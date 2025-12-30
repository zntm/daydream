/// @desc Virtual Machine for Proglang bytecode execution

enum PROGLANG_ERROR_TYPE
{
    RUNTIME,
    TYPE,
    INDEX,
    MEMBER,
    VARIABLE,
    DIVIDE_BY_ZERO,
    UNDEFINED_VALUE,
    NULL_REFERENCE,
    INVALID_ARGUMENT,
    NOT_CALLABLE,
    SYNTAX,
    IMPORT,
    // Stack errors
    STACK_OVERFLOW,
    STACK_UNDERFLOW,
    // Execution limits
    RECURSION_LIMIT,
    INFINITE_LOOP,
    // Access control
    ACCESS_DENIED,
    ABSTRACT_METHOD,
    // File/path errors
    FILE_NOT_FOUND,
    PATH_SECURITY,
    // Function errors
    ARITY_MISMATCH,
    SUPER_ERROR
}

// ========== ARRAY-BASED VM STRUCTURE ==========

enum PROG_VM {
    STACK,          // Array
    SP,             // Real (Stack Pointer)
    IP,             // Real (Instruction Pointer)
    SCOPE,          // Array [PROG_SCOPE]
    CONTEXT,        // Struct (External context)
    GLOBAL_REF,     // Struct (Global scope)
    TRY_STACK,      // Array
    ACTIVE_MODULE,  // Struct (Module info)
    CALL_STACK,     // Array
    CURRENT_THIS,   // Any
    ACTIVE_CLASS,   // Struct
    CLASS_REGISTRY, // Struct
    SIZE            // Total size
}

enum PROG_SCOPE {
    VARS,           // Struct (The actual variables map)
    PARENT,         // Array [PROG_SCOPE] or undefined
    SIZE
}

enum PROG_FRAME {
    NAME,           // String
    LINE,           // Real
    SIZE
}

// ========== CORE VM FUNCTIONS ==========

/// @desc Reset VM state for reuse
/// @param {Array<PROG_VM>} _vm The VM array
function ProgVM_reset(_vm)
{
    _vm[@ PROG_VM.SP] = 0;
    _vm[@ PROG_VM.IP] = 0;
    
    // Create new root scope
    var _scope = array_create(PROG_SCOPE.SIZE);
    _scope[PROG_SCOPE.VARS] = {};
    _scope[PROG_SCOPE.PARENT] = undefined;
    
    _vm[@ PROG_VM.SCOPE] = _scope;
    _vm[@ PROG_VM.CONTEXT] = undefined;
    _vm[@ PROG_VM.GLOBAL_REF] = {};
    _vm[@ PROG_VM.TRY_STACK] = [];
    _vm[@ PROG_VM.CALL_STACK] = [];
    _vm[@ PROG_VM.CURRENT_THIS] = undefined;
    _vm[@ PROG_VM.ACTIVE_CLASS] = undefined;
    _vm[@ PROG_VM.ACTIVE_MODULE] = undefined;
    // Note: stack array is reused, sp reset handles it
}

/// @desc Find variable in scope chain
/// @param {Array<PROG_VM>} _vm
/// @param {string} _name
function ProgVM_find_var_scope(_vm, _name)
{
    var _s = _vm[PROG_VM.SCOPE];
    
    while (_s != undefined)
    {
        if (struct_exists(_s[PROG_SCOPE.VARS], _name))
        {
            return _s;
        }
        
        _s = _s[PROG_SCOPE.PARENT];
    }
    
    return undefined;
}

/// @desc Call a function/script/closure
/// @param {Array<PROG_VM>} _vm
/// @param {any} _callee
/// @param {array} _args
/// @param {real} _line
/// @param {string} _callee_name
function ProgVM_exec_call(_vm, _callee, _args, _line = 0, _callee_name = "<anonymous>")
{
    // Push call stack frame
    var _frame = array_create(PROG_FRAME.SIZE);
    _frame[PROG_FRAME.NAME] = _callee_name;
    _frame[PROG_FRAME.LINE] = _line;
    array_push(_vm[PROG_VM.CALL_STACK], _frame);
    
    try
    {
        // Super Constructor Call via super(...)
        if (is_struct(_callee)) && (struct_exists(_callee, "__super__"))
        {
            var _super_class = _callee.__super__;
            var _receiver = _callee.receiver;
            
            // Look for constructor in super class
            if (_super_class[$ "constructor_code"] != undefined)
            {
                var _new_vm = ProgVM_create();
                _new_vm[@ PROG_VM.GLOBAL_REF] = _vm[PROG_VM.GLOBAL_REF]; // Share global scope
                
                _new_vm[@ PROG_VM.CONTEXT] = _vm[PROG_VM.CONTEXT];
                _new_vm[@ PROG_VM.CALL_STACK] = variable_clone(_vm[PROG_VM.CALL_STACK]);
                _new_vm[@ PROG_VM.CURRENT_THIS] = _receiver;
                
                var _vars = _new_vm[PROG_VM.SCOPE][PROG_SCOPE.VARS];
                for (var j = 0; j < array_length(_args); j++)
                {
                    _vars[$ $"arg{j}"] = _args[j];
                }
                _vars[$ "argc"] = array_length(_args);
                
                var _res = ProgVM_run(_new_vm, _super_class.constructor_code);
                
                ProgVM_free(_new_vm);
                array_pop(_vm[PROG_VM.CALL_STACK]);
                
                return _res;
            }
            else
            {
                // No constructor in super, just return (default constructor)
                array_pop(_vm[PROG_VM.CALL_STACK]);
                return undefined;
            }
        }
        
        // Function struct (closure or built-in wrapper)
        // Handle Array-based Closure (PROG_CLOSURE enum)
        if (is_array(_callee)) && (array_length(_callee) >= PROG_CLOSURE.SIZE) && (_callee[PROG_CLOSURE.TYPE] == "closure")
        {
            var _new_vm = ProgVM_create();
            // Use captured global_ref if available
            _new_vm[@ PROG_VM.GLOBAL_REF] = (_callee[PROG_CLOSURE.GLOBAL_REF] != undefined) ? _callee[PROG_CLOSURE.GLOBAL_REF] : _vm[PROG_VM.GLOBAL_REF];
            
            _new_vm[@ PROG_VM.CONTEXT] = _vm[PROG_VM.CONTEXT];
            // Closure scope chain
            _new_vm[PROG_VM.SCOPE][@ PROG_SCOPE.PARENT] = _callee[PROG_CLOSURE.ENV];
            
            // Set defining class for super calls
            if (_callee[PROG_CLOSURE.DEFINING_CLASS] != undefined)
            {
                _new_vm[@ PROG_VM.ACTIVE_CLASS] = _callee[PROG_CLOSURE.DEFINING_CLASS];
            }
            
            // Copy call stack for debugging
            _new_vm[@ PROG_VM.CALL_STACK] = variable_clone(_vm[PROG_VM.CALL_STACK]); 
            
            // Set 'this' context if bound
            if (_callee[PROG_CLOSURE.RECEIVER] != undefined)
            {
                _new_vm[@ PROG_VM.CURRENT_THIS] = _callee[PROG_CLOSURE.RECEIVER];
            }
            
            var _vars = _new_vm[PROG_VM.SCOPE][PROG_SCOPE.VARS];
            for (var j = 0; j < array_length(_args); j++)
            {
                _vars[$ $"arg{j}"] = _args[j];
            }
            _vars[$ "argc"] = array_length(_args);
            
            // Propagate __filename and __dirname from parent scope for import resolution
            var _env = _callee[PROG_CLOSURE.ENV];
            while (_env != undefined)
            {
                if (struct_exists(_env[PROG_SCOPE.VARS], "__filename"))
                {
                    _vars[$ "__filename"] = _env[PROG_SCOPE.VARS][$ "__filename"];
                    _vars[$ "__dirname"] = _env[PROG_SCOPE.VARS][$ "__dirname"];
                    break;
                }
                _env = _env[PROG_SCOPE.PARENT];
            }
            
            var _res = ProgVM_run(_new_vm, _callee[PROG_CLOSURE.BYTECODE]);
            
            ProgVM_free(_new_vm);
            array_pop(_vm[PROG_VM.CALL_STACK]);
            
            return _res;
        }
        
        // Built-in function
        if (is_struct(_callee)) && (struct_exists(_callee, "function"))
        {
            var _res = _callee[$ "function"](_args, _vm); // Pass VM array as self/context if needed
            array_pop(_vm[PROG_VM.CALL_STACK]);
            return _res;
        }
    
        // GML Method / Script
        if (is_method(_callee))
        {
            var _res = method_call(_callee, _args);
            array_pop(_vm[PROG_VM.CALL_STACK]);
            return _res;
        }
    
        // String name lookup
        if (is_string(_callee))
        {
            var _f = global.proglang_functions[$ _callee];
            
            if (_f != undefined)
            {
                var _res = _f[$ "function"](_args, _vm);
                array_pop(_vm[PROG_VM.CALL_STACK]);
                return _res;
            }
            
            var _script = global.proglang_scripts[$ _callee];
            
            if (_script != undefined)
            {
                var _bc = undefined;
                // Handle array-based module
                if (is_array(_script)) && (array_length(_script) >= PROG_MODULE.SIZE)
                {
                    _bc = _script[PROG_MODULE.MAIN];
                }
                else
                {
                    _bc = _script;
                }
                
                var _new_vm = ProgVM_create();
                
                _new_vm[@ PROG_VM.CONTEXT] = _vm[PROG_VM.CONTEXT];
                _new_vm[@ PROG_VM.CALL_STACK] = variable_clone(_vm[PROG_VM.CALL_STACK]);
                
                var _vars = _new_vm[PROG_VM.SCOPE][PROG_SCOPE.VARS];
                for (var j = 0; j < array_length(_args); j++)
                {
                    _vars[$ $"arg{j}"] = _args[j];
                }
                
                _vars[$ "argc"] = array_length(_args);
                
                var _res = ProgVM_run(_new_vm, _bc);
                
                ProgVM_free(_new_vm);
                array_pop(_vm[PROG_VM.CALL_STACK]);
                
                return _res;
            }
            
            // Context value
            if (_vm[PROG_VM.CONTEXT] != undefined)
            {
                var _ = _vm[PROG_VM.CONTEXT][$ _callee];
                
                if (_ != undefined)
                {
                    var _res = ProgVM_exec_call(_vm, _, _args, _line, _callee);
                    array_pop(_vm[PROG_VM.CALL_STACK]);
                    return _res;
                }
            }
            
            var _asset = asset_get_index(_callee);
            
            if (_asset != -1) && (asset_get_type(_callee) == asset_script)
            {
                var _res = script_execute_ext(_asset, _args);
                array_pop(_vm[PROG_VM.CALL_STACK]);
                return _res;
            }
        }
        
    }
    catch (_e)
    {
        array_pop(_vm[PROG_VM.CALL_STACK]);
        throw _e;
    }
    
    array_pop(_vm[PROG_VM.CALL_STACK]);
    return undefined;
}

/// @desc Execute bytecode
/// @param {Array<PROG_VM>} _vm The VM array
/// @param {struct} _bytecode Compiled bytecode object
/// @returns {any} Execution result
function ProgVM_run(_vm, _bytecode)
{
    var _code = _bytecode.code;
    var _constants = _bytecode.constants;
    var _len = array_length(_code);
    
    // Reset VM runtime state
    _vm[@ PROG_VM.SP] = 0;
    _vm[@ PROG_VM.IP] = 0;
    _vm[@ PROG_VM.TRY_STACK] = [];
    
    var _ip = 0; // Local IP for speed
    var _sp = 0; // Local SP for speed
    
    // Local cache for hot-path optimization
    var _stack = _vm[PROG_VM.STACK];
    var _gref = _vm[PROG_VM.GLOBAL_REF];
    
    // LIFTED VARIABLES for switch simplification
    var _a, _b, _val, _idx, _name, _arr, _obj, _prop;
    
    var _steps = 0;
    var _max_steps = 200000;
    
    while (_ip < _len)
    {
        try
        {
            while (_ip < _len)
            {
                if (++_steps > _max_steps)
                {
                    show_debug_message("[ProgVM] Infinite loop protection triggered");
                    return undefined;
                }
                
                var _op = _code[_ip++];
                var _arg = _code[_ip++];
                
                switch (_op)
                {
                    // Stack operations
                    case PROG_OP.PUSH_NULL: _stack[@ _sp++] = undefined; break;
                    case PROG_OP.PUSH_TRUE: _stack[@ _sp++] = true; break;
                    case PROG_OP.PUSH_FALSE: _stack[@ _sp++] = false; break;
                    case PROG_OP.PUSH_GLOBAL_REF: _stack[@ _sp++] = _gref; break;
                    case PROG_OP.PUSH_CONST: _stack[@ _sp++] = _constants[_arg]; break;
                    case PROG_OP.POP:
                        if (_sp > 0) _sp--;
                        else show_debug_message($"[ProgVM CRITICAL] STACK UNDERFLOW at IP {_ip}");
                        break;
                        
                    case PROG_OP.DUP:
                        _stack[@ _sp] = _stack[_sp - 1];
                        _sp++;
                        break;
                    case PROG_OP.DUP2:
                        var _a = _stack[_sp - 1];
                        var _b = _stack[_sp - 2];
                        _stack[@ _sp++] = _b;
                        _stack[@ _sp++] = _a;
                        break;
                    
                    case PROG_OP.POP_AND_KEEP:
                        var _a = _stack[--_sp];
                        _stack[@ _sp - 1] = _a;
                        break;
                    
                    // Optimization Ops
                    case PROG_OP.INC: ++_stack[@ _sp - 1]; break;
                    case PROG_OP.DEC: --_stack[@ _sp - 1]; break;
                    
                    // Arithmetic
                    case PROG_OP.ADD:
                        _b = _stack[--_sp]; 
                        _a = _stack[_sp - 1];
                        
                        if (is_real(_a)) && (is_real(_b))
                        {
                            _stack[@ _sp - 1] = _a + _b;
                        }
                        else if (is_string(_a)) || (is_string(_b))
                        {
                            var _sa = ((is_bool(_a)) ? ((_a) ? "true" : "false") : string(_a));
                            var _sb = ((is_bool(_b)) ? ((_b) ? "true" : "false") : string(_b));
                            _stack[@ _sp - 1] = _sa + _sb;
                        }
                        else if (is_undefined(_a)) || (is_undefined(_b))
                        {
                            runtime_error(PROGLANG_ERROR_TYPE.UNDEFINED_VALUE, "Undefined value in addition.");
                        }
                        else
                        {
                            _stack[@ _sp - 1] = _a + _b; 
                        }
                        break; 
                    
                    case PROG_OP.SUB: _b = _stack[--_sp]; _stack[@ _sp - 1] -= _b; break;
                    case PROG_OP.MUL: _b = _stack[--_sp]; _stack[@ _sp - 1] *= _b; break;
                    case PROG_OP.DIV: _b = _stack[--_sp]; _stack[@ _sp - 1] /= _b; break;
                    case PROG_OP.MOD: _b = _stack[--_sp]; _stack[@ _sp - 1] %= _b; break;
                    case PROG_OP.POW: _b = _stack[--_sp]; _stack[@ _sp - 1] = power(_stack[_sp - 1], _b); break;
                    case PROG_OP.NEG: _stack[@ _sp - 1] = -_stack[_sp - 1]; break;
                    
                    // Comparison
                    case PROG_OP.EQ: _b = _stack[--_sp]; _stack[@ _sp - 1] = (_stack[_sp - 1] == _b); break;
                    case PROG_OP.NE: _b = _stack[--_sp]; _stack[@ _sp - 1] = (_stack[_sp - 1] != _b); break;
                    case PROG_OP.LT: _b = _stack[--_sp]; _stack[@ _sp - 1] = (_stack[_sp - 1] < _b); break;
                    case PROG_OP.GT: _b = _stack[--_sp]; _stack[@ _sp - 1] = (_stack[_sp - 1] > _b); break;
                    case PROG_OP.LE: _b = _stack[--_sp]; _stack[@ _sp - 1] = (_stack[_sp - 1] <= _b); break;
                    case PROG_OP.GE: _b = _stack[--_sp]; _stack[@ _sp - 1] = (_stack[_sp - 1] >= _b); break;
                    
                    // Logical / Bitwise
                    case PROG_OP.NOT: _stack[@ _sp - 1] = !_stack[_sp - 1]; break;
                    case PROG_OP.AND: _b = _stack[--_sp]; _stack[_sp - 1] = (_stack[_sp - 1] && _b); break;
                    case PROG_OP.OR:  _b = _stack[--_sp]; _stack[_sp - 1] = (_stack[_sp - 1] || _b); break;
                    case PROG_OP.BIT_AND: _b = _stack[--_sp]; _stack[@ _sp - 1] = floor(_stack[_sp - 1]) & floor(_b); break;
                    case PROG_OP.BIT_OR:  _b = _stack[--_sp]; _stack[@ _sp - 1] = floor(_stack[_sp - 1]) | floor(_b); break;
                    case PROG_OP.BIT_XOR: _b = _stack[--_sp]; _stack[@ _sp - 1] = floor(_stack[_sp - 1]) ^ floor(_b); break;
                    case PROG_OP.BIT_NOT: _stack[_sp - 1] = ~floor(_stack[_sp - 1]); break;
                    case PROG_OP.SHL: _b = _stack[--_sp]; _stack[@ _sp - 1] = floor(_stack[_sp - 1]) << floor(_b); break;
                    case PROG_OP.SHR: _b = _stack[--_sp]; _stack[@ _sp - 1] = floor(_stack[_sp - 1]) >> floor(_b); break;
                    
                    // Variable Access
                    case PROG_OP.LOAD:
                        _name = _constants[_arg];
                        var _s = ProgVM_find_var_scope(_vm, _name);
                        
                        if (_s != undefined)
                        {
                            _val = _s[PROG_SCOPE.VARS][$ _name];
                            _stack[@ _sp++] = _val; 
                        }
                        else if (_vm[PROG_VM.CONTEXT] != undefined && struct_exists(_vm[PROG_VM.CONTEXT], _name))
                        {
                            _val = _vm[PROG_VM.CONTEXT][$ _name];
                            _stack[@ _sp++] = is_method(_val) ? method_call(_val, []) : _val;
                        }
                        else if (variable_global_exists("proglang_macros") && struct_exists(global.proglang_macros, _name))
                        {
                            _val = global.proglang_macros[$ _name];
                            _stack[@ _sp++] = is_method(_val) ? method_call(_val, []) : _val;
                        }
                        else if (struct_exists(_gref, _name))
                        {
                            _stack[@ _sp++] = _gref[$ _name];
                        }
                        else if (variable_global_exists("proglang_exports") && struct_exists(global.proglang_exports, _name))
                        {
                            _stack[@ _sp++] = global.proglang_exports[$ _name];
                        }
                        else if (variable_global_exists("proglang_scripts") && struct_exists(global.proglang_scripts, _name))
                        {
                            _stack[@ _sp++] = global.proglang_scripts[$ _name];
                        }
                        else if (variable_global_exists("proglang_functions") && struct_exists(global.proglang_functions, _name))
                        {
                            _stack[@ _sp++] = global.proglang_functions[$ _name];
                        }
                        else if (_name == "global") { _stack[@ _sp++] = global; }
                        else if (struct_exists(global, _name)) { _stack[@ _sp++] = global[$ _name]; }
                        else if (variable_global_exists(_name)) { _stack[@ _sp++] = variable_global_get(_name); }
                        else
                        { 
                            // Relax strictness for "argN"
                            if (string_pos("arg", _name) == 1 && string_digits(_name) == string_delete(_name, 1, 3))
                            {
                                _stack[@ _sp++] = undefined;
                            }
                            else
                            {
                                runtime_error(PROGLANG_ERROR_TYPE.VARIABLE, $"Variable '{_name}' not found.");
                            }
                        }
                        break;
                    
                    case PROG_OP.STORE:
                        _val = _stack[_sp - 1]; // Peek
                        _name = _constants[_arg];
                        var _s_store = ProgVM_find_var_scope(_vm, _name);
                        if (_s_store != undefined) { _s_store[PROG_SCOPE.VARS][$ _name] = _val; }
                        else if (_vm[PROG_VM.CONTEXT] != undefined && struct_exists(_vm[PROG_VM.CONTEXT], _name)) { _vm[PROG_VM.CONTEXT][$ _name] = _val; }
                        else if (struct_exists(_gref, _name)) { _gref[$ _name] = _val; }
                        else { _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ _name] = _val; }
                        break;
                        
                    case PROG_OP.DEFINE:
                        _val = _stack[_sp - 1]; // Peek
                        _name = _constants[_arg];
                        _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ _name] = _val;
                        break;
                    
                    case PROG_OP.LOAD_GLOBAL: _stack[@ _sp++] = _gref[$ _constants[_arg]]; break;
                    case PROG_OP.STORE_GLOBAL: _gref[$ _constants[_arg]] = _stack[_sp - 1]; break;
                    
                    case PROG_OP.PUSH_SCOPE:
                        // Array-based scope
                        var _new_scope = array_create(PROG_SCOPE.SIZE);
                        _new_scope[PROG_SCOPE.VARS] = {};
                        _new_scope[PROG_SCOPE.PARENT] = _vm[PROG_VM.SCOPE];
                        _vm[@ PROG_VM.SCOPE] = _new_scope;
                        break;
                        
                    case PROG_OP.POP_SCOPE:
                        var _parent = _vm[PROG_VM.SCOPE][PROG_SCOPE.PARENT];
                        if (_parent != undefined)
                        {
                            _vm[@ PROG_VM.SCOPE] = _parent;
                        }
                        else
                        {
                            runtime_error(PROGLANG_ERROR_TYPE.RUNTIME, "Scope underflow");
                        }
                        break;
                    
                    case PROG_OP.MAKE_CLOSURE:
                        var _func = _stack[--_sp];
                        
                        // Check for array format (PROG_FUNC)
                        if (is_array(_func) && array_length(_func) >= PROG_FUNC.SIZE)
                        {
                            var _closure_arr = array_create(PROG_CLOSURE.SIZE);
                            _closure_arr[PROG_CLOSURE.TYPE] = "closure";
                            _closure_arr[PROG_CLOSURE.BYTECODE] = _func[PROG_FUNC.BYTECODE];
                            _closure_arr[PROG_CLOSURE.ENV] = _vm[PROG_VM.SCOPE];
                            _closure_arr[PROG_CLOSURE.NAME] = _func[PROG_FUNC.NAME];
                            _closure_arr[PROG_CLOSURE.PARAM_COUNT] = _func[PROG_FUNC.PARAM_COUNT];
                            _closure_arr[PROG_CLOSURE.GLOBAL_REF] = _gref;
                            _stack[@ _sp++] = _closure_arr;
                        }
                        // Legacy support removed/simplified
                        else
                        {
                            runtime_error(PROGLANG_ERROR_TYPE.TYPE, "MAKE_CLOSURE expects a function constant");
                        }
                        break;
                    
                    // Structure Access
                    case PROG_OP.INDEX_GET:
                        _idx = _stack[--_sp];
                        _arr = _stack[--_sp];
                        _val = is_array(_arr) ? _arr[_idx] : (is_struct(_arr) ? _arr[$ _idx] : undefined);
                        _stack[@ _sp++] = _val;
                        break;
                    
                    case PROG_OP.INDEX_SET:
                        _val = _stack[--_sp];
                        _idx = _stack[--_sp];
                        _arr = _stack[--_sp];
                        if (is_array(_arr)) _arr[@ _idx] = _val;
                        else if (is_struct(_arr)) _arr[$ _idx] = _val;
                        _stack[@ _sp++] = _val;
                        break;
                    
                    case PROG_OP.MEMBER_GET:
                        _prop = _constants[_arg];
                        _obj = _stack[--_sp];
                        _val = undefined;
                        
                        // Super lookup
                        if (is_struct(_obj) && struct_exists(_obj, "__super__"))
                        {
                            var _super_class = _obj.__super__;
                            var _receiver = _obj.receiver;
                            var _curr = _super_class;
                            var _found = false;
                            while (_curr != undefined)
                            {
                                if (struct_exists(_curr.methods, _prop))
                                {
                                    var _method_entry = _curr.methods[$ _prop];
                                    _val = array_create(PROG_CLOSURE.SIZE);
                                    _val[PROG_CLOSURE.TYPE] = "closure";
                                    _val[PROG_CLOSURE.BYTECODE] = _method_entry.bytecode;
                                    _val[PROG_CLOSURE.ENV] = _vm[PROG_VM.SCOPE];
                                    _val[PROG_CLOSURE.NAME] = _prop;
                                    _val[PROG_CLOSURE.PARAM_COUNT] = struct_exists(_method_entry, "param_count") ? _method_entry.param_count : 0;
                                    _val[PROG_CLOSURE.DEFINING_CLASS] = _curr;
                                    _val[PROG_CLOSURE.RECEIVER] = _receiver;
                                    _val[PROG_CLOSURE.GLOBAL_REF] = _gref;
                                    _found = true;
                                    break;
                                }
                                _curr = _curr.super_class;
                            }
                            if (!_found) runtime_error(PROGLANG_ERROR_TYPE.MEMBER, $"Property '{_prop}' not found in super class.");
                        }
                        // Regular instance lookup
                        else if (is_struct(_obj))
                        {
                            if (struct_exists(_obj, _prop))
                            {
                                _val = _obj[$ _prop];
                            }
                            // Class instance method lookup
                            else if (struct_exists(_obj, "__class__"))
                            {
                                var _class = _obj.__class__;
                                var _curr = _class;
                                var _found = false;
                                while(_curr != undefined)
                                {
                                    if (struct_exists(_curr.methods, _prop))
                                    {
                                        var _method_entry = _curr.methods[$ _prop];
                                        _val = array_create(PROG_CLOSURE.SIZE);
                                        _val[PROG_CLOSURE.TYPE] = "closure";
                                        _val[PROG_CLOSURE.BYTECODE] = _method_entry.bytecode;
                                        _val[PROG_CLOSURE.ENV] = _vm[PROG_VM.SCOPE]; // Methods capture current scope (for globals etc)
                                        _val[PROG_CLOSURE.NAME] = _prop;
                                        _val[PROG_CLOSURE.PARAM_COUNT] = struct_exists(_method_entry, "param_count") ? _method_entry.param_count : 0;
                                        _val[PROG_CLOSURE.DEFINING_CLASS] = _curr;
                                        _val[PROG_CLOSURE.RECEIVER] = _obj;
                                        _val[PROG_CLOSURE.GLOBAL_REF] = _gref;
                                        _found = true;
                                        break;
                                    }
                                    _curr = _curr.super_class;
                                }
                                
                                if (!_found)
                                {
                                    runtime_error(PROGLANG_ERROR_TYPE.MEMBER, $"Property or method '{_prop}' not found.");
                                }
                            }
                            else
                            {
                                // Not found on regular struct
                                //  runtime_error(PROGLANG_ERROR_TYPE.MEMBER, $"Property '{_prop}' not found.");
                                _val = undefined;
                            }
                        }
                        else
                        {
                            
                            // String properties
                            if (is_string(_obj))
                            {
                                if (_prop == "length") _val = string_length(_obj);
                                else runtime_error(PROGLANG_ERROR_TYPE.MEMBER, "Unknown string property");
                            }
                            // Array properties
                            else if (is_array(_obj))
                            {
                                if (_prop == "length") _val = array_length(_obj);
                                else if (_prop == "push") _val = method(_obj, function(_val) { array_push(self, _val); });
                                else if (_prop == "pop") _val = method(_obj, function() { return array_pop(self); });
                                else runtime_error(PROGLANG_ERROR_TYPE.MEMBER, "Unknown array property");
                            }
                            else
                            {
                                runtime_error(PROGLANG_ERROR_TYPE.MEMBER, "Cannot access property of non-object.");
                            }
                        }
                        _stack[@ _sp++] = _val;
                        break;
                        
                    case PROG_OP.MEMBER_SET:
                        _val = _stack[--_sp];
                        _prop = _constants[_arg];
                        _obj = _stack[--_sp];
                        
                        // Check active class for private/protected (simplified)
                        if (is_struct(_obj))
                        {
                            _obj[$ _prop] = _val;
                        }
                        else
                        {
                            runtime_error(PROGLANG_ERROR_TYPE.MEMBER, "Cannot set property of non-object.");
                        }
                        _stack[@ _sp++] = _val;
                        break;
                    
                    // Control Flow
                    case PROG_OP.JUMP: _ip = _arg; break;
                    case PROG_OP.JUMP_IF_FALSE:
                        _val = _stack[--_sp];
                        if (!_val) _ip = _arg;
                        break;
                    case PROG_OP.JUMP_IF_TRUE:
                        _val = _stack[--_sp];
                        if (_val) _ip = _arg;
                        break;
                    case PROG_OP.JUMP_IF_NULL:
                        _val = _stack[_sp - 1]; // Peek, don't pop
                        if (is_undefined(_val)) _ip = _arg;
                        break;
                    case PROG_OP.JUMP_IF_NOT_NULL:
                        _val = _stack[_sp - 1]; // Peek, don't pop
                        if (!is_undefined(_val)) _ip = _arg;
                        break;
                        
                    // Creation
                    case PROG_OP.ARRAY_NEW:
                        // _arg is size
                        var _arr = array_create(_arg);
                        for (var i = _arg - 1; i >= 0; i--) _arr[i] = _stack[--_sp];
                        _stack[@ _sp++] = _arr;
                        break;
                        
                    case PROG_OP.OBJECT_NEW:
                        var _size = _arg; // Number of pairs
                        var _obj = {};
                        for (var i = 0; i < _size; i++)
                        {
                            var _val = _stack[--_sp];
                            var _key = _stack[--_sp];
                            _obj[$ _key] = _val;
                        }
                        _stack[@ _sp++] = _obj;
                        break;
                        
                    case PROG_OP.MAKE_REGEX:
                        var _flags = _stack[--_sp];
                        var _pattern = _stack[--_sp];
                        _stack[@ _sp++] = new Regex(_pattern, _flags);
                        break;
                        
                    // Spread Operations
                    case PROG_OP.PUSH_ARRAY_EMPTY:
                        _stack[@ _sp++] = [];
                        break;
                    
                    case PROG_OP.ARRAY_PUSH:
                        var _val = _stack[--_sp];
                        var _arr = _stack[_sp - 1]; // Peek
                        array_push(_arr, _val);
                        break;
    
                    case PROG_OP.ARRAY_SPREAD:
                        var _arr = _stack[--_sp]; // The array to spread
                        var _target = _stack[_sp - 1]; // The target array
                        if (is_array(_arr))
                        {
                            var _len = array_length(_arr);
                            for (var i = 0; i < _len; i++) array_push(_target, _arr[i]);
                        }
                        break;
                        
                    case PROG_OP.CALL_SPREAD:
                        _val = _stack[--_sp]; // Callee
                        var _args_arr = _stack[--_sp]; // Arg Array
                        
                        // Sync state back to VM before call
                        _vm[@ PROG_VM.SP] = _sp;
                        _vm[@ PROG_VM.IP] = _ip;
                        
                        var _res = ProgVM_exec_call(_vm, _val, _args_arr);
                        
                        _stack[@ _vm[PROG_VM.SP]++] = _res;
                        
                        // Sync state back to local
                        _sp = _vm[PROG_VM.SP];
                        _ip = _vm[PROG_VM.IP];
                        break;
                    
                    case PROG_OP.CALL:
                        var _arg_count = _arg;
                        var _args_arr = array_create(_arg_count);
                        for (var i = _arg_count - 1; i >= 0; i--) _args_arr[i] = _stack[--_sp];
                        _val = _stack[--_sp]; // Callee
                        
                        // Sync state back to VM before call
                        _vm[@ PROG_VM.SP] = _sp;
                        _vm[@ PROG_VM.IP] = _ip;
                        
                        var _res = ProgVM_exec_call(_vm, _val, _args_arr);
                        
                        _stack[@ _vm[PROG_VM.SP]++] = _res;
                        
                        // Sync state back to local
                        _sp = _vm[PROG_VM.SP];
                        _ip = _vm[PROG_VM.IP];
                        
                        break;
                        
                    case PROG_OP.RETURN:
                        _val = _stack[--_sp];
                        return _val;
                    
                    case PROG_OP.NEW_INSTANCE:
                        var _arg_count = _arg;
                        var _class = _stack[--_sp];
                        
                        if (!is_struct(_class) || !struct_exists(_class, "__type__") || _class.__type__ != "class")
                        {
                            runtime_error(PROGLANG_ERROR_TYPE.TYPE, "Target is not a class.");
                        }
                        
                        var _inst = {
                            __class__: _class,
                            __type__: "instance"
                        };
                        
                        // Initialize fields
                        if (struct_exists(_class, "fields"))
                        {
                            var _fields = _class.fields;
                            for (var k = 0; k < array_length(_fields); k++)
                            {
                                var _field = _fields[k];
                                _inst[$ _field.name] = _field.value;
                            }
                        }
                        
                        if (struct_exists(_class, "constructor_code") && _class.constructor_code != undefined)
                        {
                            var _args_arr = array_create(_arg_count);
                            for (var i = _arg_count - 1; i >= 0; i--) _args_arr[i] = _stack[--_sp];
                            
                            var _new_vm = ProgVM_create();
                            _new_vm[@ PROG_VM.CONTEXT] = _vm[PROG_VM.CONTEXT];
                            // _new_vm[@ PROG_VM.CALL_STACK] = variable_clone(_vm[PROG_VM.CALL_STACK]); // don't debug new callstack deeper?
                            _new_vm[@ PROG_VM.CURRENT_THIS] = _inst;
                            
                            var _vars = _new_vm[PROG_VM.SCOPE][PROG_SCOPE.VARS];
                            for (var j = 0; j < _arg_count; j++)
                            {
                                _vars[$ $"arg{j}"] = _args_arr[j];
                            }
                            _vars[$ "argc"] = _arg_count;
                            
                            ProgVM_run(_new_vm, _class.constructor_code);
                            ProgVM_free(_new_vm);
                        }
                        else
                        {
                            _sp -= _arg_count; 
                        }
                        
                        _stack[@ _sp++] = _inst;
                        break;
                    
                    case PROG_OP.LOAD_SUPER:
                        if (_vm[PROG_VM.CURRENT_THIS] == undefined || !struct_exists(_vm[PROG_VM.CURRENT_THIS], "__class__"))
                        {
                            runtime_error(PROGLANG_ERROR_TYPE.RUNTIME, "'super' used outside of class instance.");
                        }
                        var _class_super = undefined;
                        
                        if (_vm[PROG_VM.ACTIVE_CLASS] != undefined)
                        {
                            _class_super = _vm[PROG_VM.ACTIVE_CLASS];
                        }
                        else
                        {
                            _class_super = _vm[PROG_VM.CURRENT_THIS].__class__;
                        }
                        
                        if (_class_super.super_class == undefined)
                        {
                            runtime_error(PROGLANG_ERROR_TYPE.RUNTIME, "Class has no super class.");
                        }
                        
                        // Return super proxy
                        _stack[@ _sp++] = {
                            __super__: _class_super.super_class,
                            receiver: _vm[PROG_VM.CURRENT_THIS]
                        };
                        break;
                        
                    case PROG_OP.PUSH_TRY:
                        array_push(_vm[PROG_VM.TRY_STACK], _arg); // _arg is jump address for catch
                        break;
                    
                    case PROG_OP.POP_TRY:
                        array_pop(_vm[PROG_VM.TRY_STACK]);
                        break;
    
                    // Iteration
                    case PROG_OP.ITER_INIT:
                        var _coll = _stack[--_sp];
                        var _iter = undefined;
                        if (is_array(_coll))
                        {
                            _iter = { type: "array_iter", val: _coll, idx: 0, len: array_length(_coll) };
                        }
                        else if (is_struct(_coll))
                        {
                            var _keys = variable_struct_get_names(_coll);
                            _iter = { type: "struct_iter", val: _coll, keys: _keys, idx: 0, len: array_length(_keys) };
                        }
                        else
                        {
                            _iter = { type: "empty", idx: 0, len: 0 };
                        }
                        _stack[@ _sp++] = _iter;
                        break;
    
                    case PROG_OP.ITER_NEXT:
                        var _iter = _stack[_sp - 1]; // Peek
                        if (_iter.idx < _iter.len) {
                            var _key = undefined;
                            if (_iter.type == "array_iter") _key = _iter.idx;
                            else if (_iter.type == "struct_iter") _key = _iter.keys[_iter.idx];
                            
                            _iter.idx++;
                            _stack[@ _sp++] = _key;
                            _stack[@ _sp++] = true;
                        } else {
                            _stack[@ _sp++] = false;
                        }
                        break;
    
                    case PROG_OP.ITER_GET_VAL:
                        var _iter = _stack[_sp - 1]; // Peek
                        var _val = undefined;
                        if (_iter.type == "array_iter") _val = _iter.val[_iter.idx - 1];
                        else if (_iter.type == "struct_iter") {
                            var _key = _iter.keys[_iter.idx - 1];
                            _val = _iter.val[$ _key];
                        }
                        _stack[@ _sp++] = _val;
                        break;
    
                    // Class Def
                    case PROG_OP.CLASS_DEF:
                        _stack[@ _sp++] = _constants[_arg];
                        break;
                        
                    case PROG_OP.LOAD_THIS:
                        _stack[@ _sp++] = _vm[PROG_VM.CURRENT_THIS];
                        break;
    
                    // Modules
                    case PROG_OP.IMPORT:
                        var _path = _constants[_arg];
                        var _cur_file = "";
                        if (struct_exists(_vm[PROG_VM.SCOPE][PROG_SCOPE.VARS], "__filename"))
                            _cur_file = _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__filename"];
                        
                        var _exports = proglang_load_module(_path, _cur_file);
                        _stack[@ _sp++] = _exports;
                        break;
                        
                    case PROG_OP.EXPORT_SET:
                        var _name = _constants[_arg];
                        var _val = _stack[_sp - 1]; // Peek
                        
                        if (_vm[PROG_VM.ACTIVE_MODULE] != undefined)
                        {
                            _vm[PROG_VM.ACTIVE_MODULE].exports[$ _name] = _val;
                        }
                        else if (variable_global_exists("proglang_exports"))
                        {
                            global.proglang_exports[$ _name] = _val;
                        }
                        break;
                    
                    case PROG_OP.THROW:
                        _val = _stack[--_sp];
                        throw _val;
                        break;
                }
            }
        
            return undefined;
        }
        catch(_e)
        {
            if (array_length(_vm[PROG_VM.TRY_STACK]) > 0)
            {
                var _catch_addr = array_pop(_vm[PROG_VM.TRY_STACK]);
                _ip = _catch_addr;
                // Push error onto stack for catch block
                _stack[@ _sp++] = _e;
            }
            else
            {
                throw _e;
            }
        }
    }
}

// ========== VM POOL MANAGEMENT (Global) ==========

/// @desc Initialize VM pool if needed
function proglang_vm_pool_init()
{
    if (!variable_global_exists("proglang_vm_pool"))
    {
        global.proglang_vm_pool = [];
        global.proglang_vm_pool_max = 32;
        global.proglang_vm_alloc_count = 0;
        global.proglang_vm_gc_threshold = 100;
    }
}

function ProgVM_create_impl()
{
    var _vm = array_create(PROG_VM.SIZE);
    _vm[PROG_VM.STACK] = array_create(1024);
    _vm[PROG_VM.SP] = 0;
    _vm[PROG_VM.IP] = 0;
    
    // Initial scope
    var _scope = array_create(PROG_SCOPE.SIZE);
    _scope[PROG_SCOPE.VARS] = {};
    _scope[PROG_SCOPE.PARENT] = undefined;
    
    _vm[PROG_VM.SCOPE] = _scope;
    _vm[PROG_VM.CONTEXT] = undefined;
    _vm[PROG_VM.GLOBAL_REF] = {};
    _vm[PROG_VM.TRY_STACK] = [];
    _vm[PROG_VM.ACTIVE_MODULE] = undefined;
    _vm[PROG_VM.CALL_STACK] = [];
    _vm[PROG_VM.CURRENT_THIS] = undefined;
    _vm[PROG_VM.ACTIVE_CLASS] = undefined;
    _vm[PROG_VM.CLASS_REGISTRY] = {};
    
    return _vm;
}

/// @desc Acquire a VM instance (from pool or new)
/// @returns {Array<PROG_VM>}
function ProgVM_create()
{
    proglang_vm_pool_init();
    
    global.proglang_vm_alloc_count++;
    
    // Auto-GC check
    if (global.proglang_vm_alloc_count >= global.proglang_vm_gc_threshold)
    {
        ProgVM_gc();
        global.proglang_vm_alloc_count = 0;
    }
    
    if (array_length(global.proglang_vm_pool) > 0)
    {
        var _vm = array_pop(global.proglang_vm_pool);
        ProgVM_reset(_vm);
        return _vm;
    }
    
    return ProgVM_create_impl();
}

/// @desc Release a VM instance back to the pool
/// @param {Array<PROG_VM>} _vm
function ProgVM_free(_vm)
{
    proglang_vm_pool_init();
    
    if (array_length(global.proglang_vm_pool) < global.proglang_vm_pool_max)
    {
        ProgVM_reset(_vm);
        array_push(global.proglang_vm_pool, _vm);
    }
}

/// @desc Garbage collection - clear unused VMs from pool
function ProgVM_gc()
{
    proglang_vm_pool_init();
    
    // Clear excess pool entries
    while (array_length(global.proglang_vm_pool) > global.proglang_vm_pool_max / 2)
    {
        array_pop(global.proglang_vm_pool);
    }
    
    // Force GML garbage collection
    gc_collect();
}

/// @desc Throw a runtime error
/// @param {real} _type Error type
/// @param {string} _msg Error message
function runtime_error(_type, _msg)
{
    throw { type: _type, message: _msg, stacktrace: debug_get_callstack() };
}