
/// @desc Virtual Machine for Proglang
function ProgVM() constructor {
    stack = [];
    sp = 0;         // Stack Pointer
    ip = 0;         // Instruction Pointer
    locals = {};    // Local variables map
    context = undefined; // Execution context (instance or struct)
    // Global ref for optimization
    global_ref = global; 
    
    run = function(_bytecode) {
        var _code = _bytecode.code;
        var _constants = _bytecode.constants;
        var _len = array_length(_code);
        
        // Reset
        stack = [];
        sp = 0;
        ip = 0;
        // locals = {}; // DISABLED
        
        while (ip < _len) {
            // Unpack Op and Arg
            var _op = _code[ip++];
            var _arg = _code[ip++];
            
            show_debug_message($"[ProgVM] IP: {ip-2} OP: {_op} ARG: {_arg} STACK_TOP: {sp > 0 ? stack[sp-1] : "empty"}");
            
            switch (_op) {
                // ... (ops)
                case PROG_OP.PUSH_NULL: push(undefined); break;
                case PROG_OP.PUSH_TRUE: push(true); break;
                case PROG_OP.PUSH_FALSE: push(false); break;
                case PROG_OP.PUSH_GLOBAL_REF: push(global_ref); break;
                case PROG_OP.PUSH_CONST: push(_constants[_arg]); break;
                
                case PROG_OP.POP: sp--; break;
                case PROG_OP.DUP: push(peek()); break;
                
                // Arithmetic
                case PROG_OP.ADD: { var _b = pop(); var _a = pop(); push(_a + _b); break; }
                case PROG_OP.SUB: { var _b = pop(); var _a = pop(); push(_a - _b); break; }
                case PROG_OP.MUL: { var _b = pop(); var _a = pop(); push(_a * _b); break; }
                case PROG_OP.DIV: { var _b = pop(); var _a = pop(); push(_a / _b); break; }
                case PROG_OP.MOD: { var _b = pop(); var _a = pop(); push(_a % _b); break; }
                case PROG_OP.POW: { var _b = pop(); var _a = pop(); push(power(_a, _b)); break; }
                
                case PROG_OP.NEG: { var _a = pop(); push(-_a); break; }
                
                // Comparison
                case PROG_OP.EQ: { var _b = pop(); var _a = pop(); push(_a == _b); break; }
                case PROG_OP.NE: { var _b = pop(); var _a = pop(); push(_a != _b); break; }
                case PROG_OP.LT: { var _b = pop(); var _a = pop(); push(_a < _b); break; }
                case PROG_OP.GT: { var _b = pop(); var _a = pop(); push(_a > _b); break; }
                case PROG_OP.LE: { var _b = pop(); var _a = pop(); push(_a <= _b); break; }
                case PROG_OP.GE: { var _b = pop(); var _a = pop(); push(_a >= _b); break; }
                
                // Logical / Bitwise
                case PROG_OP.NOT: { var _a = pop(); push(!_a); break; }
                case PROG_OP.AND: { var _b = pop(); var _a = pop(); push(_a && _b); break; }
                case PROG_OP.OR:  { var _b = pop(); var _a = pop(); push(_a || _b); break; }
                
                case PROG_OP.BIT_AND: { var _b = pop(); var _a = pop(); push(_a & _b); break; }
                case PROG_OP.BIT_OR:  { var _b = pop(); var _a = pop(); push(_a | _b); break; }
                case PROG_OP.BIT_XOR: { var _b = pop(); var _a = pop(); push(_a ^ _b); break; }
                case PROG_OP.SHL:     { var _b = pop(); var _a = pop(); push(_a << _b); break; }
                case PROG_OP.SHR:     { var _b = pop(); var _a = pop(); push(_a >> _b); break; }
                
                // Variable Access
                case PROG_OP.LOAD: {
                    var _name = _constants[_arg];
                    // 1. Local
                    if (struct_exists(locals, _name)) {
                        push(locals[$ _name]);
                    } 
                    // 2. Context (built-in vars like x, y, dt, or MACROS)
                    else if (context != undefined && variable_struct_exists(context, _name)) {
                        var _val = context[$ _name];
                        if (is_method(_val)) push(method_call(_val, []));
                        else push(_val);
                    }
                    // 3. Global Macros
                    else if (variable_global_exists("proglang_macros") && struct_exists(global.proglang_macros, _name)) {
                         var _val = global.proglang_macros[$ _name];
                         if (is_method(_val)) push(method_call(_val, []));
                         else push(_val);
                    }
                    // 4. Global keyword fallback
                    else if (_name == "global") {
                        push(global);
                    }
                    // 5. Global Variable Fallback
                    else if (variable_global_exists(_name)) {
                        push(variable_global_get(_name));
                    }
                    // 6. Fallback
                    else {
                        push(undefined);
                    }
                    break;
                }
                
                case PROG_OP.STORE: {
                    var _val = peek(); // Ensure Store pops? Checked before: Yes, usually DUPs before Store.
                    var _val_popped = pop(); 
                    var _name = _constants[_arg];
                    
                    // Scope logic:
                    if (struct_exists(locals, _name)) {
                        locals[$ _name] = _val_popped;
                    } else if (context != undefined && variable_struct_exists(context, _name)) { // Only context if already exists
                        context[$ _name] = _val_popped;
                    } else {
                        // Default to local
                        locals[$ _name] = _val_popped;
                    }
                    break;
                }
                
                case PROG_OP.LOAD_GLOBAL: {
                    // Not used currently by compiler (uses LOAD "global"?)
                    // If we use specific opcode:
                    var _name = _constants[_arg];
                     push(variable_global_get(_name)); // Can't easily use variable_global_get with struct?
                     // GML global is a struct? `global.variable`.
                     // global[$ _name] works.
                     push(global_ref[$ _name]);
                     break;
                }
                
                case PROG_OP.STORE_GLOBAL: {
                     var _val = pop();
                     var _name = _constants[_arg];
                     global_ref[$ _name] = _val;
                     break;
                }
                
                // Structure Access
                case PROG_OP.INDEX_GET: {
                     var _index = pop();
                     var _arr = pop();
                     // Check type
                     if (is_array(_arr)) push(_arr[_index]);
                     else if (is_struct(_arr)) push(_arr[$ _index]); // Support struct["key"]
                     else push(undefined);
                     break;
                }
                
                case PROG_OP.INDEX_SET: {
                     var _val = pop();
                     var _index = pop();
                     var _arr = pop();
                     if (is_array(_arr)) _arr[@ _index] = _val;
                     else if (is_struct(_arr)) _arr[$ _index] = _val;
                     
                     push(_val); // Pass-through value
                     break;
                }
                
                case PROG_OP.MEMBER_GET: {
                     var _prop = _constants[_arg];
                     var _obj = pop();
                     if (is_struct(_obj)) {
                         var _val = _obj[$ _prop];
                         // Bound method check?
                         if (is_method(_val)) {
                             // If it is a method, is it bound? 
                             // GML methods carry binding.
                             // Proglang should just return it.
                         }
                         push(_val);
                     } else if (is_numeric(_obj) && instance_exists(_obj)) { // Valid Instance ID
                         push(variable_instance_get(_obj, _prop));
                     } else {
                         push(undefined);
                     }
                     break;
                }
                
                case PROG_OP.MEMBER_SET: {
                     var _val = pop();
                     var _obj = pop();
                     var _prop = _constants[_arg];
                     
                     if (is_struct(_obj)) _obj[$ _prop] = _val;
                     else if (is_numeric(_obj) && instance_exists(_obj)) variable_instance_set(_obj, _prop, _val);
                     
                     push(_val); // Pass-through
                     break;
                }
                
                // Creation
                case PROG_OP.ARRAY_NEW: {
                     var _count = _arg;
                     var _arr = array_create(_count);
                     // Stack has elements in order?
                     // Compiler: compile(elem1), compile(elem2)...
                     // Stack: [elem1, elem2, ...] (Top is elemN)
                     // So we fill backwards.
                     for (var i = _count - 1; i >= 0; i--) {
                         _arr[i] = pop();
                     }
                     push(_arr);
                     break;
                }
                
                case PROG_OP.OBJECT_NEW: {
                     var _count = _arg; // Number of pairs
                     var _obj = {};
                     // Stack: [key1, val1, key2, val2 ...] (Top is valN)
                     // Pop backwards
                     for (var i = 0; i < _count; i++) {
                         var _val = pop();
                         var _key = pop(); // Key is pushed as CONST string
                         _obj[$ _key] = _val;
                     }
                     push(_obj);
                     break;
                }
                
                // Control Flow
                case PROG_OP.JUMP: {
                     ip = _arg;
                     break;
                }
                
                case PROG_OP.JUMP_IF_FALSE: {
                     var _val = pop();
                     if (!_val) ip = _arg;
                     break;
                }
                
                // Functions
                case PROG_OP.CALL: {
                     var _argc = _arg;
                     var _callee = pop(); // Function to call
                     
                     // Args are on stack [arg1, arg2...] (Top is argN)
                     // GML script_execute_ext needs array.
                     // Or function call.
                     var _args = array_create(_argc);
                     for (var i = _argc - 1; i >= 0; i--) {
                         _args[i] = pop();
                     }
                     
                     var _res = undefined;
                     
                      if (is_method(_callee) || is_numeric(_callee)) { // Script ID or Method
                          _res = method_call(_callee, _args);
                      }
                      else if (is_struct(_callee) && variable_struct_exists(_callee, "code")) { // Bytecode function (closure/local)
                           var _sub_vm = new ProgVM();
                           _sub_vm.context = context;
                           for (var j = 0; j < array_length(_args); j++) {
                               _sub_vm.locals[$ $"arg{j}"] = _args[j];
                           }
                           _sub_vm.locals[$ "argc"] = array_length(_args);
                           _res = _sub_vm.run(_callee);
                      }
                      else if (is_string(_callee)) { // Named function in Registry?
                          // Check built-in functions
                          var _fn_data = (variable_global_exists("proglang_functions") ? global.proglang_functions[$ _callee] : undefined);
                          if (_fn_data != undefined) {
                              _res = _fn_data.func(_args, context); 
                          } 
                          // Check global exports (user-defined global functions)
                          else if (variable_global_exists("proglang_exports") && struct_exists(global.proglang_exports, _callee)) {
                               var _export_bc = global.proglang_exports[$ _callee];
                               var _sub_vm = new ProgVM();
                               _sub_vm.context = context;
                               for (var j = 0; j < array_length(_args); j++) {
                                   _sub_vm.locals[$ $"arg{j}"] = _args[j];
                               }
                               _sub_vm.locals[$ "argc"] = array_length(_args);
                               _res = _sub_vm.run(_export_bc);
                          }
                          // Check loaded scripts (single-function files)
                          else if (variable_global_exists("proglang_scripts") && struct_exists(global.proglang_scripts, _callee)) {
                               var _script = global.proglang_scripts[$ _callee];
                               var _script_bc = _script;
                               // Handle multi-function module format
                               if (is_struct(_script) && struct_exists(_script, "main")) {
                                   _script_bc = _script.main;
                               }
                               var _sub_vm = new ProgVM();
                               _sub_vm.context = context;
                               for (var j = 0; j < array_length(_args); j++) {
                                   _sub_vm.locals[$ $"arg{j}"] = _args[j];
                               }
                               _sub_vm.locals[$ "argc"] = array_length(_args);
                               _res = _sub_vm.run(_script_bc);
                          }
                          else if (context != undefined && struct_exists(context, _callee)) {
                               var _ctx_val = context[$ _callee];
                               if (is_method(_ctx_val)) {
                                   _res = method_call(_ctx_val, _args);
                               } else if (is_struct(_ctx_val) && variable_struct_exists(_ctx_val, "code")) {
                                    // Bytecode call from context (local function)
                                    var _sub_vm = new ProgVM();
                                    _sub_vm.context = context;
                                    for (var j = 0; j < array_length(_args); j++) {
                                        _sub_vm.locals[$ $"arg{j}"] = _args[j];
                                    }
                                    _sub_vm.locals[$ "argc"] = array_length(_args);
                                    _res = _sub_vm.run(_ctx_val);
                               }
                          } else {
                               // Script asset by name
                               var _asset = asset_get_index(_callee);
                               if (_asset != -1 && asset_get_type(_callee) == asset_script) {
                                   _res = script_execute_ext(_asset, _args);
                               }
                          }
                      }
                     
                     push(_res); // Return value
                     break;
                }
                
                case PROG_OP.RETURN: {
                     var _val = pop();
                     return _val;
                }
            }
        }
        
        return undefined;
    }
    
    static push = function(_val) {
        stack[@ sp++] = _val;
    }
    
    static pop = function() {
        return stack[@ --sp];
    }
    
    static peek = function() {
        return stack[sp - 1];
    }
}
