/// @desc Virtual Machine for Proglang bytecode execution

enum PROG_ERROR {
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

function ProgVM() constructor {
    // Pre-allocate stack for performance
    stack = array_create(1024);
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
    if (!variable_global_exists("proglang_macros")) {
         global.proglang_macros = {};
    }
    
    active_module = undefined; // Struct { exports: {}, loaded: bool }
    
    // Debug & Stack Trace
    call_stack = []; // Array of { name, line }
    
    // Class System
    current_this = undefined;
    active_class = undefined;
    class_registry = {};
    
    /// @desc Find variable in scope chain
    static find_var_scope = function(_name) {
        var _s = current_scope;
        while (_s != undefined) {
            if (struct_exists(_s.vars, _name)) return _s;
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
            if (is_struct(_callee) && struct_exists(_callee, "__super__")) {
                 var _super_class = _callee.__super__;
                 var _receiver = _callee.receiver;
                 
                 // Look for constructor in super class
                 if (struct_exists(_super_class, "constructor_code") && _super_class.constructor_code != undefined) {
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
            // Handle Array-based Closure (PROG_CLOSURE enum)
            if (is_array(_callee) && array_length(_callee) >= PROG_CLOSURE.SIZE && _callee[PROG_CLOSURE.TYPE] == "closure") {
                var _vm = new ProgVM();
                _vm.context = context;
                // Closure scope chain
                _vm.current_scope.parent = _callee[PROG_CLOSURE.ENV];
                
                // Set defining class for super calls
                if (_callee[PROG_CLOSURE.DEFINING_CLASS] != undefined) {
                    _vm.active_class = _callee[PROG_CLOSURE.DEFINING_CLASS];
                }
                
                // Copy call stack for debugging (reference copy)
                _vm.call_stack = variable_clone(call_stack); 
                
                // Set 'this' context if bound
                if (_callee[PROG_CLOSURE.RECEIVER] != undefined) {
                     _vm.current_this = _callee[PROG_CLOSURE.RECEIVER];
                }
                
                for (var j = 0; j < array_length(_args); j++) {
                    _vm.current_scope.vars[$ $"arg{j}"] = _args[j];
                }
                _vm.current_scope.vars[$ "argc"] = array_length(_args);
                var _res = _vm.run(_callee[PROG_CLOSURE.BYTECODE]);
                array_pop(call_stack);
                return _res;
            }
            
            // Legacy struct closure support
            if (is_struct(_callee) && struct_exists(_callee, "type") && _callee.type == "closure") {
                var _vm = new ProgVM();
                _vm.context = context;
                _vm.current_scope.parent = _callee.env;
                
                if (struct_exists(_callee, "defining_class")) {
                    _vm.active_class = _callee.defining_class;
                }
                
                _vm.call_stack = variable_clone(call_stack); 
                
                if (struct_exists(_callee, "receiver")) {
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
            if (is_struct(_callee) && struct_exists(_callee, "func")) {
                 var _res = _callee.func(_args);
                 array_pop(call_stack);
                 return _res;
            }
            
            // String name lookup
            if (is_string(_callee)) {
                
                if (struct_exists(global.proglang_functions, _callee)) {
                    var _f = global.proglang_functions[$ _callee];
                    var _res = _f.func(_args);
                    array_pop(call_stack);
                    return _res;
                }
                
                if (struct_exists(global.proglang_scripts, _callee)) {
                    var _script = global.proglang_scripts[$ _callee];
                    var _bc = undefined;
                    
                    // Handle array-based module (PROG_MODULE)
                    if (is_array(_script) && array_length(_script) >= PROG_MODULE.SIZE) {
                        _bc = _script[PROG_MODULE.MAIN];
                    }
                    // Handle legacy struct module
                    else if (is_struct(_script) && struct_exists(_script, "main")) {
                        _bc = _script.main;
                    } 
                    else {
                        _bc = _script;
                    }
                    
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
                if (context != undefined && struct_exists(context, _callee)) {
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
                        case PROG_OP.POP: {
                            if (sp > 0) sp--;
                            else show_debug_message($"[ProgVM CRITICAL] STACK UNDERFLOW at IP {ip}");
                            break;
                        }
                        case PROG_OP.DUP: _stack[@ sp] = _stack[sp - 1]; sp++; break;
                        case PROG_OP.DUP2: {
                             var _v1 = _stack[sp - 1];
                             var _v2 = _stack[sp - 2];
                             _stack[@ sp++] = _v2;
                             _stack[@ sp++] = _v1;
                             break;
                        }
                        
                        case PROG_OP.POP_AND_KEEP: {
                            var _top = _stack[--sp];
                            sp--; // Pop second
                            _stack[@ sp++] = _top; // Push top back
                            break;
                        }
                        
                        // Optimization Ops
                        case PROG_OP.INC: _stack[sp - 1]++; break;
                        case PROG_OP.DEC: _stack[sp - 1]--; break;

                        // Arithmetic
                        case PROG_OP.ADD: { 
                            var _b = _stack[--sp]; 
                            var _a = _stack[sp - 1];
                            if (is_real(_a) && is_real(_b)) {
                                _stack[sp - 1] = _a + _b;
                            } else {
                                if (is_string(_a) || is_string(_b)) {
                                    var _sa = is_bool(_a) ? (_a ? "true" : "false") : string(_a);
                                    var _sb = is_bool(_b) ? (_b ? "true" : "false") : string(_b);
                                    _stack[sp - 1] = _sa + _sb;
                                } else if (is_undefined(_a) || is_undefined(_b)) {
                                    runtime_error(PROG_ERROR.UNDEFINED_VALUE, "Undefined value in addition.");
                                } else {
                                    _stack[sp - 1] = _a + _b; 
                                }
                            }
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
                            else if (variable_global_exists("proglang_functions") && struct_exists(global.proglang_functions, _name)) {
                                _stack[@ sp++] = global.proglang_functions[$ _name];
                            }
                            else { 
                                // Relax strictness for "argN" (implicit arguments) if missing
                                if (string_pos("arg", _name) == 1 && string_digits(_name) == string_delete(_name, 1, 3)) {
                                    _stack[@ sp++] = undefined;
                                } else {
                                    runtime_error(PROG_ERROR.VARIABLE, $"Variable '{_name}' not found.");
                                }
                            }
                            break;
                        }
                        
                        case PROG_OP.STORE: {
                            var _val = _stack[sp - 1]; // Peek
                            var _name = _constants[_arg];
                            var _s = find_var_scope(_name);
                            
                            // show_debug_message($"[ProgVM] STORE '{_name}' = {_val}");
                            
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
                        
                        case PROG_OP.PUSH_SCOPE:
                            current_scope = { vars: {}, parent: current_scope };
                            break;
                            
                        case PROG_OP.POP_SCOPE:
                            if (current_scope.parent != undefined) {
                                current_scope = current_scope.parent;
                            } else {
                                runtime_error(PROG_ERROR.RUNTIME, "Scope underflow");
                            }
                            break;
                        

                        case PROG_OP.MAKE_CLOSURE: {
                            var _func = _stack[--sp];
                            
                            // Check for array format (PROG_FUNC) - this is the standard path now
                            if (is_array(_func) && array_length(_func) >= PROG_FUNC.SIZE) {
                                var _closure_arr = array_create(PROG_CLOSURE.SIZE);
                                _closure_arr[PROG_CLOSURE.TYPE] = "closure";
                                _closure_arr[PROG_CLOSURE.BYTECODE] = _func[PROG_FUNC.BYTECODE];
                                _closure_arr[PROG_CLOSURE.ENV] = current_scope;
                                _closure_arr[PROG_CLOSURE.NAME] = _func[PROG_FUNC.NAME];
                                _closure_arr[PROG_CLOSURE.PARAM_COUNT] = _func[PROG_FUNC.PARAM_COUNT];
                                // DEFINING_CLASS and RECEIVER are undefined by default (array_create)
                                _stack[@ sp++] = _closure_arr;
                            }
                            // Fallback for legacy struct format (mostly for tests/manually created bytecode)
                            else if (is_struct(_func)) {
                                var _closure = { type: "closure", bytecode: _func.bytecode, name: _func.name, env: current_scope };
                                if (struct_exists(_func, "param_count")) _closure.param_count = _func.param_count;
                                _stack[@ sp++] = _closure;
                            }
                            else {
                                runtime_error(PROG_ERROR.TYPE, "MAKE_CLOSURE expects a function constant");
                            }
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
                            if (is_struct(_obj) && struct_exists(_obj, "__super__")) {
                                var _super_class = _obj.__super__;
                                var _receiver = _obj.receiver;
                                
                                // Look in super class methods (walk up the chain)
                                var _curr = _super_class;
                                var _found = false;
                                while (_curr != undefined) {
                                    if (struct_exists(_curr.methods, _prop)) {
                                         var _method_entry = _curr.methods[$ _prop];
                                         // Create PROG_CLOSURE array for super bound method
                                         _val = array_create(PROG_CLOSURE.SIZE);
                                         _val[PROG_CLOSURE.TYPE] = "closure";
                                         _val[PROG_CLOSURE.BYTECODE] = _method_entry.bytecode;
                                         _val[PROG_CLOSURE.ENV] = current_scope;
                                         _val[PROG_CLOSURE.NAME] = _prop;
                                         _val[PROG_CLOSURE.PARAM_COUNT] = struct_exists(_method_entry, "param_count") ? _method_entry.param_count : 0;
                                         _val[PROG_CLOSURE.DEFINING_CLASS] = _curr;
                                         _val[PROG_CLOSURE.RECEIVER] = _receiver;
                                         _found = true;
                                         break;
                                    }
                                    _curr = _curr.super_class;
                                }
                                if (!_found) {
                                     runtime_error(PROG_ERROR.MEMBER, $"Property '{_prop}' not found in super class.");
                                }
                            }
                            // Regular instance lookup
                            else if (is_struct(_obj)) {
                                if (struct_exists(_obj, _prop)) {
                                    _val = _obj[$ _prop];
                                } else if (struct_exists(_obj, "__class__")) {
                                     // Instance Method lookup
                                     var _class = _obj.__class__;
                                     var _found = false;
                                     var _curr = _class;
                                     while (_curr != undefined) {
                                          if (struct_exists(_curr.methods, _prop)) {
                                               var _method_entry = _curr.methods[$ _prop];
                                               // Create PROG_CLOSURE array
                                                _val = array_create(PROG_CLOSURE.SIZE);
                                                _val[PROG_CLOSURE.TYPE] = "closure";
                                                _val[PROG_CLOSURE.BYTECODE] = _method_entry.bytecode;
                                                _val[PROG_CLOSURE.ENV] = current_scope;
                                                _val[PROG_CLOSURE.NAME] = _prop;
                                                _val[PROG_CLOSURE.PARAM_COUNT] = struct_exists(_method_entry, "param_count") ? _method_entry.param_count : 0;
                                                _val[PROG_CLOSURE.DEFINING_CLASS] = _curr;
                                                _val[PROG_CLOSURE.RECEIVER] = _obj;
                                               _found = true;
                                               break;
                                          }
                                          _curr = _curr.super_class;
                                     }
                                     if (!_found) _val = undefined;
                                } else if (struct_exists(_obj, "statics") && struct_exists(_obj, "methods")) {
                                     // Class Descriptor - Static Lookup
                                     if (struct_exists(_obj.statics, _prop)) {
                                          var _entry = _obj.statics[$ _prop];
                                          // Distinguish between static method and static field
                                          if (is_struct(_entry) && struct_exists(_entry, "bytecode")) {
                                              // Static method - return PROG_CLOSURE array
                                              // Static methods don't have 'receiver' (this), but have 'defining_class'?
                                              // Usually statics don't access instance 'this'.
                                              _val = array_create(PROG_CLOSURE.SIZE);
                                              _val[PROG_CLOSURE.TYPE] = "closure";
                                              _val[PROG_CLOSURE.BYTECODE] = _entry.bytecode;
                                              _val[PROG_CLOSURE.ENV] = current_scope;
                                              _val[PROG_CLOSURE.NAME] = _prop;
                                              _val[PROG_CLOSURE.PARAM_COUNT] = struct_exists(_entry, "param_count") ? _entry.param_count : 0;
                                              // _val[PROG_CLOSURE.DEFINING_CLASS] = _obj; // Maybe?
                                          } else if (is_struct(_entry) && struct_exists(_entry, "type") && _entry.type == "field") {
                                              // Static field - return the value directly
                                              _val = _entry.value;
                                          } else {
                                              // Fallback: treat as raw value
                                              _val = _entry;
                                          }
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
                            if (is_struct(_obj)) {
                                // Check if this is a class descriptor (for static field assignment)
                                if (struct_exists(_obj, "statics") && struct_exists(_obj, "methods")) {
                                    // Class descriptor - update static field
                                    if (struct_exists(_obj.statics, _prop)) {
                                        var _entry = _obj.statics[$ _prop];
                                        if (is_struct(_entry) && struct_exists(_entry, "type") && _entry.type == "field") {
                                            _entry.value = _val;
                                        } else {
                                            _obj.statics[$ _prop] = _val;
                                        }
                                    } else {
                                        // New static field
                                        _obj.statics[$ _prop] = { type: "field", value: _val, access: "public" };
                                    }
                                } else {
                                    // Regular struct
                                    _obj[$ _prop] = _val;
                                }
                            }
                            else if (is_numeric(_obj) && instance_exists(_obj)) variable_instance_set(_obj, _prop, _val);
                            _stack[@ sp++] = _val;
                            break;
                        }
                        
                        // ...
                        
                        case PROG_OP.CLASS_DEF: {
                            var _desc = _constants[_arg]; // Class Descriptor
                            // Resolve super class if string name
                            if (_desc.super_class != undefined && is_string(_desc.super_class)) {
                                if (struct_exists(current_scope.vars, _desc.super_class)) {
                                    _desc.super_class = current_scope.vars[$ _desc.super_class];
                                } else if (struct_exists(class_registry, _desc.super_class)) {
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
                            
                            // Initialize instance fields with their default values
                            if (struct_exists(_class, "fields")) {
                                for (var f = 0; f < array_length(_class.fields); f++) {
                                    var _field = _class.fields[f];
                                    _inst[$ _field.name] = _field.value;
                                }
                            }
                            
                            // Call constructor
                            if (struct_exists(_class, "constructor_code") && _class.constructor_code != undefined) {
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
                            if (current_this == undefined || !struct_exists(current_this, "__class__")) {
                                runtime_error(PROG_ERROR.RUNTIME, "'super' used outside of class instance.");
                            }
                            var _class = undefined;
                            
                            if (active_class != undefined) {
                                // If we are in a method, use its defining class to find super
                                _class = active_class;
                            } else if (current_this != undefined && struct_exists(current_this, "__class__")) {
                                // Fallback for script context (though super shouldn't be valid here?)
                                _class = current_this.__class__;
                            } else {
                                runtime_error(PROG_ERROR.RUNTIME, "'super' used outside of class context.");
                            }
                            
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
                            var _name = is_string(_func) ? _func : ((is_struct(_func) && struct_exists(_func, "name")) ? _func.name : "<anonymous>");
                            
                            _stack[@ sp++] = exec_call(_func, _args, _line, _name);
                            break;
                        }
                        
                        case PROG_OP.IMPORT: {
                             var _path = _constants[_arg];
                             // Get current file's path for relative resolution
                             var _current_file = struct_exists(current_scope.vars, "__filename") 
                                 ? current_scope.vars[$ "__filename"] : "";
                             try {
                                 var _exports = proglang_load_module(_path, _current_file);
                                 _stack[@ sp++] = _exports;
                             } catch (_e) {
                                 // Re-throw with context
                                 if (is_struct(_e) && struct_exists(_e, "type")) {
                                     throw _e;
                                 }
                                 runtime_error(PROG_ERROR.IMPORT, $"Failed to import '{_path}': {_e}");
                             }
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
                        case PROG_OP.JUMP_IF_FALSE: {
                            var _val = _stack[--sp];
                            // Robust Truthy Check: undefined, false, 0 are Falsy. "red", true, 1 are Truthy.
                            var _cond = true;
                            if (_val == false || _val == undefined || _val == 0) _cond = false;
                            
                            // Special case: empty string? Javascript says "" is false. GML?
                            if (is_string(_val) && _val == "") _cond = false;

                            if (!_cond) ip = _arg; 
                            break;
                        }
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
                        
                        case PROG_OP.MAKE_REGEX: {
                            var _flags = _stack[--sp];
                            var _pattern = _stack[--sp];
                            _stack[@ sp++] = new GMLRegex(_pattern, _flags);
                            break;
                        }

                        case PROG_OP.ITER_INIT: {
                            var _col = _stack[--sp];
                            var _iter = { collection: _col, index: 0, keys: undefined };
                            if (is_struct(_col)) _iter.keys = struct_get_names(_col);
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
                             var _name = is_struct(_func) && struct_exists(_func, "name") ? _func.name : "<anonymous>";
                             _stack[@ sp++] = exec_call(_func, _args, _line, _name);
                             break;
                        }

                        case PROG_OP.LOAD_THIS: _stack[@ sp++] = current_this; break;
                        case PROG_OP.ACCESS_CHECK: {
                            // Validate access level for member access
                            // Stack: [member_name, access_level ("public", "private", "protected"), object]
                            // For now, just check if private is being accessed from outside class
                            var _access = _constants[_arg];
                            if (_access == "private") {
                                // Private members should only be accessed from within the same class
                                // This is a simplified check - full implementation would track calling context
                                // For now, we allow it (strictness can be enabled later)
                            }
                            break;
                        }



                    }
                }
            } catch (_e) {
                if (array_length(try_stack) > 0) {
                    var _handler = array_pop(try_stack);
                    ip = _handler.ip;
                    sp = _handler.sp;
                    _stack[@ sp++] = _e;
                } else {
                    // Propagate unhandled exception so calling VM can catch it
                    throw _e;
                }
            }
        }
        
        return undefined;
    }
    
    // External access methods
    static push = function(_val) { stack[@ sp++] = _val; }
    static pop = function() { return stack[@ --sp]; }
    static peek = function() { return stack[sp - 1]; }
    
    /// @desc Throw a runtime error with type, message, and optional line number
    /// @param {enum} _type PROG_ERROR type
    /// @param {string} _message Error message
    /// @param {real} _line Line number (optional, defaults to 0)
    static runtime_error = function(_type, _message, _line = 0) {
        throw { type: _type, message: _message, line: _line };
    }
}
