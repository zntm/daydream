/// @desc Virtual Machine for Proglang bytecode execution

enum PROG_ERROR {
    NONE = 0,
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
    IMPORT
}

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
    
    // Module System
    if (!variable_global_exists("proglang_modules")) {
        global.proglang_modules = {};
    }
    if (!variable_global_exists("proglang_constants")) {
         global.proglang_constants = {};
    }
    
    active_module = undefined; // Struct { exports: {}, loaded: bool }
    
    // Debug & Stack Trace
    call_stack = []; // Array of { name, line }
    
    // Class System
    current_this = undefined;
    class_registry = {};
    
    // Inject constants into global scope (or create a 'constants' scope?)
    // For simplicity, we can treat them as globals or pre-defined vars.
    // Let's add them to the initial locals if they are globally available.
    // Or better, handle LOAD_GLOBAL to look there too.
    // For now, let's copy them to current scope (simplest for access like PROG_ERROR.TYPE)
    var _names = variable_struct_get_names(global.proglang_constants);
    for (var i = 0; i < array_length(_names); i++) {
        var _name = _names[i];
        current_scope.vars[$ _name] = global.proglang_constants[$ _name];
    }
    
    /// @desc Find variable in scope chain
    static find_var_scope = function(_name) {
        var _s = current_scope;
        while (_s != undefined) {
            if (variable_struct_exists(_s.vars, _name)) return _s;
            _s = _s.parent;
        }
        return undefined;
    };
    

    /// @desc Call a function/script/closure
    static exec_call = function(_callee, _args, _line = 0, _callee_name = "<anonymous>") {
        // Push call stack frame
        array_push(call_stack, { name: _callee_name, line: _line });
        
        // show_debug_message($"[ProgVM] CALL {_callee_name} args: {_args}");

        try {
            // Super Constructor Call via super(...)
            // Parser emits Call(SuperExpr, args). SuperExpr emits LOAD_SUPER -> SuperReference.
            if (is_struct(_callee) && variable_struct_exists(_callee, "__super__")) {
                 var _super_class = _callee.__super__;
                 var _receiver = _callee.receiver;
                 
                 // Look for constructor in super class
                 if (variable_struct_exists(_super_class, "constructor_code") && _super_class.constructor_code != undefined) {
                     var _vm = new ProgVM();
                     _vm.context = context;
                     _vm.call_stack = variable_clone(call_stack);
                     _vm.current_this = _receiver;
                     
                     for (var j = 0; j < array_length(_args); j++) {
                         _vm.current_scope.vars[$ $"arg{j}"] = _args[j];
                     }
                     _vm.current_scope.vars[$ "argc"] = array_length(_args);
                     
                     var _res = _vm.run(_super_class.constructor_code);
                     array_pop(call_stack);
                     return _res;
                 } else {
                     // No constructor in super, just return (default constructor)
                     array_pop(call_stack);
                     return undefined;
                 }
            }
            
            // Function struct (closure or built-in wrapper)
            if (is_struct(_callee) && variable_struct_exists(_callee, "type") && _callee.type == "closure") {
                var _vm = new ProgVM();
                _vm.context = context;
                // Closure scope chain
                _vm.current_scope.parent = _callee.env;
                
                // Copy call stack for debugging (reference copy)
                _vm.call_stack = variable_clone(call_stack); 
                
                // Set 'this' context if bound
                if (variable_struct_exists(_callee, "receiver")) {
                     _vm.current_this = _callee.receiver;
                }
                
                for (var j = 0; j < array_length(_args); j++) {
                    _vm.current_scope.vars[$ $"arg{j}"] = _args[j];
                }
                _vm.current_scope.vars[$ "argc"] = array_length(_args);
                var _res = _vm.run(_callee.bytecode);
                array_pop(call_stack);
                return _res;
            }
            
            // Built-in function
            if (is_struct(_callee) && variable_struct_exists(_callee, "func")) {
                 var _res = _callee.func(_args);
                 array_pop(call_stack);
                 return _res;
            }
            
            // String name lookup
            if (is_string(_callee)) {
                
                if (variable_struct_exists(global.proglang_functions, _callee)) {
                    var _f = global.proglang_functions[$ _callee];
                    var _res = _f.func(_args);
                    // show_debug_message($"[ProgVM] Builtin Call {_callee} Result: {_res}");
                    array_pop(call_stack);
                    return _res;
                }
                
                if (variable_struct_exists(global.proglang_scripts, _callee)) {
                    var _script = global.proglang_scripts[$ _callee];
                    var _bc = is_struct(_script) && variable_struct_exists(_script, "main") ? _script.main : _script;
                    
                    var _vm = new ProgVM();
                    _vm.context = context;
                    _vm.call_stack = variable_clone(call_stack);
                    
                    for (var j = 0; j < array_length(_args); j++) {
                        _vm.current_scope.vars[$ $"arg{j}"] = _args[j];
                    }
                    _vm.current_scope.vars[$ "argc"] = array_length(_args);
                    var _res = _vm.run(_bc);
                    array_pop(call_stack);
                    return _res;
                }
                
                // Context value
                if (context != undefined && variable_struct_exists(context, _callee)) {
                     var _res = exec_call(context[$ _callee], _args, _line, _callee);
                     array_pop(call_stack);
                     return _res;
                }
                
                // GML script asset
                var _asset = asset_get_index(_callee);
                if (_asset != -1 && asset_get_type(_callee) == asset_script) {
                    var _res = script_execute_ext(_asset, _args);
                    array_pop(call_stack);
                    return _res;
                }
            }

        } catch (_e) {
             array_pop(call_stack);
             throw _e;
        }
        
        array_pop(call_stack);
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
                        case PROG_OP.ADD: { 
                            var _b = _stack[--sp]; 
                            var _a = _stack[sp - 1];
                            if (is_undefined(_a) || is_undefined(_b)) {
                                runtime_error(PROG_ERROR.UNDEFINED_VALUE, "Undefined value in addition.");
                            }
                            _stack[sp - 1] = _a + _b; 
                            break; 
                        }
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
                            
                            
                            if (_s != undefined) { 
                                var _val = _s.vars[$ _name];
                                // show_debug_message($"[ProgVM] LOAD '{_name}' from scope: {_val}");
                                _stack[@ sp++] = _val; 
                            }
                            else if (context != undefined && variable_struct_exists(context, _name)) {
                                var _val = context[$ _name];
                                _stack[@ sp++] = is_method(_val) ? method_call(_val, []) : _val;
                            }
                            else if (variable_global_exists("proglang_macros") && variable_struct_exists(global.proglang_macros, _name)) {
                                var _val = global.proglang_macros[$ _name];
                                _stack[@ sp++] = is_method(_val) ? method_call(_val, []) : _val;
                            }
                            else if (variable_global_exists("proglang_exports") && variable_struct_exists(global.proglang_exports, _name)) {
                                _stack[@ sp++] = global.proglang_exports[$ _name];
                            }
                            else if (variable_global_exists("proglang_scripts") && variable_struct_exists(global.proglang_scripts, _name)) {
                                _stack[@ sp++] = global.proglang_scripts[$ _name];
                            }
                            else if (_name == "global") { _stack[@ sp++] = global; }
                            else if (variable_global_exists(_name)) { _stack[@ sp++] = variable_global_get(_name); }
                            else if (variable_global_exists("proglang_functions") && variable_struct_exists(global.proglang_functions, _name)) {
                                _stack[@ sp++] = global.proglang_functions[$ _name];
                            }
                            else { 
                                // show_debug_message($"[ProgVM] LOAD '{_name}' FAILED. Return undefined.");
                                _stack[@ sp++] = undefined; 
                            }
                            break;
                        }
                        
                        case PROG_OP.STORE: {
                            var _val = _stack[sp - 1]; // Peek
                            var _name = _constants[_arg];
                            var _s = find_var_scope(_name);
                            
                            // show_debug_message($"[ProgVM] STORE '{_name}' = {_val}");
                            
                            if (_s != undefined) { _s.vars[$ _name] = _val; }
                            else if (context != undefined && variable_struct_exists(context, _name)) { context[$ _name] = _val; }
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
                            if (variable_struct_exists(_func, "param_count")) _closure.param_count = _func.param_count;
                            _stack[@ sp++] = _closure;
                            break;
                        }
                        
                        // Structure Access
                        case PROG_OP.INDEX_GET: {
                            var _idx = _stack[--sp];
                            var _arr = _stack[--sp];
                            var _result = is_array(_arr) ? _arr[_idx] : (is_struct(_arr) ? _arr[$ _idx] : undefined);
                            // show_debug_message($"[ProgVM DEBUG] INDEX_GET: arr={_arr} idx={_idx} result={_result}");
                            _stack[@ sp++] = _result;
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
                            var _val = undefined;
                            
                            // Super lookup
                            if (is_struct(_obj) && variable_struct_exists(_obj, "__super__")) {
                                var _super_class = _obj.__super__;
                                var _receiver = _obj.receiver;
                                
                                // Look in super class methods
                                if (variable_struct_exists(_super_class.methods, _prop)) {
                                     var _method_entry = _super_class.methods[$ _prop];
                                     // Create bound closure
                                     _val = { 
                                         type: "closure", 
                                         bytecode: _method_entry.bytecode, 
                                         receiver: _receiver,
                                         env: current_scope 
                                     };
                                } else {
                                     runtime_error(PROG_ERROR.MEMBER, $"Property '{_prop}' not found in super class.");
                                }
                            }
                            // Regular instance lookup
                            else if (is_struct(_obj)) {
                                if (variable_struct_exists(_obj, _prop)) {
                                    _val = _obj[$ _prop];
                                } else if (variable_struct_exists(_obj, "__class__")) {
                                     // Instance Method lookup
                                     var _class = _obj.__class__;
                                     var _found = false;
                                     var _curr = _class;
                                     while (_curr != undefined) {
                                          if (variable_struct_exists(_curr.methods, _prop)) {
                                               var _method_entry = _curr.methods[$ _prop];
                                               _val = { 
                                                   type: "closure", 
                                                   bytecode: _method_entry.bytecode, 
                                                   receiver: _obj,
                                                   env: current_scope 
                                               };
                                               _found = true;
                                               break;
                                          }
                                          _curr = _curr.super_class;
                                     }
                                     if (!_found) _val = undefined;
                                } else if (variable_struct_exists(_obj, "statics") && variable_struct_exists(_obj, "methods")) {
                                     // Class Descriptor - Static Lookup
                                     if (variable_struct_exists(_obj.statics, _prop)) {
                                          var _entry = _obj.statics[$ _prop];
                                          _val = {
                                              type: "closure",
                                              bytecode: _entry.bytecode,
                                              env: current_scope
                                          };
                                     }
                                }
                            }
                            
                            if (is_undefined(_val) && !is_struct(_obj)) {
                                 // GML struct or other
                                 runtime_error(PROG_ERROR.MEMBER, $"Cannot read property '{_prop}' of non-struct.");
                            }
                            
                            _stack[@ sp++] = _val;
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
                        
                        // ...
                        
                        case PROG_OP.CLASS_DEF: {
                            var _desc = _constants[_arg]; // Class Descriptor
                            // Resolve super class if string name
                            if (_desc.super_class != undefined && is_string(_desc.super_class)) {
                                if (variable_struct_exists(current_scope.vars, _desc.super_class)) {
                                    _desc.super_class = current_scope.vars[$ _desc.super_class];
                                } else if (variable_struct_exists(class_registry, _desc.super_class)) {
                                    _desc.super_class = class_registry[$ _desc.super_class];
                                }
                            }
                            // Register in current scope
                            current_scope.vars[$ _desc.name] = _desc;
                            // Also global registry?
                            class_registry[$ _desc.name] = _desc;
                            break;
                        }
                        
                        case PROG_OP.NEW_INSTANCE: {
                            var _arg_count = _arg;
                            var _class = _stack[--sp]; // Class Descriptor
                            
                            if (!is_struct(_class)) {
                                runtime_error(PROG_ERROR.TYPE, "Attempted to instantiate non-class.");
                            }
                            
                            var _inst = { __class__: _class };
                            
                            // Call constructor
                            if (variable_struct_exists(_class, "constructor_code") && _class.constructor_code != undefined) {
                                var _args_arr = array_create(_arg_count);
                                for (var i = _arg_count - 1; i >= 0; i--) _args_arr[i] = _stack[--sp];
                                
                                var _vm = new ProgVM();
                                _vm.context = context;
                                _vm.call_stack = variable_clone(call_stack);
                                _vm.current_this = _inst; // Bind 'this'
                                
                                // Params
                                for (var j = 0; j < _arg_count; j++) {
                                     _vm.current_scope.vars[$ $"arg{j}"] = _args_arr[j];
                                }
                                _vm.current_scope.vars[$ "argc"] = _arg_count;
                                
                                _vm.run(_class.constructor_code);
                            } else {
                                // Pop args if no constructor
                                sp -= _arg_count; 
                            }
                            
                            _stack[@ sp++] = _inst;
                            break;
                        }
                        
                        case PROG_OP.LOAD_SUPER: {
                            if (current_this == undefined || !variable_struct_exists(current_this, "__class__")) {
                                runtime_error(PROG_ERROR.RUNTIME, "'super' used outside of class instance.");
                            }
                            var _class = current_this.__class__;
                            if (_class.super_class == undefined) {
                                runtime_error(PROG_ERROR.RUNTIME, "Class has no super class.");
                            }
                            // Push wrapper to indicate super lookup
                            _stack[@ sp++] = { __super__: _class.super_class, receiver: current_this };
                            break;
                        }
                        
                        case PROG_OP.CALL: {
                            var _arg_count = _arg;
                            // Stack: [..., Callee, Arg0, Arg1, ... ArgN]
                            // Callee is at sp - 1 - _arg_count
                            var _func = _stack[sp - 1 - _arg_count];
                            
                            var _args = array_create(_arg_count);
                            for (var i = _arg_count - 1; i >= 0; i--) {
                                _args[i] = _stack[--sp];
                            }
                            sp--; // Pop func
                            
                            // Line info
                            // Line info
                            var _line_idx = (ip div 2) - 1;
                            var _line = (_line_idx >= 0 && _line_idx < array_length(_bytecode.lines)) ? _bytecode.lines[_line_idx] : 0;
                            var _name = is_string(_func) ? _func : ((is_struct(_func) && variable_struct_exists(_func, "name")) ? _func.name : "<anonymous>");
                            
                            _stack[@ sp++] = exec_call(_func, _args, _line, _name);
                            break;
                        }
                        
                        case PROG_OP.IMPORT: {
                             var _path = _constants[_arg];
                             if (!variable_struct_exists(global.proglang_modules, _path)) {
                                 // Auto-init module entry if missing (lazy loading hook could go here)
                                 global.proglang_modules[$ _path] = { exports: {}, loaded: false };
                             }
                             _stack[@ sp++] = global.proglang_modules[$ _path].exports;
                             break;
                        }
                        
                        case PROG_OP.EXPORT_SET: {
                             var _name = _constants[_arg];
                             var _val = _stack[sp - 1]; // Peek
                             if (active_module != undefined) {
                                 active_module.exports[$ _name] = _val;
                             }
                             break;
                        }

                        case PROG_OP.RETURN: {
                            return _stack[--sp];
                        }

                        case PROG_OP.JUMP: ip = _arg; break;
                        case PROG_OP.JUMP_IF_FALSE: if (!_stack[--sp]) ip = _arg; break;
                        case PROG_OP.JUMP_IF_NULL: if (_stack[--sp] == undefined) ip = _arg; break;
                        case PROG_OP.JUMP_IF_NOT_NULL: if (_stack[sp - 1] != undefined) ip = _arg; break;
                        
                        case PROG_OP.ARRAY_NEW: {
                            var _arr_len = _arg;
                            var _arr = array_create(_arr_len);
                            for (var i = _arr_len - 1; i >= 0; i--) _arr[i] = _stack[--sp];
                            // show_debug_message($"[ProgVM DEBUG] ARRAY_NEW: len={_arr_len} arr={_arr}");
                            _stack[@ sp++] = _arr;
                            break;
                        }
                        
                        case PROG_OP.OBJECT_NEW: {
                            var _pair_count = _arg; // Pairs
                            var _obj = {};
                            for (var i = 0; i < _pair_count; i++) {
                                var _val = _stack[--sp];
                                var _key = _stack[--sp];
                                _obj[$ _key] = _val;
                            }
                            _stack[@ sp++] = _obj;
                            break;
                        }

                        case PROG_OP.ITER_INIT: {
                            var _col = _stack[--sp];
                            var _iter = { collection: _col, index: 0, keys: undefined };
                            if (is_struct(_col)) _iter.keys = variable_struct_get_names(_col);
                            _stack[@ sp++] = _iter;
                            break; 
                        }

                        case PROG_OP.ITER_NEXT: {
                            var _iter = _stack[sp - 1]; // Peek
                            var _has_next = false;
                            if (is_array(_iter.collection)) {
                                if (_iter.index < array_length(_iter.collection)) {
                                    // For arrays: ITER_NEXT provides the Value (first var in "for (v in arr)")
                                    // ITER_GET_VAL provides the Index (second var in "for (v, i in arr)")
                                    _stack[@ sp++] = _iter.collection[_iter.index]; // Push Value
                                    _has_next = true;
                                }
                            } else if (is_struct(_iter.collection)) {
                                if (_iter.index < array_length(_iter.keys)) {
                                    _stack[@ sp++] = _iter.keys[_iter.index]; // Push Key
                                    _has_next = true;
                                }
                            }
                            
                            if (_has_next) {
                                _stack[@ sp++] = true; // Continue
                                _iter.index++; 
                            } else {
                                _stack[@ sp++] = false; // Stop
                            }
                            break;
                        }

                        case PROG_OP.ITER_GET_VAL: {
                            var _iter = _stack[sp - 1]; // Peek
                            // This op is called to get the SECOND variable.
                            // For Array: Index.
                            // For Struct: Value. 
                            // (Test: "for (k, v in obj) sum += v". k is key, v is value.
                            //  Compiler: First var is k (Key from ITER_NEXT), Second is v (Value from ITER_GET_VAL).
                            //  VM Array logic above: ITER_NEXT pushed Value. ITER_GET_VAL should push Index.
                            //  VM Struct logic above: ITER_NEXT pushed Key. ITER_GET_VAL should push Value.
                            
                            if (is_array(_iter.collection)) {
                                _stack[@ sp++] = _iter.index - 1; // Index (already incremented)
                            } else {
                                var _key = _iter.keys[_iter.index - 1];
                                _stack[@ sp++] = _iter.collection[$ _key]; // Value
                            }
                            break;
                        }
                        
                        case PROG_OP.PUSH_TRY: array_push(try_stack, { ip: _arg, sp: sp }); break;
                        case PROG_OP.POP_TRY: array_pop(try_stack); break;
                        case PROG_OP.THROW: throw _stack[--sp]; break;
                        
                        case PROG_OP.PUSH_ARRAY_EMPTY: _stack[@ sp++] = []; break;
                        case PROG_OP.ARRAY_PUSH: {
                            var _val = _stack[--sp];
                            array_push(_stack[sp - 1], _val);
                            break;
                        }
                        case PROG_OP.ARRAY_SPREAD: {
                            var _arr = _stack[--sp];
                            var _target = _stack[sp - 1];
                            if (is_array(_arr)) {
                                for (var i = 0; i < array_length(_arr); i++) array_push(_target, _arr[i]);
                            }
                            break;
                        }
                        
                        case PROG_OP.CALL_SPREAD: {
                             var _func = _stack[--sp];
                             var _args = _stack[--sp];
                             // Exec call
                             var _line_idx = (ip div 2) - 1;
                             var _line = (_line_idx >= 0 && _line_idx < array_length(_bytecode.lines)) ? _bytecode.lines[_line_idx] : 0;
                             var _name = is_struct(_func) && variable_struct_exists(_func, "name") ? _func.name : "<anonymous>";
                             _stack[@ sp++] = exec_call(_func, _args, _line, _name);
                             break;
                        }

                        case PROG_OP.LOAD_THIS: _stack[@ sp++] = current_this; break;
                        case PROG_OP.ACCESS_CHECK: break; // TODO: runtime access checks



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
    
    static runtime_error = function(_type, _message) {
        throw { type: _type, message: _message, line: 0 }; // TODO: Pass line number
    }
}
