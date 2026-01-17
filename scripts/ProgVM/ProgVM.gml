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
    STACK,          // Array (Unified Data Stack)
    SP,             // Real (Stack Pointer)
    IP,             // Real (Instruction Pointer)
    BP,             // Real (Base Pointer for current frame)
    SCOPE,          // Array [PROG_SCOPE]
    CONTEXT,        // Struct (External context)
    GLOBAL_REF,     // Struct (Global scope)
    TRY_STACK,      // Array
    ACTIVE_MODULE,  // Struct (Module info)
    FRAME_STACK,    // Array (Control Flow Stack: [ReturnIP, SavedBP, SavedScope, SavedBytecode])
    FP,             // Real (Frame Pointer)
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
    RETURN_IP,
    SAVED_BP,
    SAVED_SCOPE,
    SAVED_BYTECODE,
    SAVED_GREF, // Added for module scope restoration
    SIZE // 5
}

// ========== CORE VM FUNCTIONS ==========

/// @desc Reset VM state for reuse
/// @param {Array<PROG_VM>} _vm The VM array
function proglang_vm_reset(_vm)
{
    _vm[@ PROG_VM.SP] = 0;
    _vm[@ PROG_VM.IP] = 0;
    _vm[@ PROG_VM.BP] = 0;
    _vm[@ PROG_VM.FP] = 0;
    
    // Pre-allocate or reset stacks
    if (array_length(_vm[PROG_VM.STACK]) < 10000) _vm[@ PROG_VM.STACK] = array_create(10000); // 10k slots
    // Using a flat array for frames roughly 1000 deep * 5 items
    if (array_length(_vm[PROG_VM.FRAME_STACK]) < 5000) _vm[@ PROG_VM.FRAME_STACK] = array_create(5000);
    
    // Create new root scope
    var _scope = array_create(PROG_SCOPE.SIZE);
    _scope[PROG_SCOPE.VARS] = {}
    _scope[PROG_SCOPE.PARENT] = undefined;
    
    _vm[@ PROG_VM.SCOPE] = _scope;
    _vm[@ PROG_VM.CONTEXT] = undefined;
    _vm[@ PROG_VM.GLOBAL_REF] = {}
    _vm[@ PROG_VM.TRY_STACK] = []; // Try stack is still dynamic for now (usually shallow)
    _vm[@ PROG_VM.CURRENT_THIS] = undefined;
    _vm[@ PROG_VM.ACTIVE_CLASS] = undefined;
    _vm[@ PROG_VM.ACTIVE_MODULE] = undefined;
}

/// @desc Find variable in scope chain
/// @param {Array<PROG_VM>} _vm
/// @param {string} _name
function proglang_vm_find_var_scope(_vm, _name)
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

/// @desc DEPRECATED: Internal Call Execution (Now Inlined in Run)
function proglang_vm_exec_call(_vm, _func, _args)
{
    show_error("proglang_vm_exec_call is deprecated and should not be used.", true);
    return undefined;
}

/// @desc Execute bytecode
/// @param {Array<PROG_VM>} _vm The VM array
/// @param {struct} _bytecode Compiled bytecode object
/// @returns {any} Execution result
function proglang_vm_run(_vm, _entry_bytecode)
{
    // === SINGLE LOOP VM (V2) ===
    

    
    if (_entry_bytecode == undefined) return undefined;
    
    // Load entry instructions
    var _curr_bytecode = _entry_bytecode;
    var _code = _curr_bytecode.code;
    var _constants = _curr_bytecode.constants;
    var _len = array_length(_code);
    
    // Reset IP for entry (assuming new invocation)
    // If this is a re-entrant call (e.g. from Native), we treat it as a new "thread" on the same stack.
    // So we don't reset SP or FP globally, but we track our start point.
    
    var _sp = _vm[PROG_VM.SP];
    var _fp = _vm[PROG_VM.FP];
    var _bp = _vm[PROG_VM.BP];
    var _ip = 0; 
    
    // Capture starting frame pointer to know when to yield/return from this run
    var _start_fp = _fp;
    
    // Local Cache
    var _stack = _vm[PROG_VM.STACK];
    var _frames = _vm[PROG_VM.FRAME_STACK];
    var _scope = _vm[PROG_VM.SCOPE];
    var _gref = _vm[PROG_VM.GLOBAL_REF];
    
    // LIFTED VARIABLES
    var _a, _b, _val, _index, _name, _arr, _obj, _prop, _vm_thrown_error;
    var _steps = 0;
    var _max_steps = 1000000;
    
    while (true)
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
                
                // DEBUG TRACE
                if (_sp < 0) show_debug_message($"[VM CRITICAL] SP UNDERFLOW BEFORE OP: {_sp}");
                
                switch (_op)
                {
                    // Stack
                    case PROG_OP.PUSH_NULL: _stack[@ _sp++] = undefined; break;
                    case PROG_OP.PUSH_TRUE: _stack[@ _sp++] = true; break;
                    case PROG_OP.PUSH_FALSE: _stack[@ _sp++] = false; break;
                    case PROG_OP.PUSH_GLOBAL_REF: _stack[@ _sp++] = _gref; break;
                    case PROG_OP.PUSH_CONST: _stack[@ _sp++] = _constants[_arg]; break;
                    case PROG_OP.POP: _sp--; break;
                    case PROG_OP.DUP: _stack[@ _sp] = _stack[_sp - 1]; _sp++; break;
                    case PROG_OP.DUP2:
                        _a = _stack[_sp - 1];
                        _b = _stack[_sp - 2];
                        _stack[@ _sp++] = _b;
                        _stack[@ _sp++] = _a;
                        break;
                    case PROG_OP.POP_AND_KEEP:
                        _a = _stack[--_sp];
                        _stack[@ _sp - 1] = _a;
                        break;
                    
                    // Optimization Ops
                    case PROG_OP.INC: _stack[@ _sp - 1]++; break;
                    case PROG_OP.DEC: _stack[@ _sp - 1]--; break;
                    
                    case PROG_OP.LOAD_LOCAL: _stack[@ _sp++] = _stack[_bp + _arg]; break;
                    case PROG_OP.STORE_LOCAL: _stack[@ _bp + _arg] = _stack[_sp - 1]; break; // Peek
                        
                    // Arithmetic
                    case PROG_OP.ADD:
                        _b = _stack[--_sp]; _a = _stack[_sp - 1];
                        if (is_real(_a) && is_real(_b)) _stack[@ _sp - 1] = _a + _b;
                        else if (is_string(_a) || is_string(_b))
                        {
                            var _sa = ((is_bool(_a)) ? ((_a) ? "true" : "false") : string(_a));
                            var _sb = ((is_bool(_b)) ? ((_b) ? "true" : "false") : string(_b));
                            _stack[@ _sp - 1] = _sa + _sb;
                        }
                        else if (is_undefined(_a) || is_undefined(_b))
                        {
                            runtime_error(PROGLANG_ERROR_TYPE.UNDEFINED_VALUE, "Undefined value in addition.");
                        }
                        else
                        {
                            _stack[@ _sp - 1] = _a + _b; 
                        }
                        break;
                    case PROG_OP.STRING_CONCAT:
                        _b = _stack[--_sp]; _a = _stack[_sp - 1];
                        var _sa = is_string(_a) ? _a : ((is_bool(_a)) ? ((_a) ? "true" : "false") : string(_a));
                        var _sb = is_string(_b) ? _b : ((is_bool(_b)) ? ((_b) ? "true" : "false") : string(_b));
                        _stack[@ _sp - 1] = _sa + _sb;
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
                    
                    // Variable Access (Legacy/Fallback)
                    case PROG_OP.LOAD:
                        _name = _constants[_arg];
                        var _s = proglang_vm_find_var_scope(_vm, _name);
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
                        else if (variable_global_exists(_name)) { _stack[@ _sp++] = variable_global_get(_name); } // Simplified global check
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
                        _val = _stack[_sp - 1];
                        _name = _constants[_arg];
                        var _s_store = proglang_vm_find_var_scope(_vm, _name);
                        if (_s_store != undefined) { _s_store[PROG_SCOPE.VARS][$ _name] = _val; }
                        else if (_vm[PROG_VM.CONTEXT] != undefined && struct_exists(_vm[PROG_VM.CONTEXT], _name)) { _vm[PROG_VM.CONTEXT][$ _name] = _val; }
                        else if (struct_exists(_gref, _name)) { _gref[$ _name] = _val; }
                        else { _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ _name] = _val; }
                        break;
                        
                    case PROG_OP.DEFINE:
                        _val = _stack[_sp - 1];
                        _name = _constants[_arg];
                        _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ _name] = _val;
                        break;
                        
                    case PROG_OP.LOAD_GLOBAL: _stack[@ _sp++] = _gref[$ _constants[_arg]]; break;
                    case PROG_OP.STORE_GLOBAL: _gref[$ _constants[_arg]] = _stack[_sp - 1]; break;
                        
                    // Scope
                    case PROG_OP.PUSH_SCOPE:
                        var _new_scope = array_create(PROG_SCOPE.SIZE);
                        _new_scope[PROG_SCOPE.VARS] = {}
                        _new_scope[PROG_SCOPE.PARENT] = _vm[PROG_VM.SCOPE];
                        _vm[@ PROG_VM.SCOPE] = _new_scope;
                        _scope = _new_scope; // Update local cache
                        break;
                        
                    case PROG_OP.POP_SCOPE:
                        var _parent = _scope[PROG_SCOPE.PARENT];
                        if (_parent != undefined)
                        {
                            _vm[@ PROG_VM.SCOPE] = _parent;
                            _scope = _parent;
                        }
                        else
                        {
                            runtime_error(PROGLANG_ERROR_TYPE.RUNTIME, "Scope underflow");
                        }
                        break;
                    
                    case PROG_OP.JUMP: _ip = _arg; break;
                    case PROG_OP.JUMP_IF_FALSE: _val = _stack[--_sp]; if (!_val) _ip = _arg; break;
                    case PROG_OP.JUMP_IF_TRUE: _val = _stack[--_sp]; if (_val) _ip = _arg; break;
                    case PROG_OP.JUMP_IF_NULL: if (is_undefined(_stack[_sp - 1])) _ip = _arg; break;
                    case PROG_OP.JUMP_IF_NOT_NULL: if (!is_undefined(_stack[_sp - 1])) _ip = _arg; break;
                    
                    case PROG_OP.CALL:
                    case PROG_OP.CALL_SPREAD:
                        var _param_count = 0;
                        var _callee_index = 0;
                        
                        if (_op == PROG_OP.CALL)
                        {
                            _param_count = _arg;
                            _callee_index = _sp - _param_count - 1;
                            _val = _stack[_callee_index]; // Callee
                        }
                        else
                        {
                            // CALL_SPREAD: [Callee, ArgArr]
                            var _args_arr = _stack[--_sp];
                            _val = _stack[--_sp]; // Callee
                            _param_count = array_length(_args_arr);
                            
                            // Re-push callee and args to unify stack Call format
                            _stack[@ _sp++] = _val;
                            for (var i = 0; i < _param_count; i++) _stack[@ _sp++] = _args_arr[i];
                            
                            _callee_index = _sp - _param_count - 1;
                        }
                        
                        // 0. Resolve String Callee
                        if (is_string(_val))
                        {
                            // 1. Global Functions (Built-ins)
                            if (variable_global_exists("proglang_functions") && struct_exists(global.proglang_functions, _val))
                            {
                                _val = global.proglang_functions[$ _val];
                            }
                            // 2. Global Scripts (Modules)
                            else if (variable_global_exists("proglang_scripts") && struct_exists(global.proglang_scripts, _val))
                            {
                                var _s = global.proglang_scripts[$ _val];
                                if (is_array(_s) && array_length(_s) >= PROG_MODULE.SIZE) _val = _s[PROG_MODULE.MAIN];
                                else _val = _s;
                            }
                            // 3. Context
                            else if (_vm[PROG_VM.CONTEXT] != undefined && struct_exists(_vm[PROG_VM.CONTEXT], _val))
                            {
                                _val = _vm[PROG_VM.CONTEXT][$ _val];
                            }
                            // 4. Asset Script
                            else 
                            {
                                var _asset = asset_get_index(_val);
                                if (_asset != -1 && asset_get_type(_val) == asset_script) _val = _asset;
                            }
                        }
    
                        // 1. Bytecode Closure
                        if (is_array(_val) && array_length(_val) >= PROG_CLOSURE.SIZE && _val[PROG_CLOSURE.TYPE] == "closure")
                        {
                            // Argument Padding (Optional Parameters)
                            var _expected_count = _val[PROG_CLOSURE.PARAM_COUNT];
                            if (_param_count < _expected_count)
                            {
                                var _diff = _expected_count - _param_count;
                                repeat(_diff) _stack[@ _sp++] = undefined;
                                _param_count = _expected_count;
                            }
    
                            // Push Frame
                            _frames[@ _fp++] = _ip;
                            _frames[@ _fp++] = _bp;
                            _frames[@ _fp++] = _scope;
                            _frames[@ _fp++] = _curr_bytecode;
                            _frames[@ _fp++] = _gref;
                            
                            // Switch Context
                            _curr_bytecode = _val[PROG_CLOSURE.BYTECODE];
                            _code = _curr_bytecode.code;
                            _constants = _curr_bytecode.constants;
                            _len = array_length(_code);
                            _ip = 0;
                            _bp = _sp - _param_count; // BP points to first argument
                            
                            // Scope Setup
                            var _closure_env = _val[PROG_CLOSURE.ENV];
                            var _new_scope = array_create(PROG_SCOPE.SIZE);
                            _new_scope[PROG_SCOPE.VARS] = {}
                            _new_scope[PROG_SCOPE.PARENT] = _closure_env;
                            _vm[@ PROG_VM.SCOPE] = _new_scope;
                            _scope = _new_scope;

                            // Restore captured global ref
                            _gref = _val[PROG_CLOSURE.GLOBAL_REF];
                            _vm[@ PROG_VM.GLOBAL_REF] = _gref;
                            
                            // Legacy Argument Support (Populate argN)
                            var _vars = _new_scope[PROG_SCOPE.VARS];
                            for (var i = 0; i < _param_count; i++)
                            {
                                _vars[$ "arg" + string(i)] = _stack[_bp + i];
                            }
                            _vars[$ "argc"] = _param_count;
                        }
                        // 2. Built-in Function (Struct wrapper)
                        else if (is_struct(_val) && struct_exists(_val, "function"))
                        {
                            var _args_subset = array_create(_param_count);
                            array_copy(_args_subset, 0, _stack, _callee_index + 1, _param_count);
                            _sp -= (_param_count + 1); // Pop args and callee
                            var _res = _val[$ "function"](_args_subset, _vm);
                            _stack[@ _sp++] = _res;
                        }
                        // 3. Native Script
                        else if (is_real(_val) && script_exists(_val))
                        {
                            var _args_subset = array_create(_param_count);
                            array_copy(_args_subset, 0, _stack, _callee_index + 1, _param_count);
                            // Execute
                            _sp -= (_param_count + 1); // Pop args and callee
                            var _res = script_execute_ext(_val, _args_subset);
                            _stack[@ _sp++] = _res;
                        }
                        // 4. Native Method/Function
                        else if (is_method(_val))
                        {
                            var _args_subset = array_create(_param_count);
                            array_copy(_args_subset, 0, _stack, _callee_index + 1, _param_count);
                            _sp -= (_param_count + 1);
                            var _res = method_call(_val, _args_subset);
                            _stack[@ _sp++] = _res;
                        }
                        // 5. Raw Bytecode (Module/Script)
                        else if (is_struct(_val) && struct_exists(_val, "code"))
                        {
                            // Push Frame (Same as closure but fresh scope)
                            _frames[@ _fp++] = _ip;
                            _frames[@ _fp++] = _bp;
                            _frames[@ _fp++] = _scope;
                            _frames[@ _fp++] = _curr_bytecode;
                            _frames[@ _fp++] = _gref; // No change in gref for raw bytecode usually, but consistent frame push
                            
                            _curr_bytecode = _val;
                            _code = _curr_bytecode.code;
                            _constants = _curr_bytecode.constants;
                            _len = array_length(_code);
                            _ip = 0;
                            _bp = _sp - _param_count;
                            
                            var _new_scope = array_create(PROG_SCOPE.SIZE);
                            _new_scope[PROG_SCOPE.VARS] = {}
                            _new_scope[PROG_SCOPE.PARENT] = undefined; // Top level
                            _vm[@ PROG_VM.SCOPE] = _new_scope;
                            _scope = _new_scope;
                            
                            var _vars = _new_scope[PROG_SCOPE.VARS];
                            for (var i = 0; i < _param_count; i++)
                            {
                                _vars[$ "arg" + string(i)] = _stack[_bp + i];
                            }
                            _vars[$ "argc"] = _param_count;
                        }
                        else
                        {
                            show_debug_message($"[ProgVM] Error: Call to non-callable value: {_val}");
                            _sp -= (_param_count + 1);
                            _stack[@ _sp++] = undefined;
                        }
                        break;
                        
                    case PROG_OP.RETURN:
                        _val = _stack[--_sp];
                        
                        if (_fp == _start_fp)
                        {
                            // Sync VM state before exit
                            _vm[@ PROG_VM.SP] = _sp;
                            _vm[@ PROG_VM.IP] = _ip;
                            _vm[@ PROG_VM.BP] = _bp;
                            _vm[@ PROG_VM.FP] = _fp;
                            return _val;
                        }
                        
                        // Capture current (Callee's) BP to restore SP correctly later
                        var _return_bp = _bp;
    
                        // Pop Frame
                        _gref = _frames[--_fp];
                        _curr_bytecode = _frames[--_fp];
                        _scope = _frames[--_fp];
                        _bp = _frames[--_fp];
                        _ip = _frames[--_fp];
                        
                        _vm[@ PROG_VM.SCOPE] = _scope;
                        _vm[@ PROG_VM.GLOBAL_REF] = _gref;
                        
                        _code = _curr_bytecode.code;
                        _constants = _curr_bytecode.constants;
                        _len = array_length(_code);
                        
                        // Return Value placement
                        // Previous stack: [... Caller Locals ... | Callee | Arg1 ... ArgN | ... Callee Locals ...]
                        // _return_bp was pointing to Arg1.
                        // We want to reset SP to point to where Callee was, and push the return value there.
                        // Callee was at _return_bp - 1.
                        
                        _sp = _return_bp - 1;
                        _stack[@ _sp++] = _val;
                        break;
                        
                    // Try/Catch
                    case PROG_OP.PUSH_TRY:
                        // We push {ip, fp} to handle cross-frame catches
                        array_push(_vm[PROG_VM.TRY_STACK], { ip: _arg, fp: _fp, sp: _sp });
                        break;
                    
                    case PROG_OP.POP_TRY:
                        array_pop(_vm[PROG_VM.TRY_STACK]);
                        break;
                    
                    case PROG_OP.THROW:
                        _val = _stack[--_sp];
                        throw _val; // Handled by outer try-catch
                        break;
                        
                    // Structure Access
                    case PROG_OP.INDEX_GET:
                        _index = _stack[--_sp];
                        _arr = _stack[--_sp];
                        
                        // Check for range slicing: _index is ["range", start, end]
                        if (is_array(_index) && array_length(_index) >= 3 && _index[0] == "range")
                        {
                            var _start = _index[1];
                            var _end = _index[2];
                            
                            if (is_array(_arr))
                            {
                                var _arr_len = array_length(_arr);
                                
                                if (_start < 0) _start = 0;
                                if (_end >= _arr_len) _end = _arr_len - 1;
                                
                                var _slice_len = _end - _start + 1;
                                
                                if (_slice_len > 0)
                                {
                                    _val = array_create(_slice_len);
                                    array_copy(_val, 0, _arr, _start, _slice_len);
                                }
                                else
                                {
                                    _val = [];
                                }
                            }
                            else if (is_string(_arr))
                            {
                                // String slicing: str[start..end] (0-indexed, inclusive)
                                var _str_len = string_length(_arr);
                                
                                if (_start < 0) _start = 0;
                                if (_end >= _str_len) _end = _str_len - 1;
                                
                                var _slice_len = _end - _start + 1;
                                
                                if (_slice_len > 0)
                                {
                                    _val = string_copy(_arr, _start + 1, _slice_len);
                                }
                                else
                                {
                                    _val = "";
                                }
                            }
                            else
                            {
                                runtime_error(PROGLANG_ERROR_TYPE.TYPE, "Range indexing only supported on arrays and strings.");
                            }
                        }
                        else
                        {
                            // Single element access
                            if (is_array(_arr))
                            {
                                _val = _arr[_index];
                            }
                            else if (is_struct(_arr))
                            {
                                _val = _arr[$ _index];
                            }
                            else if (is_string(_arr))
                            {
                                // String indexing: str[i] (0-indexed)
                                _val = string_char_at(_arr, _index + 1);
                            }
                            else
                            {
                                _val = undefined;
                            }
                        }
                        
                        _stack[@ _sp++] = _val;
                        break;
                    
                    case PROG_OP.INDEX_SET:
                        _val = _stack[--_sp];
                        _index = _stack[--_sp];
                        _arr = _stack[--_sp];
                        if (is_array(_arr)) _arr[@ _index] = _val;
                        else if (is_struct(_arr)) _arr[$ _index] = _val;
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
                    
                    // Creation
                    case PROG_OP.ARRAY_NEW:
                        var _sz = _arg;
                        var _arr = array_create(_sz);
                        for (var i = _sz - 1; i >= 0; i--) _arr[i] = _stack[--_sp];
                        _stack[@ _sp++] = _arr;
                        break;
                        
                    case PROG_OP.OBJECT_NEW:
                        var _sz = _arg;
                        var _obj = {}
                        for (var i = 0; i < _sz; i++) {
                            var _v = _stack[--_sp];
                            var _k = _stack[--_sp];
                            _obj[$ _k] = _v;
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
                            var _arr_spread_len = array_length(_arr);
                            for (var i = 0; i < _arr_spread_len; i++) array_push(_target, _arr[i]);
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
                        }
                        
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
                            
                            var _new_vm = proglang_vm_create();
                            _new_vm[@ PROG_VM.CONTEXT] = _vm[PROG_VM.CONTEXT];
                            // _new_vm[@ PROG_VM.CALL_STACK] = variable_clone(_vm[PROG_VM.CALL_STACK]); // don't debug new callstack deeper?
                            _new_vm[@ PROG_VM.CURRENT_THIS] = _inst;
                            
                            var _vars = _new_vm[PROG_VM.SCOPE][PROG_SCOPE.VARS];
                            for (var j = 0; j < _arg_count; j++)
                            {
                                _vars[$ $"arg{j}"] = _args_arr[j];
                            }
                            _vars[$ "argc"] = _arg_count;
                            
                            proglang_vm_run(_new_vm, _class.constructor_code);
                            proglang_vm_free(_new_vm);
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
                        }
                        break;
                        
                    // Iteration
                    case PROG_OP.ITER_INIT:
                        var _coll = _stack[--_sp];
                        var _mode = _arg; // 0: Default, 1: Key, 2: Value, 3: Pair
                        var _iter = undefined;
                        
                        // Check for range object (array with "range" marker)
                        if (is_array(_coll) && array_length(_coll) >= 3 && _coll[0] == "range")
                        {
                            // Range iterator: [1]=start, [2]=end (inclusive)
                            _iter = { type: "range_iter", current: _coll[1], range_end: _coll[2], done: false }
                        }
                        else if (is_array(_coll))
                        {
                            _iter = { type: "array_iter", val: _coll, idx: 0, len: array_length(_coll) }
                        }
                        else if (is_struct(_coll))
                        {
                            if (_mode == 0)
                            {
                                runtime_error(PROGLANG_ERROR_TYPE.RUNTIME, "Iterating struct with 'in' requires explicit 'key' or 'value' modifier.");
                            }
                            
                            var _keys = struct_get_names(_coll);
                            _iter = { type: "struct_iter", val: _coll, keys: _keys, idx: 0, len: array_length(_keys) }
                        }
                        else
                        {
                            _iter = { type: "empty", idx: 0, len: 0 }
                        }
                        _stack[@ _sp++] = _iter;
                        break;
                    
                    case PROG_OP.ITER_NEXT:
                        var _iter = _stack[_sp - 1]; // Peek
                        if (_iter.type == "range_iter")
                        {
                            if (!_iter.done && _iter.current <= _iter.range_end)
                            {
                                var _val = _iter.current;
                                _iter.current++;
                                if (_iter.current > _iter.range_end) _iter.done = true;
                                _stack[@ _sp++] = _val;
                                _stack[@ _sp++] = true;
                            }
                            else
                            {
                                _stack[@ _sp++] = false;
                            }
                        }
                        else if (_iter.idx < _iter.len)
                        {
                            var _key = undefined;
                            if (_iter.type == "array_iter") _key = _iter.idx;
                            else if (_iter.type == "struct_iter") _key = _iter.keys[_iter.idx];
                            
                            _iter.idx++;
                            _stack[@ _sp++] = _key;
                            _stack[@ _sp++] = true;
                        }
                        else
                        {
                            _stack[@ _sp++] = false;
                        }
                        break;
                    
                    case PROG_OP.ITER_GET_VAL:
                        var _iter = _stack[_sp - 1]; // Peek
                        var _val = undefined;
                        if (_iter.type == "range_iter")
                        {
                            _val = _iter.current - 1; // Current was already incremented
                        }
                        else if (_iter.type == "array_iter")
                        {
                            _val = _iter.val[_iter.idx - 1];
                        }
                        else if (_iter.type == "struct_iter")
                        {
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
                        var _scope_file = proglang_vm_find_var_scope(_vm, "__filename");
                        if (_scope_file != undefined)
                            _cur_file = _scope_file[PROG_SCOPE.VARS][$ "__filename"];
                        
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
                        
                    // ========== NEW V2 OPS ==========
                    
                    case PROG_OP.IN_CHECK:
                        // lhs in rhs: string in string, value in array
                        // Structs require explicit 'in key' or 'in value'
                        var _rhs = _stack[--_sp];
                        var _lhs = _stack[--_sp];
                        var _result = false;
                        if (is_string(_rhs) && is_string(_lhs))
                        {
                            _result = (string_pos(_lhs, _rhs) > 0);
                        }
                        else if (is_array(_rhs))
                        {
                            for (var i = 0; i < array_length(_rhs); i++)
                            {
                                if (_rhs[i] == _lhs)
                                {
                                    _result = true;
                                    break;
                                }
                            }
                        }
                        _stack[@ _sp++] = _result;
                        break;
                        
                    case PROG_OP.IN_KEY:
                        // lhs in key rhs: check if key exists in struct
                        var _rhs = _stack[--_sp];
                        var _lhs = _stack[--_sp];
                        var _result = false;
                        if (is_struct(_rhs))
                        {
                            _result = struct_exists(_rhs, _lhs);
                        }
                        _stack[@ _sp++] = _result;
                        break;
                        
                    case PROG_OP.IN_VALUE:
                        // lhs in value rhs: check if value exists in struct values
                        var _rhs = _stack[--_sp];
                        var _lhs = _stack[--_sp];
                        var _result = false;
                        if (is_struct(_rhs))
                        {
                            var _names = struct_get_names(_rhs);
                            for (var i = 0; i < array_length(_names); i++)
                            {
                                if (_rhs[$ _names[i]] == _lhs)
                                {
                                    _result = true;
                                    break;
                                }
                            }
                        }
                        _stack[@ _sp++] = _result;
                        break;
                        
                    case PROG_OP.MAKE_RANGE:
                        // Create range object [type, start, end, current]
                        var _end = _stack[--_sp];
                        var _start = _stack[--_sp];
                        // Using array for performance: [0]=type, [1]=start, [2]=end
                        var _range = ["range", _start, _end];
                        _stack[@ _sp++] = _range;
                        break;
                }
            }
        } catch (_vm_exception) {
                var _try_stack = _vm[PROG_VM.TRY_STACK];
                if (array_length(_try_stack) == 0) throw _vm_exception;
                
                var _handler = _try_stack[array_length(_try_stack) - 1];
                
                // Allow handler even if fp seems "earlier" (e.g. 0 vs 0), 
                // as long as it's in the stack it was pushed by this VM instance.
                
                array_pop(_try_stack);
                
                // Unwind Frames until we reach handler's FP
                while (_fp > _handler.fp)
                {
                    _gref = _frames[--_fp];
                    _curr_bytecode = _frames[--_fp];
                    _scope = _frames[--_fp];
                    _bp = _frames[--_fp];
                    _ip = _frames[--_fp];
                }
                
                // Restore VM state to match unwind
                _vm[@ PROG_VM.SCOPE] = _scope;
                _vm[@ PROG_VM.GLOBAL_REF] = _gref;
                
                // Restore Handler Context
                _code = _curr_bytecode.code;
                _constants = _curr_bytecode.constants;
                _len = array_length(_code);
                _ip = _handler.ip;
                _vm[@ PROG_VM.SCOPE] = _scope;
                
                // Push error to stack
                _sp = _handler.sp;
                _stack[@ _sp++] = _vm_exception;
                
                continue; // Back into the instruction loop
            }
            
            // Loop exit (implicit return)
            if (_fp > _start_fp)
            {
                var _ret_val = undefined;
                
                // Return Value placement
                // Previous stack: [... Caller Locals ... | Callee | Arg1 ... ArgN | ... Callee Locals ...]
                // BP was pointing to Arg1.
                // We want to reset SP to point to Callee position, and place return value there.
                // Callee was at BP - 1.
                
                _sp = _bp - 1;
                _stack[@ _sp++] = _ret_val;
                
                _gref = _frames[--_fp];
                _curr_bytecode = _frames[--_fp];
                _scope = _frames[--_fp];
                _bp = _frames[--_fp]; // RESTORE CALLER BP
                _ip = _frames[--_fp];
                
                _vm[@ PROG_VM.SCOPE] = _scope;
                _vm[@ PROG_VM.GLOBAL_REF] = _gref;
                
                _code = _curr_bytecode.code;
                _constants = _curr_bytecode.constants;
                _len = array_length(_code);
            }
            else
            {
                return undefined;
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

function proglang_vm_create_impl()
{
    var _vm = array_create(PROG_VM.SIZE);
    _vm[PROG_VM.STACK] = array_create(1024);
    _vm[PROG_VM.FRAME_STACK] = array_create(256); // Initial frame stack
    _vm[PROG_VM.SP] = 0;
    _vm[PROG_VM.IP] = 0;
    _vm[PROG_VM.BP] = 0;
    _vm[PROG_VM.FP] = 0;
    
    // Initial scope
    var _scope = array_create(PROG_SCOPE.SIZE);
    _scope[PROG_SCOPE.VARS] = {}
    _scope[PROG_SCOPE.PARENT] = undefined;
    
    _vm[PROG_VM.SCOPE] = _scope;
    _vm[PROG_VM.CONTEXT] = undefined;
    _vm[PROG_VM.GLOBAL_REF] = {}
    _vm[PROG_VM.TRY_STACK] = [];
    _vm[PROG_VM.ACTIVE_MODULE] = undefined;
    // _vm[PROG_VM.CALL_STACK] = [];
    _vm[PROG_VM.CURRENT_THIS] = undefined;
    _vm[PROG_VM.ACTIVE_CLASS] = undefined;
    _vm[PROG_VM.CLASS_REGISTRY] = {}
    
    return _vm;
}

/// @desc Acquire a VM instance (from pool or new)
/// @returns {Array<PROG_VM>}
function proglang_vm_create()
{
    proglang_vm_pool_init();
    
    global.proglang_vm_alloc_count++;
    
    // Auto-GC check
    if (global.proglang_vm_alloc_count >= global.proglang_vm_gc_threshold)
    {
        proglang_vm_gc();
        global.proglang_vm_alloc_count = 0;
    }
    
    if (array_length(global.proglang_vm_pool) > 0)
    {
        var _vm = array_pop(global.proglang_vm_pool);
        proglang_vm_reset(_vm);
        return _vm;
    }
    
    return proglang_vm_create_impl();
}

/// @desc Release a VM instance back to the pool
/// @param {Array<PROG_VM>} _vm
function proglang_vm_free(_vm)
{
    proglang_vm_pool_init();
    
    if (array_length(global.proglang_vm_pool) < global.proglang_vm_pool_max)
    {
        proglang_vm_reset(_vm);
        array_push(global.proglang_vm_pool, _vm);
    }
}

/// @desc Garbage collection - clear unused VMs from pool
function proglang_vm_gc()
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
    throw { type: _type, message: _msg, stacktrace: debug_get_callstack() }
}