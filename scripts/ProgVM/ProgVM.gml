/// @desc Virtual Machine for Proglang bytecode execution
function ProgVM() constructor {
    // Pre-allocate stack for performance
    stack = array_create(256);
    sp = 0;
    ip = 0;
    
    // Scope system with parent chain for closures
    current_scope = { vars: {}, parent: undefined };
    locals = current_scope.vars;
    
    context = undefined;
    global_ref = global;
    try_stack = [];
    
    /// @desc Find variable in scope chain
    static find_var_scope = function(_name) {
        var _s = current_scope;
        while (_s != undefined) {
            if (struct_exists(_s.vars, _name)) return _s;
            _s = _s.parent;
        }
        return undefined;
    };
    
    /// @desc Execute a callee (closure, bytecode, string name, or method)
    static exec_call = function(_callee, _args) {
        // GML method or script ID
        if (is_method(_callee) || is_numeric(_callee)) {
            return method_call(_callee, _args);
        }
        
        // Closure with captured environment
        if (is_struct(_callee) && struct_exists(_callee, "type") && _callee.type == "closure") {
            var _vm = new ProgVM();
            _vm.context = context;
            _vm.current_scope.parent = _callee.env;
            for (var j = 0; j < array_length(_args); j++) {
                _vm.current_scope.vars[$ $"arg{j}"] = _args[j];
            }
            // Optional params: fill with undefined if missing
            if (struct_exists(_callee, "param_count")) {
                 for (var j = array_length(_args); j < _callee.param_count; j++) {
                     _vm.current_scope.vars[$ $"arg{j}"] = undefined;
                 }
            }
            
            _vm.current_scope.vars[$ "argc"] = array_length(_args);
            return _vm.run(_callee.bytecode);
        }
        
        // Raw bytecode struct
        if (is_struct(_callee) && struct_exists(_callee, "code")) {
            var _vm = new ProgVM();
            _vm.context = context;
            for (var j = 0; j < array_length(_args); j++) {
                _vm.current_scope.vars[$ $"arg{j}"] = _args[j];
            }
            _vm.current_scope.vars[$ "argc"] = array_length(_args);
            return _vm.run(_callee);
        }
        
        // String name lookup
        if (is_string(_callee)) {
            // Built-in functions
            if (variable_global_exists("proglang_functions")) {
                var _fn = global.proglang_functions[$ _callee];
                if (_fn != undefined) return _fn.func(_args, context);
            }
            
            // Global exports
            if (variable_global_exists("proglang_exports") && struct_exists(global.proglang_exports, _callee)) {
                var _bc = global.proglang_exports[$ _callee]; // This is likely the Func constant (not closure)
                // If it's a function struct (from compiler), it has param_count? 
                // Wait, global exports might be raw bytecode OR function struct?
                // Compiler emits: STORE_GLOBAL (function index).
                // So proglang_exports has function structs.
                // Let's handle if it is a function struct.
                
                var _vm = new ProgVM();
                _vm.context = context;
                
                // If it is a function struct, it might have param_count
                var _target_bc = _bc;
                var _pcount = 0;
                
                if (struct_exists(_bc, "type") && _bc.type == "function") {
                    _target_bc = _bc.bytecode;
                    if (struct_exists(_bc, "param_count")) _pcount = _bc.param_count;
                }
                
                for (var j = 0; j < array_length(_args); j++) {
                    _vm.current_scope.vars[$ $"arg{j}"] = _args[j];
                }
                for (var j = array_length(_args); j < _pcount; j++) {
                    _vm.current_scope.vars[$ $"arg{j}"] = undefined;
                }
                
                _vm.current_scope.vars[$ "argc"] = array_length(_args);
                return _vm.run(_target_bc);
            }
            
            // Loaded scripts
            if (variable_global_exists("proglang_scripts") && struct_exists(global.proglang_scripts, _callee)) {
                var _script = global.proglang_scripts[$ _callee];
                var _bc = is_struct(_script) && struct_exists(_script, "main") ? _script.main : _script;
                var _vm = new ProgVM();
                _vm.context = context;
                for (var j = 0; j < array_length(_args); j++) {
                    _vm.current_scope.vars[$ $"arg{j}"] = _args[j];
                }
                _vm.current_scope.vars[$ "argc"] = array_length(_args);
                return _vm.run(_bc);
            }
            
            // Context value
            if (context != undefined && struct_exists(context, _callee)) {
                return exec_call(context[$ _callee], _args);
            }
            
            // GML script asset
            var _asset = asset_get_index(_callee);
            if (_asset != -1 && asset_get_type(_callee) == asset_script) {
                return script_execute_ext(_asset, _args);
            }
        }
        
        return undefined;
    };
    
    /// @desc Execute bytecode
    /// @param {struct} _bytecode Compiled bytecode object
    /// @returns {any} Execution result
    run = function(_bytecode) {
        var _code = _bytecode.code;
        var _constants = _bytecode.constants;
        var _len = array_length(_code);
        
        // Reset VM state
        sp = 0;
        ip = 0;
        try_stack = [];
        
        // Local cache for hot-path optimization
        var _stack = stack;
        var _gref = global_ref;
        
        var _steps = 0;
        var _max_steps = 200000;
        
        while (ip < _len) {
            try {
                while (ip < _len) {
                    if (++_steps > _max_steps) {
                        show_debug_message("[ProgVM] Infinite loop protection triggered");
                        return undefined;
                    }
                    
                    var _op = _code[ip++];
                    var _arg = _code[ip++];
                    
                    switch (_op) {
                        // Stack operations
                        case PROG_OP.PUSH_NULL: _stack[@ sp++] = undefined; break;
                        case PROG_OP.PUSH_TRUE: _stack[@ sp++] = true; break;
                        case PROG_OP.PUSH_FALSE: _stack[@ sp++] = false; break;
                        case PROG_OP.PUSH_GLOBAL_REF: _stack[@ sp++] = _gref; break;
                        case PROG_OP.PUSH_CONST: _stack[@ sp++] = _constants[_arg]; break;
                        case PROG_OP.POP: sp--; break;
                        case PROG_OP.DUP: _stack[@ sp] = _stack[sp - 1]; sp++; break;
                        case PROG_OP.DUP2: {
                             var _v1 = _stack[sp - 1];
                             var _v2 = _stack[sp - 2];
                             _stack[@ sp++] = _v2;
                             _stack[@ sp++] = _v1;
                             break;
                        }
                        
                        // Arithmetic
                        case PROG_OP.ADD: { var _b = _stack[--sp]; _stack[sp - 1] += _b; break; }
                        case PROG_OP.SUB: { var _b = _stack[--sp]; _stack[sp - 1] -= _b; break; }
                        case PROG_OP.MUL: { var _b = _stack[--sp]; _stack[sp - 1] *= _b; break; }
                        case PROG_OP.DIV: { var _b = _stack[--sp]; _stack[sp - 1] /= _b; break; }
                        case PROG_OP.MOD: { var _b = _stack[--sp]; _stack[sp - 1] %= _b; break; }
                        case PROG_OP.POW: { var _b = _stack[--sp]; _stack[sp - 1] = power(_stack[sp - 1], _b); break; }
                        case PROG_OP.NEG: _stack[sp - 1] = -_stack[sp - 1]; break;
                        
                        // Comparison
                        case PROG_OP.EQ: { var _b = _stack[--sp]; _stack[sp - 1] = (_stack[sp - 1] == _b); break; }
                        case PROG_OP.NE: { var _b = _stack[--sp]; _stack[sp - 1] = (_stack[sp - 1] != _b); break; }
                        case PROG_OP.LT: { var _b = _stack[--sp]; _stack[sp - 1] = (_stack[sp - 1] < _b); break; }
                        case PROG_OP.GT: { var _b = _stack[--sp]; _stack[sp - 1] = (_stack[sp - 1] > _b); break; }
                        case PROG_OP.LE: { var _b = _stack[--sp]; _stack[sp - 1] = (_stack[sp - 1] <= _b); break; }
                        case PROG_OP.GE: { var _b = _stack[--sp]; _stack[sp - 1] = (_stack[sp - 1] >= _b); break; }
                        
                        // Logical / Bitwise
                        case PROG_OP.NOT: _stack[sp - 1] = !_stack[sp - 1]; break;
                        case PROG_OP.AND: { var _b = _stack[--sp]; _stack[sp - 1] = (_stack[sp - 1] && _b); break; }
                        case PROG_OP.OR: { var _b = _stack[--sp]; _stack[sp - 1] = (_stack[sp - 1] || _b); break; }
                        case PROG_OP.BIT_AND: { var _b = _stack[--sp]; _stack[sp - 1] &= _b; break; }
                        case PROG_OP.BIT_OR: { var _b = _stack[--sp]; _stack[sp - 1] |= _b; break; }
                        case PROG_OP.BIT_XOR: { var _b = _stack[--sp]; _stack[sp - 1] ^= _b; break; }
                        case PROG_OP.SHL: { var _b = _stack[--sp]; _stack[sp - 1] = _stack[sp - 1] << _b; break; }
                        case PROG_OP.SHR: { var _b = _stack[--sp]; _stack[sp - 1] = _stack[sp - 1] >> _b; break; }
                        
                        // Variable Access
                        case PROG_OP.LOAD: {
                            var _name = _constants[_arg];
                            var _s = find_var_scope(_name);
                            
                            if (_s != undefined) { _stack[@ sp++] = _s.vars[$ _name]; }
                            else if (context != undefined && struct_exists(context, _name)) {
                                var _val = context[$ _name];
                                _stack[@ sp++] = is_method(_val) ? method_call(_val, []) : _val;
                            }
                            else if (variable_global_exists("proglang_macros") && struct_exists(global.proglang_macros, _name)) {
                                var _val = global.proglang_macros[$ _name];
                                _stack[@ sp++] = is_method(_val) ? method_call(_val, []) : _val;
                            }
                            else if (variable_global_exists("proglang_exports") && struct_exists(global.proglang_exports, _name)) {
                                _stack[@ sp++] = global.proglang_exports[$ _name];
                            }
                            else if (variable_global_exists("proglang_scripts") && struct_exists(global.proglang_scripts, _name)) {
                                _stack[@ sp++] = global.proglang_scripts[$ _name];
                            }
                            else if (_name == "global") { _stack[@ sp++] = global; }
                            else if (variable_global_exists(_name)) { _stack[@ sp++] = variable_global_get(_name); }
                            else { _stack[@ sp++] = _name; }
                            break;
                        }
                        
                        case PROG_OP.STORE: {
                            var _val = _stack[sp - 1]; // Peek
                            var _name = _constants[_arg];
                            var _s = find_var_scope(_name);
                            
                            if (_s != undefined) { _s.vars[$ _name] = _val; }
                            else if (context != undefined && struct_exists(context, _name)) { context[$ _name] = _val; }
                            else { current_scope.vars[$ _name] = _val; }
                            break;
                        }
                        
                        case PROG_OP.DEFINE: {
                            var _val = _stack[sp - 1]; // Peek
                            var _name = _constants[_arg];
                            current_scope.vars[$ _name] = _val;
                            break;
                        }
                        
                        case PROG_OP.LOAD_GLOBAL: _stack[@ sp++] = _gref[$ _constants[_arg]]; break;
                        case PROG_OP.STORE_GLOBAL: _gref[$ _constants[_arg]] = _stack[sp - 1]; break;
                        
                        case PROG_OP.MAKE_CLOSURE: {
                            var _func = _stack[--sp];
                            var _closure = { type: "closure", bytecode: _func.bytecode, name: _func.name, env: current_scope };
                            if (struct_exists(_func, "param_count")) _closure.param_count = _func.param_count;
                            _stack[@ sp++] = _closure;
                            break;
                        }
                        
                        // Structure Access
                        case PROG_OP.INDEX_GET: {
                            var _idx = _stack[--sp];
                            var _arr = _stack[--sp];
                            _stack[@ sp++] = is_array(_arr) ? _arr[_idx] : (is_struct(_arr) ? _arr[$ _idx] : undefined);
                            break;
                        }
                        
                        case PROG_OP.INDEX_SET: {
                            var _val = _stack[--sp];
                            var _idx = _stack[--sp];
                            var _arr = _stack[--sp];
                            if (is_array(_arr)) _arr[@ _idx] = _val;
                            else if (is_struct(_arr)) _arr[$ _idx] = _val;
                            _stack[@ sp++] = _val;
                            break;
                        }
                        
                        case PROG_OP.MEMBER_GET: {
                            var _prop = _constants[_arg];
                            var _obj = _stack[--sp];
                            if (is_struct(_obj)) { _stack[@ sp++] = _obj[$ _prop]; }
                            else if (is_numeric(_obj) && instance_exists(_obj)) { _stack[@ sp++] = variable_instance_get(_obj, _prop); }
                            else { _stack[@ sp++] = undefined; }
                            break;
                        }
                        
                        case PROG_OP.MEMBER_SET: {
                            var _val = _stack[--sp];
                            var _obj = _stack[--sp];
                            var _prop = _constants[_arg];
                            if (is_struct(_obj)) _obj[$ _prop] = _val;
                            else if (is_numeric(_obj) && instance_exists(_obj)) variable_instance_set(_obj, _prop, _val);
                            _stack[@ sp++] = _val;
                            break;
                        }
                        
                        // Collection Creation
                        case PROG_OP.ARRAY_NEW: {
                            var _count = _arg;
                            var _arr = array_create(_count);
                            for (var i = _count - 1; i >= 0; i--) _arr[i] = _stack[--sp];
                            _stack[@ sp++] = _arr;
                            break;
                        }
                        
                        case PROG_OP.OBJECT_NEW: {
                            var _count = _arg;
                            var _obj = {};
                            for (var i = 0; i < _count; i++) {
                                var _val = _stack[--sp];
                                var _key = _stack[--sp];
                                _obj[$ _key] = _val;
                            }
                            _stack[@ sp++] = _obj;
                            break;
                        }
                        
                        // Control Flow
                        case PROG_OP.JUMP: ip = _arg; break;
                        case PROG_OP.JUMP_IF_FALSE: if (!_stack[--sp]) ip = _arg; break;
                        case PROG_OP.JUMP_IF_NULL: if (_stack[sp - 1] == undefined) ip = _arg; break;
                        case PROG_OP.JUMP_IF_NOT_NULL: if (_stack[sp - 1] != undefined) ip = _arg; break;
                        
                        // Exception Handling
                        case PROG_OP.PUSH_TRY: array_push(try_stack, { ip: _arg, sp: sp }); break;
                        case PROG_OP.POP_TRY: array_pop(try_stack); break;
                        case PROG_OP.THROW: throw _stack[--sp];
                        
                        // Iteration
                        case PROG_OP.ITER_INIT: {
                            var _col = _stack[--sp];
                            var _iter = { index: 0, source: _col, type: "unknown" };
                            if (is_array(_col)) { _iter.type = "array"; _iter.count = array_length(_col); }
                            else if (is_struct(_col)) { _iter.type = "struct"; _iter.keys = struct_get_names(_col); _iter.count = array_length(_iter.keys); }
                            _stack[@ sp++] = _iter;
                            break;
                        }
                        
                        case PROG_OP.ITER_NEXT: {
                            var _iter = _stack[sp - 1];
                            if (_iter.index < _iter.count) {
                                var _val = (_iter.type == "array") ? _iter.source[_iter.index++] : _iter.keys[_iter.index++];
                                _stack[@ sp++] = _val;
                                _stack[@ sp++] = true;
                            } else {
                                _stack[@ sp++] = false;
                            }
                            break;
                        }
                        
                        case PROG_OP.ITER_GET_VAL: {
                             var _iter = _stack[sp - 1]; // Peek iterator
                             var _val = undefined;
                             if (_iter.type == "struct") {
                                  var _key = _iter.keys[_iter.index - 1];
                                  _val = _iter.source[$ _key];
                             } else if (_iter.type == "array") {
                                  _val = _iter.index - 1; // Return index for array (since Key was Element)
                             }
                             _stack[@ sp++] = _val;
                             break;
                        }
                        
                        // Array Spread
                        case PROG_OP.PUSH_ARRAY_EMPTY: _stack[@ sp++] = []; break;
                        case PROG_OP.ARRAY_PUSH: { var _val = _stack[--sp]; array_push(_stack[sp - 1], _val); break; }
                        case PROG_OP.ARRAY_SPREAD: {
                            var _src = _stack[--sp];
                            if (is_array(_src)) array_copy(_stack[sp - 1], array_length(_stack[sp - 1]), _src, 0, array_length(_src));
                            break;
                        }
                        
                        // Function Calls
                        case PROG_OP.CALL_SPREAD: {
                            var _callee = _stack[--sp];
                            var _args = _stack[--sp];
                            _stack[@ sp++] = exec_call(_callee, _args);
                            break;
                        }
                        
                        case PROG_OP.CALL: {
                            var _callee = _stack[--sp];
                            var _args = array_create(_arg);
                            for (var i = _arg - 1; i >= 0; i--) _args[i] = _stack[--sp];
                            _stack[@ sp++] = exec_call(_callee, _args);
                            break;
                        }
                        
                        case PROG_OP.RETURN: return _stack[--sp];
                    }
                }
            } catch (_e) {
                if (array_length(try_stack) > 0) {
                    var _handler = array_pop(try_stack);
                    ip = _handler.ip;
                    sp = _handler.sp;
                    _stack[@ sp++] = _e;
                } else {
                    show_debug_message($"[ProgVM] Uncaught Exception: {_e}");
                    return undefined;
                }
            }
        }
        
        return undefined;
    }
    
    // External access methods
    static push = function(_val) { stack[@ sp++] = _val; }
    static pop = function() { return stack[@ --sp]; }
    static peek = function() { return stack[sp - 1]; }
}
