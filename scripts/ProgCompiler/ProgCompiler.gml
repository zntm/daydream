/// @desc VM Opcodes for Proglang bytecode
enum PROG_OP
{
    // Stack operations
    PUSH_NULL, PUSH_TRUE, PUSH_FALSE, PUSH_CONST, PUSH_GLOBAL_REF,
    POP, DUP,
    
    // Arithmetic
    ADD, SUB, MUL, DIV, MOD, POW, NEG,
    
    // Comparison
    EQ, NE, LT, GT, LE, GE,
    
    // Logical/Bitwise
    NOT, AND, OR, BIT_AND, BIT_OR, BIT_XOR, BIT_NOT, SHL, SHR,
    
    // Variables
    LOAD, STORE, DEFINE, LOAD_GLOBAL, STORE_GLOBAL,
    
    // Structure access
    INDEX_GET, INDEX_SET, MEMBER_GET, MEMBER_SET,
    
    // Creation
    ARRAY_NEW, OBJECT_NEW, MAKE_REGEX,
    
    // Control flow
    JUMP, JUMP_IF_FALSE, JUMP_IF_TRUE, JUMP_IF_NULL, JUMP_IF_NOT_NULL, BREAK_N,
    
    // Functions
    CALL, RETURN, CALL_SPREAD, MAKE_CLOSURE,
    
    // Iteration
    ITER_INIT, ITER_NEXT, ITER_GET_VAL,
    
    // Exceptions
    PUSH_TRY, POP_TRY, THROW,
    
    // Spread operations
    PUSH_ARRAY_EMPTY, ARRAY_PUSH, ARRAY_SPREAD,
    
    // Module Ops
    IMPORT, IMPORT_UI, EXPORT_SET,
    
    // Stack Ops Extra
    DUP2, POP_AND_KEEP,
    
    // Optimization Ops
    INC, DEC,
    
    // Class System
    CLASS_DEF, NEW_INSTANCE, LOAD_THIS, LOAD_SUPER, ACCESS_CHECK,
    
    // Scoping
    PUSH_SCOPE, POP_SCOPE,
    
    // Debug
    DEBUG_LINE,
    
    // New v2 Ops
    IN_CHECK, IN_KEY, IN_VALUE, MAKE_RANGE,
    STRING_CONCAT,
    
    // Optimization Ops
    LOAD_LOCAL, STORE_LOCAL,
    
    // Annotation Ops
    MEMOIZE_CHECK, MEMOIZE_STORE
}

/// @desc Array indices for function data (replaces struct)
/// Usage: func_arr = [PROG_FUNC_TYPE, name, bytecode, is_global, param_count]
enum PROG_FUNC
{
    TYPE,           // Always "function"
    NAME,           // Function name
    BYTECODE,       // Compiled bytecode
    IS_GLOBAL,      // Boolean: is global function
    PARAM_COUNT,    // Number of parameters
    IS_INLINE,      // Boolean: is inline function
    SIZE            // Array size
}

/// @desc Array indices for closure data (replaces struct)
/// Usage: closure_arr = [PROG_CLOSURE_TYPE, bytecode, env]
enum PROG_CLOSURE
{
    TYPE,           // Always "closure"
    BYTECODE,       // Compiled bytecode
    ENV,            // Captured scope environment
    NAME,           // Function name (for debug/recursion)
    PARAM_COUNT,    // Number of parameters
    DEFINING_CLASS, // Class where method was defined
    RECEIVER,       // Bound 'this' instance
    GLOBAL_REF,     // Captured global scope for module exports
    SIZE            // Array size
}

/// @desc Array indices for script module data (replaces struct)
/// Usage: module_arr = [main_bytecode, scope_struct]
enum PROG_MODULE
{
    MAIN,           // Main bytecode
    SCOPE,          // Scope with local functions
    SIZE            // Array size
}

/// @desc Bytecode container
function ProgBytecode() constructor
{
    code = [];
    code_size = 0;
    constants = [];
    lines = [];
}

/// @desc Bytecode compiler for Proglang
/// @param {Array} _context_keys Optional array of context variable names that cannot be redeclared
function ProgCompiler(_context_keys = []) constructor
{
    bytecode = new ProgBytecode();
    loop_stack = []; // Stack of { start, continue, breaks[] }
    scope_depth = 0; // Track nesting depth for error checking
    had_error = false;
    error_message = "";
    
    inline_functions = {}; // Map of inline function name -> AST node
    inline_stack = []; // Stack for inline expansion contexts (handling returns)
    
    // Build context keywords struct from provided keys
    context_keywords = {}
    var _length = array_length(_context_keys);
    for (var i = 0; i < _length; i++)
    {
        context_keywords[$ _context_keys[i]] = true;
    }
    
    // Stack of declared variable sets per scope (for redeclaration checks)
    declared_vars = [{}];
    
    memo_count = 0; // Unique ID counter for memoized functions
    current_memo_id = undefined;
    memo_id_stack = [];
    
    // Stack of constant scopes (parallel to declared_vars)
    // Each entry is a struct of { varname: value }
    const_scopes = [{}]; 
    
    static invalidate_constants = function()
    {
        var _length = array_length(const_scopes);
        
        for (var i = 0; i < _length; ++i)
        {
            const_scopes[@ i] = {}
        }
    }
    
    static get_const = function(_name)
    {
        for (var i = array_length(const_scopes) - 1; i >= 0; --i)
        {
            var _scope = const_scopes[i][$ _name];
            
            if (_scope != undefined)
            {
                return _scope;
            }
        }
        
        return undefined;
    }
    
    static set_const = function(_name, _value)
    {
        for (var i = array_length(const_scopes) - 1; i >= 0; --i)
        {
            if (const_scopes[i][$ _name] != undefined) 
            {
                const_scopes[@ i][$ _name] = _value;
                
                return;
            }
        }
    }
    
    static remove_const = function(_name)
    {
        for (var i = array_length(const_scopes) - 1; i >= 0; i--)
        {
            if (const_scopes[i][$ _name] != undefined) 
            {
                struct_remove(const_scopes[i], _name);
                
                return;
            }
        }
    }
    
    /// @desc Reserved keywords that cannot be used as variable names
    static reserved_keywords = {
        "var": true, "global": true, "if": true, "else": true, "for": true, "in": true,
        "while": true, "repeat": true, "break": true, "continue": true, "return": true,
        "true": true, "false": true, "undefined": true, "try": true, "catch": true, "throw": true,
        "and": true, "or": true, "not": true, "switch": true, "case": true, "default": true,
        "fn": true, "import": true, "export": true, "from": true, "as": true,
        "class": true, "new": true, "this": true, "extends": true, "super": true, "static": true,
        "public": true, "private": true, "protected": true, "abstract": true, "interface": true, "implements": true
    }
    
    // Emit instruction
    static emit = function(_op, _arg = undefined, _line = 0)
    {
        array_push(bytecode.code, _op, _arg);
        array_push(bytecode.lines, _line);
        bytecode.code_size += 2;
        return bytecode.code_size - 2;
    }
    
    // Add constant with deduplication
    static add_constant = function(_value)
    {
        var _constants = bytecode.constants;
        var _constants_length = array_length(_constants);
        
        for (var i = 0; i < _constants_length; ++i)
        {
            if (_constants[i] == _value)
            {
                return i;
            }
        }
        
        array_push(_constants, _value);
        
        return _constants_length;
    }
    
    // Patch jump address
    static patch_jump = function(_address, _target)
    {
        bytecode.code[@ _address + 1] = _target;
    }
    
    /// @desc Compile AST to bytecode
    static compile = function(_ast)
    {
        invalidate_constants();
        
        if (_ast.type == PROG_AST.BLOCK)
        {
            var _statements = _ast.statements;
            var _statements_length = array_length(_statements);
            
            for (var i = 0; i < _statements_length; ++i)
            {
                compile_node(_statements[i]);
            }
        }
        else
        {
            compile_node(_ast);
        }
        
        emit(PROG_OP.PUSH_NULL);
        emit(PROG_OP.RETURN);
        
        return bytecode;
    }
    
    /// @desc Try constant folding for binary operations
    static try_fold_binary = function(_node)
    {
        // Try to simplify operands if they are identifiers known to be constant
        var _left = _node.left;
        var _right = _node.right;
        
        var _l_val = (_left.type == PROG_AST.IDENTIFIER) ? get_const(_left.name) : undefined;
        if (_l_val != undefined)
        {
            _left = { type: (is_string(_l_val) ? PROG_AST.STRING_LITERAL : (is_bool(_l_val) ? PROG_AST.BOOL_LITERAL : PROG_AST.NUMBER_LITERAL)), value: _l_val }
        }
        
        var _r_val = (_right.type == PROG_AST.IDENTIFIER) ? get_const(_right.name) : undefined;
        if (_r_val != undefined)
        {
            _right = { type: (is_string(_r_val) ? PROG_AST.STRING_LITERAL : (is_bool(_r_val) ? PROG_AST.BOOL_LITERAL : PROG_AST.NUMBER_LITERAL)), value: _r_val }
        }
        
        var _is_num_left = _left.type == PROG_AST.NUMBER_LITERAL;
        var _is_num_right = _right.type == PROG_AST.NUMBER_LITERAL;
        var _is_str_left = _left.type == PROG_AST.STRING_LITERAL;
        var _is_str_right = _right.type == PROG_AST.STRING_LITERAL;
        var _is_bool_left = _left.type == PROG_AST.BOOL_LITERAL;
        var _is_bool_right = _right.type == PROG_AST.BOOL_LITERAL;
    
        if (_is_num_left && _is_num_right)
        {
            var _a = _left.value;
            var _b = _right.value;
            switch (_node.op)
            {
                case PROG_TOKEN.PLUS: return _a + _b;
                case PROG_TOKEN.MINUS: return _a - _b;
                case PROG_TOKEN.STAR: return _a * _b;
                case PROG_TOKEN.SLASH: return _b != 0 ? _a / _b : undefined;
                case PROG_TOKEN.PERCENT: return _b != 0 ? _a % _b : undefined;
                case PROG_TOKEN.POWER: return power(_a, _b);
                case PROG_TOKEN.EQ: return _a == _b;
                case PROG_TOKEN.NE: return _a != _b;
                case PROG_TOKEN.LT: return _a < _b;
                case PROG_TOKEN.GT: return _a > _b;
                case PROG_TOKEN.LE: return _a <= _b;
                case PROG_TOKEN.GE: return _a >= _b;
                default: return undefined;
            }
        }
        
        if (_is_str_left && _is_str_right)
        {
            var _a = _left.value;
            var _b = _right.value;
            switch (_node.op)
            {
                case PROG_TOKEN.PLUS: return _a + _b;
                case PROG_TOKEN.EQ: return _a == _b;
                case PROG_TOKEN.NE: return _a != _b;
                default: return undefined;
            }
        }
        
        if (_is_bool_left && _is_bool_right)
        {
            var _a = _left.value;
            var _b = _right.value;
            switch (_node.op)
            {
                case PROG_TOKEN.EQ: return _a == _b;
                case PROG_TOKEN.NE: return _a != _b;
                case PROG_TOKEN.AND: return _a && _b;
                case PROG_TOKEN.OR: return _a || _b;
                default: return undefined;
            }
        }
        
        return undefined;
    }
    
    /// @desc Try constant folding for index access (str[i] or str[start..end])
    static try_fold_index = function(_node)
    {
        // Check if target is a known constant string
        var _target_val = undefined;
        if (_node.target.type == PROG_AST.STRING_LITERAL)
        {
            _target_val = _node.target.value;
        }
        else if (_node.target.type == PROG_AST.IDENTIFIER)
        {
            _target_val = get_const(_node.target.name);
        }
        
        if (!is_string(_target_val)) return undefined;
        
        // Check if index is a constant number or a range expression with constant bounds
        if (_node.index.type == PROG_AST.NUMBER_LITERAL)
        {
            var _index = floor(_node.index.value);
            if (_index >= 0 && _index < string_length(_target_val))
            {
                return string_char_at(_target_val, _index + 1);
            }
            return "";
        }
        else if (_node.index.type == PROG_AST.IDENTIFIER)
        {
            var _index_val = get_const(_node.index.name);
            if (is_real(_index_val))
            {
                var _index = floor(_index_val);
                if (_index >= 0 && _index < string_length(_target_val))
                {
                    return string_char_at(_target_val, _index + 1);
                }
                return "";
            }
        }
        else if (_node.index.type == PROG_AST.RANGE_EXPR)
        {
            // Get start and end values
            var _start_val = undefined;
            var _end_val = undefined;
            
            if (_node.index.range_start.type == PROG_AST.NUMBER_LITERAL)
            {
                _start_val = floor(_node.index.range_start.value);
            }
            else if (_node.index.range_start.type == PROG_AST.IDENTIFIER)
            {
                _start_val = get_const(_node.index.range_start.name);
                if (is_real(_start_val)) _start_val = floor(_start_val);
            }
            
            if (_node.index.range_end.type == PROG_AST.NUMBER_LITERAL)
            {
                _end_val = floor(_node.index.range_end.value);
            }
            else if (_node.index.range_end.type == PROG_AST.IDENTIFIER)
            {
                _end_val = get_const(_node.index.range_end.name);
                if (is_real(_end_val)) _end_val = floor(_end_val);
            }
            
            if (is_real(_start_val) && is_real(_end_val))
            {
                var _str_len = string_length(_target_val);
                if (_start_val < 0) _start_val = 0;
                if (_end_val >= _str_len) _end_val = _str_len - 1;
                
                var _slice_len = _end_val - _start_val + 1;
                if (_slice_len > 0)
                {
                    return string_copy(_target_val, _start_val + 1, _slice_len);
                }
                return "";
            }
        }
        
        return undefined;
    }
    
    static compile_func_body = function(_node)
    {
        var _parent = bytecode;
        bytecode = new ProgBytecode();
        
        // Push function scope with marker
        array_push(declared_vars, { is_func: true });
        // Push const scope logic is handled via const_scopes stack BUT functions isolate scope completely
        // so we can't share const_scopes. We must save/restore.
        var _old_scopes = const_scopes;
        const_scopes = [{}]; // Reset for new function
        
        var _param_names = [];
        for (var i = 0; i < array_length(_node.params); i++)
        {
            var _param = _node.params[i];
            array_push(_param_names, _param.name);
            
            // Error: Check context keywords
            if (struct_exists(context_keywords, _param.name)) 
            {
                had_error = true;
                error_message = $"[Line {_node.line}] Error: Context variable '{_param.name}' cannot be used as argument name.";
                bytecode = _parent;
                array_pop(declared_vars);
                const_scopes = _old_scopes;
                return { bytecode: new ProgBytecode(), params: [], param_count: 0 }
            }
            
    
            
            // Track local variable mapping
            // Note: Since arguments are already on stack at BP+i, we map them directly.
            // We don't need to emit LOAD/DEFINE/POP logic anymore for basic args.
            
            declared_vars[array_length(declared_vars) - 1][$ _param.name] = { type: "local", index: i }
            
            // Handle default values
            if (_param.default_value != undefined)
            {
                 // Default value logic is tricky with pre-pushed args.
                 // We need to check if the passed arg (at stack[BP+i]) is undefined (or missing).
                 // Actually, if missing, Call opcode pushes undefined? 
                 // My Call opcode pushes args.
                 // If call has fewer args, the stack slots are NOT filled.
                 // So BP+i might be garbage or old stack data if we didn't push undefined.
                 // In CALL logic, we didn't fill missing args with undefined.
                 // We need to fix CALL or handle here.
                 // For now, let's assume CALL pushed undefined (I need to verify/fix that).
                 
                 emit(PROG_OP.LOAD_LOCAL, i, _node.line);
                 emit(PROG_OP.PUSH_NULL);
                 emit(PROG_OP.EQ);
                 var _skip = emit(PROG_OP.JUMP_IF_FALSE, 0);
                 compile_node(_param.default_value); // Pushes default value
                 emit(PROG_OP.STORE_LOCAL, i, _node.line); // Update local (BP+i)
                 emit(PROG_OP.POP); // Consume result of store (peek)
                 patch_jump(_skip, bytecode.code_size);
            }
        }
        
        // We removed the LOAD/DEFINE/POP loop.
        // Now arguments are just locals 0..N-1.
        
        // Save and restore memo context for nested functions
        array_push(memo_id_stack, current_memo_id);
        current_memo_id = struct_exists(_node, "is_memoize") && _node.is_memoize ? memo_count++ : undefined;
        
        if (current_memo_id != undefined)
        {
            emit(PROG_OP.MEMOIZE_CHECK, current_memo_id, _node.line);
        }
        
        compile_node(_node.body);
        
        // Pop function scope
        array_pop(declared_vars);
        const_scopes = _old_scopes;
        
        if (current_memo_id != undefined)
        {
            emit(PROG_OP.MEMOIZE_STORE, current_memo_id, _node.line);
        }
        
        current_memo_id = array_pop(memo_id_stack);
        
        emit(PROG_OP.PUSH_NULL);
        emit(PROG_OP.RETURN);
        
        var _res = {
            bytecode: bytecode,
            params: _param_names,
            param_count: array_length(_node.params)
        }
        
        bytecode = _parent;
        return _res;
    }
    
    static compile_function_def = function(_node)
    {
        var _res = compile_func_body(_node);
        
        var _func_arr = array_create(PROG_FUNC.SIZE);
        _func_arr[PROG_FUNC.TYPE] = "function";
        _func_arr[PROG_FUNC.NAME] = struct_exists(_node, "name") ? _node.name : "<anonymous>";
        _func_arr[PROG_FUNC.BYTECODE] = _res.bytecode;
        _func_arr[PROG_FUNC.IS_GLOBAL] = struct_exists(_node, "is_global") ? _node.is_global : false;
        _func_arr[PROG_FUNC.PARAM_COUNT] = _res.param_count;
        _func_arr[PROG_FUNC.IS_INLINE] = struct_exists(_node, "is_inline") ? _node.is_inline : false;
        
        // Store inline function AST for call-site expansion
        if (_func_arr[PROG_FUNC.IS_INLINE] && struct_exists(_node, "name"))
        {
            inline_functions[$ _node.name] = _node;
        }
        
        var _index = add_constant(_func_arr);
        emit(PROG_OP.PUSH_CONST, _index, _node.line);
        emit(PROG_OP.MAKE_CLOSURE, undefined, _node.line);
    }
    
    static compile_identifier = function(_node, _is_assignment = false)
    {
        var _name = _node.name;
        
        // 1. Check constants/macros
        if (!_is_assignment && struct_exists(global.proglang_macros, _name))
        {
            var _val = global.proglang_macros[$ _name];
            if (is_bool(_val)) emit(_val ? PROG_OP.PUSH_TRUE : PROG_OP.PUSH_FALSE, undefined, _node.line);
            else if (is_string(_val) || is_real(_val)) emit(PROG_OP.PUSH_CONST, add_constant(_val), _node.line);
            else emit(PROG_OP.LOAD, add_constant(_name), _node.line);
            return;
        }
        
        // 2. Check locals (BP relative)
        // Search backwards from current scope until function boundary
        var _index = array_length(declared_vars) - 1;
        
        while (_index >= 0)
        {
            var _scope = declared_vars[_index];
            var _info = _scope[$ _name];
            
            if (_info != undefined) && (is_struct(_info)) && (_info.type == "local")
            {
                emit(PROG_OP.LOAD_LOCAL, _info.index, _node.line);
                
                return;
            }
            
            // Stop if we hit a function boundary
            if (struct_exists(_scope, "is_func") && _scope.is_func) break;
            
            _index--;
        }
        
        // Fallback or Capture?
        // If not found in local scopes, it loops back to LOAD name.
        // Captures are handled by runtime lookup in v2 (or closure env).
        
        // Fallback to standard named load
        emit(PROG_OP.LOAD, add_constant(_name), _node.line);
    }
    
    static compile_node = function(_node)
    {
        switch (_node.type)
        {
            // Literals
            case PROG_AST.NUMBER_LITERAL:
            case PROG_AST.STRING_LITERAL:
                emit(PROG_OP.PUSH_CONST, add_constant(_node.value), _node.line);
                break;
                
            case PROG_AST.BOOL_LITERAL:
                emit(_node.value ? PROG_OP.PUSH_TRUE : PROG_OP.PUSH_FALSE, undefined, _node.line);
                break;
                
            case PROG_AST.UNDEFINED_LITERAL:
                emit(PROG_OP.PUSH_NULL, undefined, _node.line);
                break;
                
            case PROG_AST.ARRAY_LITERAL:
                var _has_spread = false;
                for (var i = 0; i < array_length(_node.elements); i++)
                {
                    if (_node.elements[i].type == PROG_AST.UNARY_OP && _node.elements[i].op == PROG_TOKEN.SPREAD)
                    {
                        _has_spread = true; break;
                    }
                }
                if (_has_spread)
                {
                    emit(PROG_OP.PUSH_ARRAY_EMPTY, undefined, _node.line);
                    for (var i = 0; i < array_length(_node.elements); i++)
                    {
                        var _el = _node.elements[i];
                        if (_el.type == PROG_AST.UNARY_OP && _el.op == PROG_TOKEN.SPREAD)
                        {
                            compile_node(_el.right);
                            emit(PROG_OP.ARRAY_SPREAD, undefined, _node.line);
                        }
                        else
                        {
                            compile_node(_el);
                            emit(PROG_OP.ARRAY_PUSH, undefined, _node.line);
                        }
                    }
                }
                else
                {
                    for (var i = 0; i < array_length(_node.elements); i++) compile_node(_node.elements[i]);
                    emit(PROG_OP.ARRAY_NEW, array_length(_node.elements), _node.line);
                }
                break;
                
            case PROG_AST.OBJECT_LITERAL:
                for (var i = 0; i < array_length(_node.pairs); i++)
                {
                    emit(PROG_OP.PUSH_CONST, add_constant(_node.pairs[i].key), _node.line);
                    compile_node(_node.pairs[i].value);
                }
                emit(PROG_OP.OBJECT_NEW, array_length(_node.pairs), _node.line);
                break;
                
            case PROG_AST.REGEX_LITERAL:
                emit(PROG_OP.PUSH_CONST, add_constant(_node.pattern), _node.line);
                emit(PROG_OP.PUSH_CONST, add_constant(_node.flags), _node.line);
                emit(PROG_OP.MAKE_REGEX, undefined, _node.line);
                break;
                
            // Expressions
            case PROG_AST.BINARY_OP:
                // Constant folding
                var _folded = try_fold_binary(_node);
                if (_folded != undefined)
                {
                    if (is_bool(_folded))
                    {
                        emit(_folded ? PROG_OP.PUSH_TRUE : PROG_OP.PUSH_FALSE, undefined, _node.line);
                    }
                    else
                    {
                        emit(PROG_OP.PUSH_CONST, add_constant(_folded), _node.line);
                    }
                    break;
                }
                
                // Null coalescing short-circuit
                if (_node.op == PROG_TOKEN.NULL_COALESCE)
                {
                    compile_node(_node.left);
                    var _jmp = emit(PROG_OP.JUMP_IF_NOT_NULL, 0, _node.line);
                    emit(PROG_OP.POP);
                    compile_node(_node.right);
                    patch_jump(_jmp, bytecode.code_size);
                    break;
                }
                
                // Logical AND short-circuit
                if (_node.op == PROG_TOKEN.AND)
                {
                    compile_node(_node.left);
                    emit(PROG_OP.DUP, undefined, _node.line);
                    var _jmp = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                    emit(PROG_OP.POP, undefined, _node.line);
                    compile_node(_node.right);
                    patch_jump(_jmp, bytecode.code_size);
                    break;
                }
                
                // Logical OR short-circuit
                if (_node.op == PROG_TOKEN.OR)
                {
                    compile_node(_node.left);
                    emit(PROG_OP.DUP, undefined, _node.line);
                    var _jmp_eval = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                    var _jmp_end = emit(PROG_OP.JUMP, 0, _node.line);
                    
                    patch_jump(_jmp_eval, bytecode.code_size);
                    emit(PROG_OP.POP, undefined, _node.line);
                    compile_node(_node.right);
                    
                    patch_jump(_jmp_end, bytecode.code_size);
                    break;
                }
                
                compile_node(_node.left);
                compile_node(_node.right);
                
                var _opcode;
                switch (_node.op)
                {
                    case PROG_TOKEN.PLUS: 
                        // Check if we can infer string type from literals or constants
                        var _is_str_left = (_node.left.type == PROG_AST.STRING_LITERAL) || 
                                           (_node.left.type == PROG_AST.IDENTIFIER && is_string(get_const(_node.left.name)));
                        var _is_str_right = (_node.right.type == PROG_AST.STRING_LITERAL) || 
                                            (_node.right.type == PROG_AST.IDENTIFIER && is_string(get_const(_node.right.name)));
                                            
                        if (_is_str_left || _is_str_right)
                        {
                            _opcode = PROG_OP.STRING_CONCAT;
                        }
                        else
                        {
                            _opcode = PROG_OP.ADD; 
                        }
                        break;
                    case PROG_TOKEN.MINUS: _opcode = PROG_OP.SUB; break;
                    case PROG_TOKEN.STAR: _opcode = PROG_OP.MUL; break;
                    case PROG_TOKEN.SLASH: _opcode = PROG_OP.DIV; break;
                    case PROG_TOKEN.PERCENT: _opcode = PROG_OP.MOD; break;
                    case PROG_TOKEN.POWER: _opcode = PROG_OP.POW; break;
                    case PROG_TOKEN.EQ: _opcode = PROG_OP.EQ; break;
                    case PROG_TOKEN.NE: _opcode = PROG_OP.NE; break;
                    case PROG_TOKEN.LT: _opcode = PROG_OP.LT; break;
                    case PROG_TOKEN.GT: _opcode = PROG_OP.GT; break;
                    case PROG_TOKEN.LE: _opcode = PROG_OP.LE; break;
                    case PROG_TOKEN.GE: _opcode = PROG_OP.GE; break;
                    case PROG_TOKEN.AND: _opcode = PROG_OP.AND; break;
                    case PROG_TOKEN.OR: _opcode = PROG_OP.OR; break;
                    case PROG_TOKEN.AMP: _opcode = PROG_OP.BIT_AND; break;
                    case PROG_TOKEN.PIPE: _opcode = PROG_OP.BIT_OR; break;
                    case PROG_TOKEN.CARET: _opcode = PROG_OP.BIT_XOR; break;
                    case PROG_TOKEN.LSHIFT: _opcode = PROG_OP.SHL; break;
                    case PROG_TOKEN.RSHIFT: _opcode = PROG_OP.SHR; break;
                    
                    case PROG_TOKEN.COMMA:
                        _opcode = PROG_OP.POP_AND_KEEP; 
                        break;
                }
                emit(_opcode, undefined, _node.line);
                break;
                
            case PROG_AST.UNARY_OP:
                compile_node(_node.right);
                if (_node.op == PROG_TOKEN.MINUS) emit(PROG_OP.NEG, undefined, _node.line);
                else if (_node.op == PROG_TOKEN.NOT) emit(PROG_OP.NOT, undefined, _node.line);
                else if (_node.op == PROG_TOKEN.TILDE) emit(PROG_OP.BIT_NOT, undefined, _node.line);
                break;
                
            case PROG_AST.IDENTIFIER:
                compile_identifier(_node);
                break;
                
            case PROG_AST.ASSIGNMENT:
                var _known_const = undefined;
                var _invalidate = true;
                
                // 1. Analyze if we can predict the new constant value
                if (_node.target.type == PROG_AST.IDENTIFIER)
                {
                    // For straight assignment (=)
                    if (_node.op == PROG_TOKEN.ASSIGN)
                    {
                        // Check Literal
                        if (_node.value.type == PROG_AST.NUMBER_LITERAL || _node.value.type == PROG_AST.STRING_LITERAL || _node.value.type == PROG_AST.BOOL_LITERAL)
                        {
                            _known_const = _node.value.value;
                            _invalidate = false;
                        }
                        // Check Identifier (known)
                        else if (_node.value.type == PROG_AST.IDENTIFIER)
                        {
                            _known_const = get_const(_node.value.name);
                            if (_known_const != undefined) _invalidate = false;
                        }
                        // Check Binary Fold
                        else if (_node.value.type == PROG_AST.BINARY_OP)
                        {
                            var _folded = try_fold_binary(_node.value);
                            if (_folded != undefined)
                            {
                                _known_const = _folded;
                                _invalidate = false;
                            }
                        }
                    }
                    // For compound assignment (+=, -=, etc)
                    else 
                    {
                        var _old_val = get_const(_node.target.name);
                        if (_old_val != undefined)
                        {
                            var _rhs_val = undefined;
                            
                            // Determine RHS value
                            if (_node.value.type == PROG_AST.NUMBER_LITERAL) _rhs_val = _node.value.value;
                            else if (_node.value.type == PROG_AST.IDENTIFIER) _rhs_val = get_const(_node.value.name);
                            else if (_node.value.type == PROG_AST.BINARY_OP) _rhs_val = try_fold_binary(_node.value);
                            
                            if (_rhs_val != undefined && is_real(_old_val) && is_real(_rhs_val))
                            {
                                switch (_node.op)
                                {
                                    case PROG_TOKEN.PLUS_ASSIGN: _known_const = _old_val + _rhs_val; _invalidate = false; break;
                                    case PROG_TOKEN.MINUS_ASSIGN: _known_const = _old_val - _rhs_val; _invalidate = false; break;
                                    case PROG_TOKEN.STAR_ASSIGN: _known_const = _old_val * _rhs_val; _invalidate = false; break;
                                    case PROG_TOKEN.SLASH_ASSIGN: if (_rhs_val != 0) { _known_const = _old_val / _rhs_val; _invalidate = false; } break;
                                    case PROG_TOKEN.PERCENT_ASSIGN: if (_rhs_val != 0) { _known_const = _old_val % _rhs_val; _invalidate = false; } break;
                                    case PROG_TOKEN.POWER_ASSIGN: _known_const = power(_old_val, _rhs_val); _invalidate = false; break;
                                    case PROG_TOKEN.LSHIFT_ASSIGN: _known_const = ((_old_val << _rhs_val) & 0xFFFFFFFF); _invalidate = false; break;
                                    case PROG_TOKEN.RSHIFT_ASSIGN: _known_const = (_old_val >> _rhs_val); _invalidate = false; break;
                                    case PROG_TOKEN.AMP_ASSIGN: _known_const = (_old_val & _rhs_val); _invalidate = false; break;
                                    case PROG_TOKEN.PIPE_ASSIGN: _known_const = (_old_val | _rhs_val); _invalidate = false; break;
                                    case PROG_TOKEN.CARET_ASSIGN: _known_const = (_old_val ^ _rhs_val); _invalidate = false; break;
                                }
                            }
                        }
                    }
                }
                
                // 2. Compile the assignment
                compile_assignment(_node);
                
                // 3. Update Constant State
                if (_node.target.type == PROG_AST.IDENTIFIER)
                {
                    if (!_invalidate && _known_const != undefined)
                    {
                        set_const(_node.target.name, _known_const);
                    }
                    else
                    {
                        remove_const(_node.target.name);
                    }
                }
                break;
                
            case PROG_AST.VAR_DECL:
                // Error: Check if name is a reserved keyword
                if (struct_exists(reserved_keywords, _node.name))
                {
                    had_error = true;
                    error_message = $"[Line {_node.line}] Error: Cannot use reserved keyword '{_node.name}' as variable name.";
                    
                    return;
                }
                // Error: Check if name shadows a context variable
                if (struct_exists(context_keywords, _node.name))
                {
                    had_error = true;
                    error_message = $"[Line {_node.line}] Error: Cannot redeclare context variable '{_node.name}'.";
                    
                    return;
                }
                
                // Error: Check for redeclaration in the current scope
                var _current_scope = array_last(declared_vars);
                if (struct_exists(_current_scope, _node.name))
                {
                    had_error = true;
                    error_message = $"[Line {_node.line}] Error: Variable '{_node.name}' already declared in this scope.";
                    
                    return;
                }
                
                // Add to current scope declarations
                _current_scope[$ _node.name] = true;
                
                // Error: Check if global var declared inside nested scope
                if (_node[$ "is_global"]) && (scope_depth > 0)
                {
                    had_error = true;
                    error_message = $"[Line {_node.line}] Error: Global variables must be declared at top level, not inside statements.";
                    return;
                }
                
                var _init_const = undefined;
                if (_node.initializer != undefined) 
                {
                    // Constant tracking
                    if (_node.initializer.type == PROG_AST.NUMBER_LITERAL || _node.initializer.type == PROG_AST.STRING_LITERAL || _node.initializer.type == PROG_AST.BOOL_LITERAL)
                    {
                        _init_const = _node.initializer.value;
                    }
                    else if (_node.initializer.type == PROG_AST.IDENTIFIER)
                    {
                        _init_const = get_const(_node.initializer.name);
                    }
                    else if (_node.initializer.type == PROG_AST.BINARY_OP)
                    {
                        var _folded = try_fold_binary(_node.initializer);
                        if (_folded != undefined) _init_const = _folded;
                    }
                    
                    compile_node(_node.initializer);
                }
                else 
                {
                    // Undefined is not treated as a foldable constant currently (simplifies logic)
                    emit(PROG_OP.PUSH_NULL, undefined, _node.line);
                }
                
                var _index = add_constant(_node.name);
                if (_node[$ "is_global"])
                {
                    emit(PROG_OP.STORE_GLOBAL, _index, _node.line);
                }
                else
                {
                    emit(PROG_OP.DEFINE, _index, _node.line);
                    
                    // Track local constant
                    if (_init_const != undefined)
                    {
                        var _scope = array_last(const_scopes);
                        _scope[$ _node.name] = _init_const;
                    }
                }
                emit(PROG_OP.POP, undefined, _node.line);
                break;
                
            case PROG_AST.BLOCK:
                scope_depth++;
                array_push(declared_vars, {});
                array_push(const_scopes, {}); // Start new constant scope
                emit(PROG_OP.PUSH_SCOPE, undefined, _node.line);
                for (var i = 0; i < array_length(_node.statements); i++)
                {
                    compile_node(_node.statements[i]);
                }
                emit(PROG_OP.POP_SCOPE, undefined, _node.line);
                array_pop(const_scopes); // End constant scope
                array_pop(declared_vars);
                scope_depth--;
                break;
                
            case PROG_AST.FUNC_DECL:
                compile_function_def(_node);
                
                var _name_index = add_constant(_node.name);
                emit(_node.is_global ? PROG_OP.STORE_GLOBAL : PROG_OP.STORE, _name_index, _node.line);
                emit(PROG_OP.POP);
                break;
                
            case PROG_AST.FUNC_EXPR:
                compile_function_def(_node);
                break;
                
            case PROG_AST.EXPRESSION_STMT:
                compile_node(_node.expression);
                emit(PROG_OP.POP, undefined, _node.line);
                break;
                
            case PROG_AST.IF_STMT:
                compile_node(_node.condition);
                invalidate_constants(); // Invalidate on branches
                var _jmp_else = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                compile_node(_node.then_branch);
                var _jmp_end = emit(PROG_OP.JUMP, 0, _node.line);
                patch_jump(_jmp_else, bytecode.code_size);
                if (_node.else_branch != undefined) compile_node(_node.else_branch);
                patch_jump(_jmp_end, bytecode.code_size);
                break;
                
            case PROG_AST.WHILE_STMT:
                invalidate_constants();
                var _start = bytecode.code_size;
                compile_node(_node.condition);
                var _exit = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                
                array_push(loop_stack, { start: _start, continue_addr: _start, breaks: [] });
                
                compile_node(_node.body);
                emit(PROG_OP.JUMP, _start, _node.line);
                patch_jump(_exit, bytecode.code_size);
                
                var _loop = array_pop(loop_stack);
                for (var i = 0; i < array_length(_loop.breaks); i++)
                {
                    patch_jump(_loop.breaks[i], bytecode.code_size);
                }
                break;
                
            case PROG_AST.REPEAT_STMT:
                invalidate_constants();
                var _rep_var = "@rep_" + string(bytecode.code_size);
                var _index = add_constant(_rep_var);
                compile_node(_node.count);
                emit(PROG_OP.STORE, _index, _node.line);
                emit(PROG_OP.POP);
                
                var _start = bytecode.code_size;
                emit(PROG_OP.LOAD, _index, _node.line);
                emit(PROG_OP.PUSH_CONST, add_constant(0));
                emit(PROG_OP.GT);
                var _exit = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                
                array_push(loop_stack, { start: _start, continue_addr: _start, breaks: [] });
                
                compile_node(_node.body);
                
                emit(PROG_OP.LOAD, _index);
                emit(PROG_OP.PUSH_CONST, add_constant(1));
                emit(PROG_OP.SUB);
                emit(PROG_OP.STORE, _index);
                emit(PROG_OP.POP);
                emit(PROG_OP.JUMP, _start);
                patch_jump(_exit, bytecode.code_size);
                
                var _loop = array_pop(loop_stack);
                for (var i = 0; i < array_length(_loop.breaks); i++)
                {
                    patch_jump(_loop.breaks[i], bytecode.code_size);
                }
                break;
                
            case PROG_AST.FOR_STMT:
                // Initialize scope for For loop variable if VarDecl
                // Note: PROG_AST.FOR usually has its own block scope logic if we implemented let/const strictly,
                // but here var is function-scoped. However, for constant tracking, we treat initializer as current scope.
                
                if (_node.initializer)
                {
                    if (_node.initializer.type == PROG_AST.VAR_DECL) compile_node(_node.initializer);
                    else { compile_node(_node.initializer); emit(PROG_OP.POP); }
                }
                
                // Loop starts: invalidate constants as we re-enter this block
                var _start = bytecode.code_size;
                invalidate_constants(); 
                
                var _exit = -1;
                if (_node.condition)
                {
                    compile_node(_node.condition);
                    _exit = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                }
                
                var _loop_ctx = { start: _start, continue_jumps: [], breaks: [] }
                array_push(loop_stack, _loop_ctx);
                
                compile_node(_node.body);
                
                var _inc_addr = bytecode.code_size;
                for (var i = 0; i < array_length(_loop_ctx.continue_jumps); i++)
                {
                    patch_jump(_loop_ctx.continue_jumps[i], _inc_addr);
                }
                
                if (_node.increment)
                {
                    compile_node(_node.increment); emit(PROG_OP.POP);
                }

                emit(PROG_OP.JUMP, _start, _node.line);
                if (_exit != -1) patch_jump(_exit, bytecode.code_size);
                
                array_pop(loop_stack);
                for (var i = 0; i < array_length(_loop_ctx.breaks); i++)
                {
                    patch_jump(_loop_ctx.breaks[i], bytecode.code_size);
                }
                break;
                
            case PROG_AST.CONTINUE_STMT:
                if (array_length(loop_stack) > 0)
                {
                    var _ctx = array_last(loop_stack);
                    if (struct_exists(_ctx, "continue_addr"))
                    {
                        emit(PROG_OP.JUMP, _ctx.continue_addr, _node.line);
                    }
                    else
                    {
                        array_push(_ctx.continue_jumps, emit(PROG_OP.JUMP, 0, _node.line));
                    }
                }
                break;
    
            case PROG_AST.BREAK_STMT:
                if (array_length(loop_stack) > 0)
                {
                    var _amount = 1;
                    if (_node.amount != undefined)
                    {
                        if (_node.amount.type == PROG_AST.NUMBER_LITERAL)
                        {
                            _amount = floor(_node.amount.value);
                        }
                        else
                        {
                            // Error: break amount must be a number literal
                            _amount = 1;
                        }
                    }
                    _amount = clamp(_amount, 1, array_length(loop_stack));
                    
                    // Pop items for each loop level being broken out of
                    for (var i = 0; i < _amount; i++)
                    {
                        var _lidx = array_length(loop_stack) - 1 - i;
                        var _l = loop_stack[_lidx];
                        if (struct_exists(_l, "needs_pop") && _l.needs_pop)
                        {
                            emit(PROG_OP.POP, undefined, _node.line);
                        }
                    }
                    
                    var _target_index = array_length(loop_stack) - _amount;
                    var _ctx = loop_stack[_target_index];
                    array_push(_ctx.breaks, emit(PROG_OP.JUMP, 0, _node.line));
                }
                break;
                
            case PROG_AST.TERNARY:
                compile_node(_node.condition);
                var _jf = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                compile_node(_node.true_branch);
                var _je = emit(PROG_OP.JUMP, 0, _node.line);
                patch_jump(_jf, bytecode.code_size);
                compile_node(_node.false_branch);
                patch_jump(_je, bytecode.code_size);
                break;
                
            case PROG_AST.PREFIX_OP:
                if (_node.target.type == PROG_AST.IDENTIFIER)
                {
                    var _index = add_constant(_node.target.name);
                    emit(PROG_OP.LOAD, _index, _node.line);
                    emit(_node.op == PROG_TOKEN.PLUS_PLUS ? PROG_OP.INC : PROG_OP.DEC);
                    emit(PROG_OP.STORE, _index, _node.line);
                    
                    // Update constants for PREFIX
                    var _val = get_const(_node.target.name);
                    if (_val != undefined && is_real(_val))
                    {
                        set_const(_node.target.name, _val + (_node.op == PROG_TOKEN.PLUS_PLUS ? 1 : -1));
                    }
                    else
                    {
                        remove_const(_node.target.name);
                    }
                }
                else if (_node.target.type == PROG_AST.MEMBER)
                {
                    compile_node(_node.target.target); // Obj
                    emit(PROG_OP.DUP);
                    emit(PROG_OP.MEMBER_GET, add_constant(_node.target.property), _node.line);
                    emit(_node.op == PROG_TOKEN.PLUS_PLUS ? PROG_OP.INC : PROG_OP.DEC);
                    emit(PROG_OP.MEMBER_SET, add_constant(_node.target.property), _node.line);
                }
                else if (_node.target.type == PROG_AST.INDEX)
                {
                    compile_node(_node.target.target); // Arr
                    compile_node(_node.target.index); // Idx
                    emit(PROG_OP.DUP2);
                    emit(PROG_OP.INDEX_GET, undefined, _node.line);
                    emit(_node.op == PROG_TOKEN.PLUS_PLUS ? PROG_OP.INC : PROG_OP.DEC);
                    emit(PROG_OP.INDEX_SET, undefined, _node.line);
                }
                break;
                
            case PROG_AST.POSTFIX_OP:
                if (_node.target.type == PROG_AST.IDENTIFIER)
                {
                    var _index = add_constant(_node.target.name);
                    emit(PROG_OP.LOAD, _index, _node.line);
                    emit(PROG_OP.DUP);
                    emit(_node.op == PROG_TOKEN.PLUS_PLUS ? PROG_OP.INC : PROG_OP.DEC);
                    emit(PROG_OP.STORE, _index, _node.line);
                    emit(PROG_OP.POP);
                    
                    // Update constants for POSTFIX (same internal upgrade)
                    var _val = get_const(_node.target.name);
                    if (_val != undefined && is_real(_val))
                    {
                        set_const(_node.target.name, _val + (_node.op == PROG_TOKEN.PLUS_PLUS ? 1 : -1));
                    }
                    else
                    {
                        remove_const(_node.target.name);
                    }
                }
                else if (_node.target.type == PROG_AST.MEMBER)
                {
                    var _temp = "@post_tmp_" + string(bytecode.code_size);
                    var _tidx = add_constant(_temp);
                    
                    compile_node(_node.target.target); // Obj
                    emit(PROG_OP.DUP);
                    emit(PROG_OP.MEMBER_GET, add_constant(_node.target.property), _node.line); // Obj, Val
                    emit(PROG_OP.STORE, _tidx); // Obj, Val
                    emit(PROG_OP.POP); // Obj
                    
                    emit(PROG_OP.LOAD, _tidx); // Obj, Val
                    emit(_node.op == PROG_TOKEN.PLUS_PLUS ? PROG_OP.INC : PROG_OP.DEC); // Obj, NewVal
                    emit(PROG_OP.MEMBER_SET, add_constant(_node.target.property), _node.line); // Set returns NewVal. Stack: NewVal
                    emit(PROG_OP.POP); // Consume NewVal
                    emit(PROG_OP.LOAD, _tidx); // Return Original
                }
                else if (_node.target.type == PROG_AST.INDEX)
                {
                    var _temp = "@post_tmp_" + string(bytecode.code_size);
                    var _tidx = add_constant(_temp);
    
                    compile_node(_node.target.target); // Arr
                    compile_node(_node.target.index); // Idx
                    emit(PROG_OP.DUP2); 
                    emit(PROG_OP.INDEX_GET, undefined, _node.line); // Arr, Idx, Val
                    emit(PROG_OP.STORE, _tidx); // Arr, Idx, Val
                    emit(PROG_OP.POP); // Arr, Idx
                    
                    emit(PROG_OP.LOAD, _tidx); // Arr, Idx, Val
                    emit(_node.op == PROG_TOKEN.PLUS_PLUS ? PROG_OP.INC : PROG_OP.DEC); // Arr, Idx, NewVal
                    emit(PROG_OP.INDEX_SET, undefined, _node.line); // NewVal
                    emit(PROG_OP.POP);
                    emit(PROG_OP.LOAD, _tidx);
                }
                break;
                
            case PROG_AST.SWITCH_STMT:
                compile_node(_node.expr);
                
                // Switch involves jumps, so invalidate
                invalidate_constants();
                
                var _case_jumps = []; // Jumps from checks to their bodies
                var _end_jumps = [];  // Jumps to the end of switch
                
                // Phase 1: Emit all case checks
                for (var i = 0; i < array_length(_node.cases); i++)
                {
                    var _case = _node.cases[i];
                    emit(PROG_OP.DUP); // Keep expr for comparison
                    compile_node(_case.value);
                    emit(PROG_OP.EQ);
                    // If NOT equal, skip to next check
                    var _skip_to_next = emit(PROG_OP.JUMP_IF_FALSE, 0);
                    emit(PROG_OP.POP); // Match! Consume duplicated expr
                    var _jump_to_body = emit(PROG_OP.JUMP, 0);
                    array_push(_case_jumps, _jump_to_body);
                    patch_jump(_skip_to_next, bytecode.code_size);
                }
                
                // Phase 2: After all checks, handle default or end
                emit(PROG_OP.POP); // Pop expr (no case matched)
                if (_node.default_case != undefined)
                {
                    var _to_default = emit(PROG_OP.JUMP, 0); 
                    array_push(_case_jumps, _to_default);
                }
                else
                {
                    var _to_end = emit(PROG_OP.JUMP, 0); 
                    array_push(_end_jumps, _to_end);
                }
                
                // Phase 3: Emit case bodies
                var _switch_ctx = { breaks: [] }
                array_push(loop_stack, _switch_ctx);
                
                for (var i = 0; i < array_length(_node.cases); i++)
                {
                    var _case = _node.cases[i];
                    patch_jump(_case_jumps[i], bytecode.code_size);
                    compile_node(_case.body);
                }
                
                // Phase 4: Default body
                if (_node.default_case != undefined)
                {
                    var _def_jmp_index = array_length(_node.cases);
                    patch_jump(_case_jumps[_def_jmp_index], bytecode.code_size);
                    compile_node(_node.default_case);
                }
                
                // Phase 5: Patch all breaks and end jumps
                array_pop(loop_stack);
                for (var i = 0; i < array_length(_switch_ctx.breaks); i++)
                {
                    patch_jump(_switch_ctx.breaks[i], bytecode.code_size);
                }
                for (var i = 0; i < array_length(_end_jumps); i++)
                {
                    patch_jump(_end_jumps[i], bytecode.code_size);
                }
                break;
                
            case PROG_AST.CALL:
                var _is_inline_call = false;
                var _func_node = undefined;
                
                // Check if inline
                if (_node.callee.type == PROG_AST.IDENTIFIER)
                {
                    if (struct_exists(inline_functions, _node.callee.name))
                    {
                        _func_node = inline_functions[$ _node.callee.name];
                        _is_inline_call = true;
                    }
                }
                
                var _has_spread = false;
                if (!_is_inline_call)
                {
                    for (var i = 0; i < array_length(_node.args); i++)
                    {
                        if (_node.args[i].type == PROG_AST.UNARY_OP && _node.args[i].op == PROG_TOKEN.SPREAD)
                        {
                            _has_spread = true; break;
                        }
                    }
                }
                
                if (_is_inline_call)
                {
                    // INLINE EXPANSION
                    var _ret_var = "@inline_ret_" + string(bytecode.code_size);
                    var _ctx = { ret_var: _ret_var, jumps: [], start_depth: scope_depth };
                    array_push(inline_stack, _ctx);
                    
                    // Initialize return variable to undefined
                    emit(PROG_OP.PUSH_NULL);
                    emit(PROG_OP.DEFINE, add_constant(_ret_var), _node.line);
                    emit(PROG_OP.POP);
                    
                    // Push Scope for function body
                    emit(PROG_OP.PUSH_SCOPE, undefined, _node.line);
                    
                    // Bind Parameters
                    var _params = _func_node.params;
                    var _param_count = array_length(_params);
                    var _arg_count = array_length(_node.args);
                    
                    for (var i = 0; i < _param_count; i++)
                    {
                        var _param = _params[i];
                        
                        if (i < _arg_count)
                        {
                            compile_node(_node.args[i]);
                        }
                        else
                        {
                            // Missing argument - use default or undefined
                            if (_param.default_value != undefined) compile_node(_param.default_value);
                            else emit(PROG_OP.PUSH_NULL);
                        }
                        
                        emit(PROG_OP.DEFINE, add_constant(_param.name), _node.line);
                        emit(PROG_OP.POP);
                    }
                    
                    // Compile Body
                    // Note: func_node.body is a BLOCK, which emits PUSH/POP SCOPE itself.
                    // This means we have: InlineScope -> BlockScope.
                    // This is fine, but maybe redundant. 
                    // However, we need InlineScope to hold the params so they are local to the expansion
                    // but visible to the body.
                    compile_node(_func_node.body);
                    
                    // Patch Return Jumps
                    for (var j = 0; j < array_length(_ctx.jumps); j++)
                    {
                        patch_jump(_ctx.jumps[j], bytecode.code_size);
                    }
                    
                    // Pop Scope
                    emit(PROG_OP.POP_SCOPE, undefined, _node.line);
                    
                    // Pop Context
                    array_pop(inline_stack);
                    
                    // Load Result
                    emit(PROG_OP.LOAD, add_constant(_ret_var), _node.line);
                }
                else if (_has_spread)
                {
                    emit(PROG_OP.PUSH_ARRAY_EMPTY, undefined, _node.line);
                    for (var i = 0; i < array_length(_node.args); i++)
                    {
                        var _arg = _node.args[i];
                        if (_arg.type == PROG_AST.UNARY_OP && _arg.op == PROG_TOKEN.SPREAD)
                        {
                            compile_node(_arg.right);
                            emit(PROG_OP.ARRAY_SPREAD, undefined, _node.line);
                        }
                        else
                        {
                            compile_node(_arg);
                            emit(PROG_OP.ARRAY_PUSH, undefined, _node.line);
                        }
                    }
                    compile_node(_node.callee);
                    emit(PROG_OP.CALL_SPREAD, undefined, _node.line);
                }
                else
                {
                    compile_node(_node.callee);
                    for (var i = 0; i < array_length(_node.args); i++) compile_node(_node.args[i]);
                    emit(PROG_OP.CALL, array_length(_node.args), _node.line);
                }
                break;
                
            case PROG_AST.MEMBER:
                compile_node(_node.target);
                emit(PROG_OP.MEMBER_GET, add_constant(_node.property), _node.line);
                break;
                
            case PROG_AST.INDEX:
                var _folded_index = try_fold_index(_node);
                if (_folded_index != undefined)
                {
                    emit(PROG_OP.PUSH_CONST, add_constant(_folded_index), _node.line);
                }
                else
                {
                    compile_node(_node.target);
                    compile_node(_node.index);
                    emit(PROG_OP.INDEX_GET, undefined, _node.line);
                }
                break;
                
            case PROG_AST.RETURN_STMT:
                if (array_length(inline_stack) > 0)
                {
                    // Inline return: Assign to ret var and jump to end
                    var _ctx = array_last(inline_stack);
                    
                    if (_node.value) compile_node(_node.value);
                    else emit(PROG_OP.PUSH_NULL);
                    
                    // Memoization in inline functions (if we ever support it, but for now we follow current_memo_id)
                    // Wait, if an inline function is memoized, its result should be cached.
                    // But currently we only handle @inline OR @memoize, usually not both.
                    // If both are used, we follow current_memo_id.
                    if (current_memo_id != undefined)
                    {
                        emit(PROG_OP.MEMOIZE_STORE, current_memo_id, _node.line);
                    }
                    
                    // Store in return variable
                    var _ret_idx = add_constant(_ctx.ret_var);
                    // Use LOAD/STORE for locals in current scope? No, scope is handled by PUSH_SCOPE.
                    // But we used add_constant for unique name.
                    // We need to ensure we are addressing the variable correctly.
                    // Since we are inside a PUSH_SCOPE block, we can use STORE.
                    // But wait, STORE uses constants to find name in scope.
                    emit(PROG_OP.STORE, _ret_idx, _node.line); 
                    emit(PROG_OP.POP); // Consume value (STORE leaves it on stack)
                    
                    // Jump to end
                    var _pop_count = scope_depth - _ctx.start_depth;
                    for (var k = 0; k < _pop_count; k++) emit(PROG_OP.POP_SCOPE, undefined, _node.line);
                    
                    array_push(_ctx.jumps, emit(PROG_OP.JUMP, 0, _node.line));
                }
                else
                {
                    // Normal return
                    if (_node.value) compile_node(_node.value);
                    else emit(PROG_OP.PUSH_NULL);
                    
                    if (current_memo_id != undefined)
                    {
                        emit(PROG_OP.MEMOIZE_STORE, current_memo_id, _node.line);
                    }
                    
                    emit(PROG_OP.RETURN, undefined, _node.line);
                }
                break;
                
            case PROG_AST.FOR_IN_STMT:
                invalidate_constants(); // Invalidate before loop
                compile_node(_node.collection);
                
                // Determine Iteration Mode
                // 0: Default (Single var, no modifier) -> Error on struct
                // 1: Key (modifier == "key")
                // 2: Value (modifier == "value")
                // 3: Pair (Two variables) -> OK on struct (implicit key iteration, fetching value manual)
                
                var _mode = 0;
                
                var _mod = undefined;
                if (struct_exists(_node, "modifier")) _mod = _node.modifier;
                
                if (_mod == "key") _mode = 1;
                else if (_mod == "value") _mode = 2;
                else if (struct_exists(_node, "value_var") && _node.value_var != undefined) _mode = 3;
                
                emit(PROG_OP.ITER_INIT, _mode, _node.line);
                var _start = bytecode.code_size;
                
                // Track loop for break/continue
                var _loop_ctx = { start: _start, continue_addr: _start, breaks: [], needs_pop: true }
                array_push(loop_stack, _loop_ctx);
                
                emit(PROG_OP.ITER_NEXT, undefined, _node.line);
                var _exit = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                
                if (_mod == "key")
                {
                    // Key iteration: Variable becomes the key
                    emit(PROG_OP.DEFINE, add_constant(_node.variable), _node.line);
                    emit(PROG_OP.POP);
                }
                else if (_mod == "value")
                {
                    // Value iteration: Variable becomes the value
                    emit(PROG_OP.POP); // Discard Key
                    emit(PROG_OP.ITER_GET_VAL, undefined, _node.line);
                    emit(PROG_OP.DEFINE, add_constant(_node.variable), _node.line);
                    emit(PROG_OP.POP);
                }
                else if (struct_exists(_node, "value_var") && _node.value_var != undefined)
                {
                    // If two variables requested (k, v in arr): first is key, second is value
                    // _node.variable is the key, _node.value_var is the value (per AST definition)
                    emit(PROG_OP.DEFINE, add_constant(_node.variable), _node.line); // Define Key
                    emit(PROG_OP.POP); // Consume Key
                    emit(PROG_OP.ITER_GET_VAL, undefined, _node.line); // Pushes Value using Iterator
                    emit(PROG_OP.DEFINE, add_constant(_node.value_var), _node.line); // Define Value
                    emit(PROG_OP.POP); // Consume Value
                }
                else
                {
                    // Single variable default: iterate over VALUES (not keys)
                    // Stack: Iter, Key - but we want the value
                    emit(PROG_OP.POP); // Pop the key, we don't need it
                    emit(PROG_OP.ITER_GET_VAL, undefined, _node.line); // Push value
                    emit(PROG_OP.DEFINE, add_constant(_node.variable), _node.line); // Define Value
                    emit(PROG_OP.POP); // Consume Value
                }
                
                compile_node(_node.body);
                emit(PROG_OP.JUMP, _start, _node.line);
                patch_jump(_exit, bytecode.code_size);
                emit(PROG_OP.POP); // Pop iterator
                
                array_pop(loop_stack);
                for (var i = 0; i < array_length(_loop_ctx.breaks); i++)
                {
                    patch_jump(_loop_ctx.breaks[i], bytecode.code_size);
                }
                break;
                
            case PROG_AST.TRY_STMT:
                invalidate_constants(); // Conservative
                var _catch_jmp = emit(PROG_OP.PUSH_TRY, 0, _node.line);
                compile_node(_node.try_block);
                emit(PROG_OP.POP_TRY, undefined, _node.line);
                var _end_jmp = emit(PROG_OP.JUMP, 0, _node.line);
                patch_jump(_catch_jmp, bytecode.code_size);
                
                invalidate_constants(); // Catch block entry
                if (_node.catch_var != undefined)
                {
                    emit(PROG_OP.STORE, add_constant(_node.catch_var), _node.line);
                    emit(PROG_OP.POP);
                }
                else
                {
                    emit(PROG_OP.POP);
                }
                if (_node.catch_block != undefined) compile_node(_node.catch_block);
                patch_jump(_end_jmp, bytecode.code_size);
                break;
            
            case PROG_AST.IMPORT_STMT:
                // Check if importing from a .ui file
                var _is_ui = string_ends_with(_node.module_path, ".ui");
                
                if (_is_ui)
                {
                    emit(PROG_OP.IMPORT_UI, add_constant(_node.module_path), _node.line);
                }
                else
                {
                    emit(PROG_OP.IMPORT, add_constant(_node.module_path), _node.line);
                }
                // Stack: ExportsStruct (or UI definitions struct)
                for (var i = 0; i < array_length(_node.imports); i++)
                {
                    var _imp = _node.imports[i];
                    emit(PROG_OP.DUP); // Exports, Exports
                    if (struct_exists(_imp, "is_default") && _imp.is_default)
                    {
                        emit(PROG_OP.MEMBER_GET, add_constant(_imp.name), _node.line);
                    }
                    else
                    {
                        emit(PROG_OP.MEMBER_GET, add_constant(_imp.name), _node.line);
                    }
                    // Stack: Exports, Val
                    emit(PROG_OP.DEFINE, add_constant(_imp.alias), _node.line);
                    emit(PROG_OP.POP); // Exports
                }
                emit(PROG_OP.POP); // Pop Exports
                break;
                
            case PROG_AST.EXPORT_STMT:
                if (_node.is_default)
                {
                    compile_node(_node.declaration);
                    emit(PROG_OP.EXPORT_SET, add_constant("default"), _node.line);
                    emit(PROG_OP.POP);
                }
                else
                {
                    compile_node(_node.declaration);
                    if (_node.declaration.type == PROG_AST.VAR_DECL)
                    {
                        emit(PROG_OP.LOAD, add_constant(_node.declaration.name), _node.line);
                        emit(PROG_OP.EXPORT_SET, add_constant(_node.declaration.name), _node.line);
                        emit(PROG_OP.POP);
                    }
                    else if (_node.declaration.type == PROG_AST.FUNC_DECL)
                    {
                        emit(PROG_OP.LOAD, add_constant(_node.declaration.name), _node.line);
                        emit(PROG_OP.EXPORT_SET, add_constant(_node.declaration.name), _node.line);
                        emit(PROG_OP.POP);
                    }
                }
                break;
            
            case PROG_AST.THROW_STMT:
                compile_node(_node.expression);
                emit(PROG_OP.THROW, undefined, _node.line);
                break;
                
            case PROG_AST.DESTRUCTURING_DECL:
                if (_node.initializer != undefined) compile_node(_node.initializer);
                else emit(PROG_OP.PUSH_NULL);
                
                compile_destructuring({ type: _node.pattern_type, elements: _node.elements });
                
                emit(PROG_OP.POP);
                break;
                
            case PROG_AST.CLASS_DECL:
                compile_class_def(_node);
                break;
                
            case PROG_AST.NEW_EXPR:
                for (var i = 0; i < array_length(_node.args); i++)
                {
                    compile_node(_node.args[i]);
                }
                
                emit(PROG_OP.LOAD, add_constant(_node.class_name), _node.line);
                emit(PROG_OP.NEW_INSTANCE, array_length(_node.args), _node.line);
                break;
                
            case PROG_AST.THIS_EXPR:
                emit(PROG_OP.LOAD_THIS, undefined, _node.line);
                break;
                
            case PROG_AST.SUPER_EXPR:
                emit(PROG_OP.LOAD_SUPER, undefined, _node.line);
                break;
                
            // ========== NEW V2 FEATURES ==========
            
            case PROG_AST.IN_EXPR:
                compile_node(_node.left);
                compile_node(_node.right);
                if (_node.modifier == "key") emit(PROG_OP.IN_KEY, undefined, _node.line);
                else if (_node.modifier == "value") emit(PROG_OP.IN_VALUE, undefined, _node.line);
                else emit(PROG_OP.IN_CHECK, undefined, _node.line);
                break;
                
            case PROG_AST.RANGE_EXPR:
                compile_node(_node.range_start);
                compile_node(_node.range_end);
                emit(PROG_OP.MAKE_RANGE, undefined, _node.line);
                break;
                
            case PROG_AST.OPTIONAL_MEMBER:
                // obj?.prop -> if obj is null/undefined, result is undefined
                compile_node(_node.target);
                var _skip = emit(PROG_OP.JUMP_IF_NULL, 0, _node.line);
                emit(PROG_OP.MEMBER_GET, add_constant(_node.property), _node.line);
                patch_jump(_skip, bytecode.code_size);
                break;
                
            case PROG_AST.OPTIONAL_INDEX:
                // obj?.[idx] -> if obj is null/undefined, result is undefined
                compile_node(_node.target);
                var _skip = emit(PROG_OP.JUMP_IF_NULL, 0, _node.line);
                compile_node(_node.index);
                emit(PROG_OP.INDEX_GET, undefined, _node.line);
                patch_jump(_skip, bytecode.code_size);
                break;
        }
    }
    
    static compile_class_def = function(_node)
    {
        var _descriptor = {
            name: _node.name,
            super_class: _node.super_class,
            methods: {},
            statics: {},
            fields: [],
            __type__: "class"
        }
        
        // Constructor
        if (_node.class_constructor != undefined)
        {
            var _ctor = _node.class_constructor;
            _descriptor.constructor_code = compile_func_body(_ctor).bytecode;
            _descriptor.constructor_params = array_length(_ctor.params);
        }
        
        // Members
        for (var i = 0; i < array_length(_node.members); i++)
        {
            var _mem = _node.members[i];
            if (_mem.type == "method")
            {
                if (_mem.node.body == undefined) continue;
                var _bc = compile_func_body(_mem.node);
                var _entry = { 
                    bytecode: _bc.bytecode, 
                    params: _bc.params, // Param names
                    param_count: _bc.param_count,
                    access: _mem.access 
                }
                
                if (_mem.is_static)
                {
                    _descriptor.statics[$ _mem.node.name] = _entry;
                }
                else
                {
                    _descriptor.methods[$ _mem.node.name] = _entry;
                }
            }
            else
            {
                // Field (instance or static)
                if (_mem.is_static)
                {
                    // Static field: extract literal value if possible
                    var _value = undefined;
                    if (_mem.node.initializer != undefined)
                    {
                        var _init = _mem.node.initializer;
                        if (_init.type == PROG_AST.NUMBER_LITERAL || _init.type == PROG_AST.STRING_LITERAL)
                        {
                            _value = _init.value;
                        }
                        else if (_init.type == PROG_AST.BOOL_LITERAL)
                        {
                            _value = _init.value;
                        }
                        else if (_init.type == PROG_AST.UNDEFINED_LITERAL)
                        {
                            _value = undefined;
                        }
                    }
                    _descriptor.statics[$ _mem.node.name] = { type: "field", value: _value, access: _mem.access }
                }
                else
                {
                    // Instance field - extract literal value if possible
                    var _value = undefined;
                    if (_mem.node.initializer != undefined)
                    {
                        var _init = _mem.node.initializer;
                        if (_init.type == PROG_AST.NUMBER_LITERAL || _init.type == PROG_AST.STRING_LITERAL)
                        {
                            _value = _init.value;
                        }
                        else if (_init.type == PROG_AST.BOOL_LITERAL)
                        {
                            _value = _init.value;
                        }
                        else if (_init.type == PROG_AST.UNDEFINED_LITERAL)
                        {
                            _value = undefined;
                        }
                    }
                    array_push(_descriptor.fields, { name: _mem.node.name, value: _value, access: _mem.access, is_static: false });
                }
            }
        }
        
        var _index = add_constant(_descriptor);
        
        emit(PROG_OP.CLASS_DEF, _index, _node.line);
        
        if (_node.name != undefined)
        {
            emit(PROG_OP.DEFINE, add_constant(_node.name), _node.line);
        }
    }
    
    static compile_destructuring = function(_pattern)
    {
        var _pattern_type = _pattern.type;
        
        if (_pattern_type == "array")
        {
            var _elements = _pattern.elements;
            var _elements_length = array_length(_elements);
            
            for (var i = 0; i < _elements_length; ++i)
            {
                var _element = _elements[i];
                
                emit(PROG_OP.DUP);
                emit(PROG_OP.PUSH_CONST, add_constant(i));
                emit(PROG_OP.INDEX_GET);
                
                if (is_string(_element))
                {
                    emit(PROG_OP.STORE, add_constant(_element));
                }
                else if (is_struct(_element))
                {
                    compile_destructuring(_element);
                }
                
                emit(PROG_OP.POP);
            }
        } 
        else if (_pattern_type == "object")
        {
            var _elements = _pattern.elements;
            var _elements_length = array_length(_elements);
            
            for (var i = 0; i < _elements_length; ++i)
            {
                var _element = _elements[i];
                
                emit(PROG_OP.DUP);
                emit(PROG_OP.MEMBER_GET, add_constant(_element.key));
                
                var _target = _element.target;
                
                if (is_string(_target))
                {
                    emit(PROG_OP.STORE, add_constant(_target));
                }
                else if (is_struct(_target))
                {
                    compile_destructuring(_target);
                }
                
                emit(PROG_OP.POP);
            }
        }
    }
    
    static compile_assignment = function(_node)
    {
        var _target = _node.target;
        var _target_type = _target.type;
        
        var _line = _node.line;
        var _op = _node.op;
        
        if (_target_type == PROG_AST.IDENTIFIER)
        {
            var _index = add_constant(_target.name);
            
            if (_op != PROG_TOKEN.ASSIGN)
            {
                emit(PROG_OP.LOAD, _index, _line);
                
                compile_node(_node.value);
                
                switch (_op)
                {
                    case PROG_TOKEN.PLUS:
                    case PROG_TOKEN.PLUS_ASSIGN:
                        emit(PROG_OP.ADD);
                        break;
                    
                    case PROG_TOKEN.MINUS:
                    case PROG_TOKEN.MINUS_ASSIGN:
                        emit(PROG_OP.SUB);
                        break;
                    
                    case PROG_TOKEN.STAR:
                    case PROG_TOKEN.STAR_ASSIGN:
                        emit(PROG_OP.MUL);
                        break;
                    
                    case PROG_TOKEN.SLASH:
                    case PROG_TOKEN.SLASH_ASSIGN:
                        emit(PROG_OP.DIV);
                        break;
                    
                    case PROG_TOKEN.PERCENT:
                    case PROG_TOKEN.PERCENT_ASSIGN:
                        emit(PROG_OP.MOD);
                        break;
                    
                    case PROG_TOKEN.POWER:
                    case PROG_TOKEN.POWER_ASSIGN:
                        emit(PROG_OP.POW);
                        break;
                    
                    case PROG_TOKEN.LSHIFT:
                    case PROG_TOKEN.LSHIFT_ASSIGN:
                        emit(PROG_OP.SHL);
                        break;
                    
                    case PROG_TOKEN.RSHIFT:
                    case PROG_TOKEN.RSHIFT_ASSIGN:
                        emit(PROG_OP.SHR);
                        break;
                    
                    case PROG_TOKEN.AMP:
                    case PROG_TOKEN.AMP_ASSIGN:
                        emit(PROG_OP.BIT_AND);
                        break;
                    
                    case PROG_TOKEN.PIPE:
                    case PROG_TOKEN.PIPE_ASSIGN:
                        emit(PROG_OP.BIT_OR);
                        break;
                    
                    case PROG_TOKEN.CARET:
                    case PROG_TOKEN.CARET_ASSIGN:
                        emit(PROG_OP.BIT_XOR);
                        break;
                }
            }
            else
            {
                compile_node(_node.value);
            }
            emit(PROG_OP.STORE, _index, _line);
        }
        else if (_target_type == PROG_AST.MEMBER)
        {
            compile_node(_target.target);
            
            if (_op != PROG_TOKEN.ASSIGN)
            {
                emit(PROG_OP.DUP);
                emit(PROG_OP.MEMBER_GET, add_constant(_target.property), _line);
                
                compile_node(_node.value);
                
                switch (_op)
                {
                    case PROG_TOKEN.PLUS:
                    case PROG_TOKEN.PLUS_ASSIGN:
                        emit(PROG_OP.ADD);
                        break;
                    
                    case PROG_TOKEN.MINUS:
                    case PROG_TOKEN.MINUS_ASSIGN:
                        emit(PROG_OP.SUB);
                        break;
                    
                    case PROG_TOKEN.STAR:
                    case PROG_TOKEN.STAR_ASSIGN:
                        emit(PROG_OP.MUL);
                        break;
                    
                    case PROG_TOKEN.SLASH:
                    case PROG_TOKEN.SLASH_ASSIGN:
                        emit(PROG_OP.DIV);
                        break;
                    
                    case PROG_TOKEN.PERCENT:
                    case PROG_TOKEN.PERCENT_ASSIGN:
                        emit(PROG_OP.MOD);
                        break;
                    
                    case PROG_TOKEN.POWER:
                    case PROG_TOKEN.POWER_ASSIGN:
                        emit(PROG_OP.POW);
                        break;
                    
                    case PROG_TOKEN.LSHIFT:
                    case PROG_TOKEN.LSHIFT_ASSIGN:
                        emit(PROG_OP.SHL);
                        break;
                    
                    case PROG_TOKEN.RSHIFT:
                    case PROG_TOKEN.RSHIFT_ASSIGN:
                        emit(PROG_OP.SHR);
                        break;
                    
                    case PROG_TOKEN.AMP:
                    case PROG_TOKEN.AMP_ASSIGN:
                        emit(PROG_OP.BIT_AND);
                        break;
                    
                    case PROG_TOKEN.PIPE:
                    case PROG_TOKEN.PIPE_ASSIGN:
                        emit(PROG_OP.BIT_OR);
                        break;
                    
                    case PROG_TOKEN.CARET:
                    case PROG_TOKEN.CARET_ASSIGN:
                        emit(PROG_OP.BIT_XOR);
                        break;
                }
            }
            else
            {
                compile_node(_node.value);
            }
            
            emit(PROG_OP.MEMBER_SET, add_constant(_target.property), _line);
        }
        else if (_target_type == PROG_AST.INDEX)
        {
            compile_node(_target.target);
            compile_node(_target.index);
            
            if (_op != PROG_TOKEN.ASSIGN)
            {
                emit(PROG_OP.DUP2);
                emit(PROG_OP.INDEX_GET, undefined, _line);
                
                compile_node(_node.value);
                
                switch (_op)
                {
                    case PROG_TOKEN.PLUS:
                    case PROG_TOKEN.PLUS_ASSIGN:
                        emit(PROG_OP.ADD);
                        break;
                    
                    case PROG_TOKEN.MINUS:
                    case PROG_TOKEN.MINUS_ASSIGN:
                        emit(PROG_OP.SUB);
                        break;
                    
                    case PROG_TOKEN.STAR:
                    case PROG_TOKEN.STAR_ASSIGN:
                        emit(PROG_OP.MUL);
                        break;
                    
                    case PROG_TOKEN.SLASH:
                    case PROG_TOKEN.SLASH_ASSIGN:
                        emit(PROG_OP.DIV);
                        break;
                    
                    case PROG_TOKEN.PERCENT:
                    case PROG_TOKEN.PERCENT_ASSIGN:
                        emit(PROG_OP.MOD);
                        break;
                    
                    case PROG_TOKEN.POWER:
                    case PROG_TOKEN.POWER_ASSIGN:
                        emit(PROG_OP.POW);
                        break;
                    
                    case PROG_TOKEN.LSHIFT:
                    case PROG_TOKEN.LSHIFT_ASSIGN:
                        emit(PROG_OP.SHL);
                        break;
                    
                    case PROG_TOKEN.RSHIFT:
                    case PROG_TOKEN.RSHIFT_ASSIGN:
                        emit(PROG_OP.SHR);
                        break;
                    
                    case PROG_TOKEN.AMP:
                    case PROG_TOKEN.AMP_ASSIGN:
                        emit(PROG_OP.BIT_AND);
                        break;
                    
                    case PROG_TOKEN.PIPE:
                    case PROG_TOKEN.PIPE_ASSIGN:
                        emit(PROG_OP.BIT_OR);
                        break;
                    
                    case PROG_TOKEN.CARET:
                    case PROG_TOKEN.CARET_ASSIGN:
                        emit(PROG_OP.BIT_XOR);
                        break;
                }
            }
            else
            {
                compile_node(_node.value);
            }
            
            emit(PROG_OP.INDEX_SET, undefined, _line);
        }
    }
}
