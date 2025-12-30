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
    JUMP, JUMP_IF_FALSE, JUMP_IF_NULL, JUMP_IF_NOT_NULL, BREAK_N,
    
    // Functions
    CALL, RETURN, CALL_SPREAD, MAKE_CLOSURE,
    
    // Iteration
    ITER_INIT, ITER_NEXT, ITER_GET_VAL,
    
    // Exceptions
    PUSH_TRY, POP_TRY, THROW,
    
    // Spread operations
    PUSH_ARRAY_EMPTY, ARRAY_PUSH, ARRAY_SPREAD,
    
    // Module Ops
    IMPORT, EXPORT_SET,
    
    // Stack Ops Extra
    DUP2, POP_AND_KEEP,
    
    // Optimization Ops
    INC, DEC,
    
    // Class System
    CLASS_DEF, NEW_INSTANCE, LOAD_THIS, LOAD_SUPER, ACCESS_CHECK,
    
    // Scoping
    PUSH_SCOPE, POP_SCOPE,
    
    // Debug
    DEBUG_LINE
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
function ProgCompiler() constructor
{
    bytecode = new ProgBytecode();
    loop_stack = []; // Stack of { start, continue, breaks[] }
    
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
        var _len = array_length(bytecode.constants);
        for (var i = 0; i < _len; i++)
        {
            if (bytecode.constants[i] == _value) return i;
        }
        array_push(bytecode.constants, _value);
        return _len;
    }
    
    // Patch jump address
    static patch_jump = function(_addr, _target)
    {
        bytecode.code[_addr + 1] = _target;
    }
    
    /// @desc Compile AST to bytecode
    static compile = function(_ast)
    {
        if (_ast.type == PROG_AST.BLOCK)
        {
            for (var i = 0; i < array_length(_ast.statements); i++)
            {
                compile_node(_ast.statements[i]);
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
        if (_node.left.type != PROG_AST.NUMBER_LITERAL || _node.right.type != PROG_AST.NUMBER_LITERAL)
        {
            return undefined;
        }
        var _a = _node.left.value;
        var _b = _node.right.value;
        switch (_node.op)
        {
            case PROG_TOKEN.PLUS: return _a + _b;
            case PROG_TOKEN.MINUS: return _a - _b;
            case PROG_TOKEN.STAR: return _a * _b;
            case PROG_TOKEN.SLASH: return _b != 0 ? _a / _b : undefined;
            case PROG_TOKEN.PERCENT: return _b != 0 ? _a % _b : undefined;
            case PROG_TOKEN.POWER: return power(_a, _b);
            default: return undefined;
        }
    }
    
    static compile_func_body = function(_node)
    {
        var _parent = bytecode;
        bytecode = new ProgBytecode();
        
        var _param_names = [];
        for (var i = 0; i < array_length(_node.params); i++)
        {
            var _param = _node.params[i];
            array_push(_param_names, _param.name);
            
            emit(PROG_OP.LOAD, add_constant($"arg{i}"), _node.line);
            
            if (_param.default_value != undefined)
            {
                 emit(PROG_OP.DUP);
                 emit(PROG_OP.PUSH_NULL);
                 emit(PROG_OP.EQ);
                 var _skip = emit(PROG_OP.JUMP_IF_FALSE, 0);
                 emit(PROG_OP.POP);
                 compile_node(_param.default_value);
                 patch_jump(_skip, bytecode.code_size);
            }
            
            emit(PROG_OP.DEFINE, add_constant(_param.name), _node.line);
            emit(PROG_OP.POP);
        }
        
        compile_node(_node.body);
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
        _func_arr[PROG_FUNC.NAME] = variable_struct_exists(_node, "name") ? _node.name : "<anonymous>";
        _func_arr[PROG_FUNC.BYTECODE] = _res.bytecode;
        _func_arr[PROG_FUNC.IS_GLOBAL] = variable_struct_exists(_node, "is_global") ? _node.is_global : false;
        _func_arr[PROG_FUNC.PARAM_COUNT] = _res.param_count;
        
        var _idx = add_constant(_func_arr);
        emit(PROG_OP.PUSH_CONST, _idx, _node.line);
        emit(PROG_OP.MAKE_CLOSURE, undefined, _node.line);
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
                    emit(PROG_OP.PUSH_CONST, add_constant(_folded), _node.line);
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
                    case PROG_TOKEN.PLUS: _opcode = PROG_OP.ADD; break;
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
                emit(PROG_OP.LOAD, add_constant(_node.name), _node.line);
                break;
                
            case PROG_AST.ASSIGNMENT:
                compile_assignment(_node);
                break;
                
            case PROG_AST.VAR_DECL:
                if (_node.initializer != undefined) compile_node(_node.initializer);
                else emit(PROG_OP.PUSH_NULL, undefined, _node.line);
                var _idx = add_constant(_node.name);
                if (struct_exists(_node, "is_global") && _node.is_global)
                {
                    emit(PROG_OP.STORE_GLOBAL, _idx, _node.line);
                }
                else
                {
                    emit(PROG_OP.DEFINE, _idx, _node.line);
                }
                emit(PROG_OP.POP, undefined, _node.line);
                break;
                
            case PROG_AST.BLOCK:
                emit(PROG_OP.PUSH_SCOPE, undefined, _node.line);
                for (var i = 0; i < array_length(_node.statements); i++)
                {
                    compile_node(_node.statements[i]);
                }
                emit(PROG_OP.POP_SCOPE, undefined, _node.line);
                break;
                
            case PROG_AST.FUNC_DECL:
                compile_function_def(_node);
                
                var _name_idx = add_constant(_node.name);
                emit(_node.is_global ? PROG_OP.STORE_GLOBAL : PROG_OP.STORE, _name_idx, _node.line);
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
                var _jmp_else = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                compile_node(_node.then_branch);
                var _jmp_end = emit(PROG_OP.JUMP, 0, _node.line);
                patch_jump(_jmp_else, bytecode.code_size);
                if (_node.else_branch != undefined) compile_node(_node.else_branch);
                patch_jump(_jmp_end, bytecode.code_size);
                break;
                
            case PROG_AST.WHILE_STMT:
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
                var _rep_var = "@rep_" + string(bytecode.code_size);
                var _idx = add_constant(_rep_var);
                compile_node(_node.count);
                emit(PROG_OP.STORE, _idx, _node.line);
                emit(PROG_OP.POP);
                
                var _start = bytecode.code_size;
                emit(PROG_OP.LOAD, _idx, _node.line);
                emit(PROG_OP.PUSH_CONST, add_constant(0));
                emit(PROG_OP.GT);
                var _exit = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                
                array_push(loop_stack, { start: _start, continue_addr: _start, breaks: [] });
                
                compile_node(_node.body);
                
                emit(PROG_OP.LOAD, _idx);
                emit(PROG_OP.PUSH_CONST, add_constant(1));
                emit(PROG_OP.SUB);
                emit(PROG_OP.STORE, _idx);
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
                if (_node.initializer)
                {
                    if (_node.initializer.type == PROG_AST.VAR_DECL) compile_node(_node.initializer);
                    else { compile_node(_node.initializer); emit(PROG_OP.POP); }
                }
                var _start = bytecode.code_size;
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
                
                if (_node.increment) { compile_node(_node.increment); emit(PROG_OP.POP); }
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
                    var _target_idx = array_length(loop_stack) - _amount;
                    var _ctx = loop_stack[_target_idx];
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
                    var _idx = add_constant(_node.target.name);
                    emit(PROG_OP.LOAD, _idx, _node.line);
                    emit(_node.op == PROG_TOKEN.PLUS_PLUS ? PROG_OP.INC : PROG_OP.DEC);
                    emit(PROG_OP.STORE, _idx, _node.line);
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
                    var _idx = add_constant(_node.target.name);
                    emit(PROG_OP.LOAD, _idx, _node.line);
                    emit(PROG_OP.DUP);
                    emit(_node.op == PROG_TOKEN.PLUS_PLUS ? PROG_OP.INC : PROG_OP.DEC);
                    emit(PROG_OP.STORE, _idx, _node.line);
                    emit(PROG_OP.POP);
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
                    var _def_jmp_idx = array_length(_node.cases);
                    patch_jump(_case_jumps[_def_jmp_idx], bytecode.code_size);
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
                var _has_spread = false;
                for (var i = 0; i < array_length(_node.args); i++)
                {
                    if (_node.args[i].type == PROG_AST.UNARY_OP && _node.args[i].op == PROG_TOKEN.SPREAD)
                    {
                        _has_spread = true; break;
                    }
                }
                if (_has_spread)
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
                compile_node(_node.target);
                compile_node(_node.index);
                emit(PROG_OP.INDEX_GET, undefined, _node.line);
                break;
                
            case PROG_AST.RETURN_STMT:
                if (_node.value) compile_node(_node.value);
                else emit(PROG_OP.PUSH_NULL);
                emit(PROG_OP.RETURN, undefined, _node.line);
                break;
                
            case PROG_AST.FOR_IN_STMT:
                compile_node(_node.collection);
                emit(PROG_OP.ITER_INIT, undefined, _node.line);
                var _start = bytecode.code_size;
                emit(PROG_OP.ITER_NEXT, undefined, _node.line);
                var _exit = emit(PROG_OP.JUMP_IF_FALSE, 0, _node.line);
                
                // Stack: Iter, Key
                emit(PROG_OP.DEFINE, add_constant(_node.variable), _node.line); // Define Key
                emit(PROG_OP.POP); // Consume Key
                
                // If value variable requested:
                if (struct_exists(_node, "value_var") && _node.value_var != undefined)
                {
                     emit(PROG_OP.ITER_GET_VAL, undefined, _node.line); // Pushes Value using Iterator
                     emit(PROG_OP.DEFINE, add_constant(_node.value_var), _node.line); // Define Value
                     emit(PROG_OP.POP); // Consume Value
                }
                
                compile_node(_node.body);
                emit(PROG_OP.JUMP, _start, _node.line);
                patch_jump(_exit, bytecode.code_size);
                emit(PROG_OP.POP);
                break;
                
            case PROG_AST.TRY_STMT:
                var _catch_jmp = emit(PROG_OP.PUSH_TRY, 0, _node.line);
                compile_node(_node.try_block);
                emit(PROG_OP.POP_TRY, undefined, _node.line);
                var _end_jmp = emit(PROG_OP.JUMP, 0, _node.line);
                patch_jump(_catch_jmp, bytecode.code_size);
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
                emit(PROG_OP.IMPORT, add_constant(_node.module_path), _node.line);
                // Stack: ExportsStruct
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
        
        var _idx = add_constant(_descriptor);
        emit(PROG_OP.CLASS_DEF, _idx, _node.line);
    }
    
    static compile_destructuring = function(_pattern)
    {
        if (_pattern.type == "array")
        {
            for (var i = 0; i < array_length(_pattern.elements); i++)
            {
                var _el = _pattern.elements[i];
                emit(PROG_OP.DUP);
                emit(PROG_OP.PUSH_CONST, add_constant(i));
                emit(PROG_OP.INDEX_GET); // Stack: [..., Arr, Val]
                
                if (is_string(_el))
                {
                    emit(PROG_OP.STORE, add_constant(_el));
                }
                else if (is_struct(_el))
                {
                    // Nested pattern
                    compile_destructuring(_el);
                }
                
                emit(PROG_OP.POP); // Consume Val
            }
        } 
        else if (_pattern.type == "object")
        {
            for (var i = 0; i < array_length(_pattern.elements); i++)
            {
                var _el = _pattern.elements[i];
                emit(PROG_OP.DUP);
                emit(PROG_OP.MEMBER_GET, add_constant(_el.key)); // Stack: [..., Obj, Val]
                
                if (is_string(_el.target))
                {
                    emit(PROG_OP.STORE, add_constant(_el.target));
                }
                else if (is_struct(_el.target))
                {
                    // Nested pattern (target is the pattern struct)
                    compile_destructuring(_el.target);
                }
                
                emit(PROG_OP.POP); // Consume Val
            }
        }
    }
    
    static compile_assignment = function(_node)
    {
        var _target = _node.target;
        var _line = _node.line;
        var _op = _node.op;
        
        if (_target.type == PROG_AST.IDENTIFIER)
        {
            var _idx = add_constant(_target.name);
            if (_op != PROG_TOKEN.ASSIGN)
            {
                emit(PROG_OP.LOAD, _idx, _line);
                compile_node(_node.value);
                switch (_op)
                {
                    case PROG_TOKEN.PLUS: case PROG_TOKEN.PLUS_ASSIGN: emit(PROG_OP.ADD); break;
                    case PROG_TOKEN.MINUS: case PROG_TOKEN.MINUS_ASSIGN: emit(PROG_OP.SUB); break;
                    case PROG_TOKEN.STAR: case PROG_TOKEN.STAR_ASSIGN: emit(PROG_OP.MUL); break;
                    case PROG_TOKEN.SLASH: case PROG_TOKEN.SLASH_ASSIGN: emit(PROG_OP.DIV); break;
                    case PROG_TOKEN.PERCENT: case PROG_TOKEN.PERCENT_ASSIGN: emit(PROG_OP.MOD); break;
                    case PROG_TOKEN.POWER: case PROG_TOKEN.POWER_ASSIGN: emit(PROG_OP.POW); break;
                    case PROG_TOKEN.LSHIFT: case PROG_TOKEN.LSHIFT_ASSIGN: emit(PROG_OP.SHL); break;
                    case PROG_TOKEN.RSHIFT: case PROG_TOKEN.RSHIFT_ASSIGN: emit(PROG_OP.SHR); break;
                    case PROG_TOKEN.AMP: case PROG_TOKEN.AMP_ASSIGN: emit(PROG_OP.BIT_AND); break;
                    case PROG_TOKEN.PIPE: case PROG_TOKEN.PIPE_ASSIGN: emit(PROG_OP.BIT_OR); break;
                    case PROG_TOKEN.CARET: case PROG_TOKEN.CARET_ASSIGN: emit(PROG_OP.BIT_XOR); break;
                }
            }
            else
            {
                compile_node(_node.value);
            }
            emit(PROG_OP.STORE, _idx, _line);
        }
        else if (_target.type == PROG_AST.MEMBER)
        {
            compile_node(_target.target); // Push Obj
            if (_op != PROG_TOKEN.ASSIGN)
            {
                emit(PROG_OP.DUP); // Obj, Obj
                emit(PROG_OP.MEMBER_GET, add_constant(_target.property), _line); // Obj, Val
                compile_node(_node.value); // Obj, Val, RHS
                switch (_op)
                {
                    case PROG_TOKEN.PLUS: case PROG_TOKEN.PLUS_ASSIGN: emit(PROG_OP.ADD); break;
                    case PROG_TOKEN.MINUS: case PROG_TOKEN.MINUS_ASSIGN: emit(PROG_OP.SUB); break;
                    case PROG_TOKEN.STAR: case PROG_TOKEN.STAR_ASSIGN: emit(PROG_OP.MUL); break;
                    case PROG_TOKEN.SLASH: case PROG_TOKEN.SLASH_ASSIGN: emit(PROG_OP.DIV); break;
                    case PROG_TOKEN.PERCENT: case PROG_TOKEN.PERCENT_ASSIGN: emit(PROG_OP.MOD); break;
                    case PROG_TOKEN.POWER: case PROG_TOKEN.POWER_ASSIGN: emit(PROG_OP.POW); break;
                    case PROG_TOKEN.LSHIFT: case PROG_TOKEN.LSHIFT_ASSIGN: emit(PROG_OP.SHL); break;
                    case PROG_TOKEN.RSHIFT: case PROG_TOKEN.RSHIFT_ASSIGN: emit(PROG_OP.SHR); break;
                    case PROG_TOKEN.AMP: case PROG_TOKEN.AMP_ASSIGN: emit(PROG_OP.BIT_AND); break;
                    case PROG_TOKEN.PIPE: case PROG_TOKEN.PIPE_ASSIGN: emit(PROG_OP.BIT_OR); break;
                    case PROG_TOKEN.CARET: case PROG_TOKEN.CARET_ASSIGN: emit(PROG_OP.BIT_XOR); break;
                }
                // Stack: Obj, NewVal
            }
            else
            {
                compile_node(_node.value); // Obj, NewVal
            }
            emit(PROG_OP.MEMBER_SET, add_constant(_target.property), _line);
        }
        else if (_target.type == PROG_AST.INDEX)
        {
            compile_node(_target.target); // Arr
            compile_node(_target.index); // Arr, Idx
            if (_op != PROG_TOKEN.ASSIGN)
            {
                emit(PROG_OP.DUP2); // Arr, Idx, Arr, Idx
                emit(PROG_OP.INDEX_GET, undefined, _line); // Arr, Idx, Val
                compile_node(_node.value); // Arr, Idx, Val, RHS
                switch (_op)
                {
                    case PROG_TOKEN.PLUS: case PROG_TOKEN.PLUS_ASSIGN: emit(PROG_OP.ADD); break;
                    case PROG_TOKEN.MINUS: case PROG_TOKEN.MINUS_ASSIGN: emit(PROG_OP.SUB); break;
                    case PROG_TOKEN.STAR: case PROG_TOKEN.STAR_ASSIGN: emit(PROG_OP.MUL); break;
                    case PROG_TOKEN.SLASH: case PROG_TOKEN.SLASH_ASSIGN: emit(PROG_OP.DIV); break;
                    case PROG_TOKEN.PERCENT: case PROG_TOKEN.PERCENT_ASSIGN: emit(PROG_OP.MOD); break;
                    case PROG_TOKEN.POWER: case PROG_TOKEN.POWER_ASSIGN: emit(PROG_OP.POW); break;
                    case PROG_TOKEN.LSHIFT: case PROG_TOKEN.LSHIFT_ASSIGN: emit(PROG_OP.SHL); break;
                    case PROG_TOKEN.RSHIFT: case PROG_TOKEN.RSHIFT_ASSIGN: emit(PROG_OP.SHR); break;
                    case PROG_TOKEN.AMP: case PROG_TOKEN.AMP_ASSIGN: emit(PROG_OP.BIT_AND); break;
                    case PROG_TOKEN.PIPE: case PROG_TOKEN.PIPE_ASSIGN: emit(PROG_OP.BIT_OR); break;
                    case PROG_TOKEN.CARET: case PROG_TOKEN.CARET_ASSIGN: emit(PROG_OP.BIT_XOR); break;
                }
                // Stack: Arr, Idx, NewVal
            }
            else
            {
                compile_node(_node.value); // Arr, Idx, NewVal
            }
            emit(PROG_OP.INDEX_SET, undefined, _line);
        }
    }
}
