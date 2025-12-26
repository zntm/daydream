
/// @desc Virtual Machine for Proglang
function ProgVM() constructor {
    stack = [];
    sp = 0;         // Stack Pointer
    ip = 0;         // Instruction Pointer
    
    // SCOPE SYSTEM
    // Instead of simple `locals` map, we have a scope chain.
    // current_scope = { vars: {}, parent: undefined }
    // We maintain 'locals' as a shortcut to current_scope.vars? Or just use current_scope.
    
    current_scope = { vars: {}, parent: undefined };
    locals = current_scope.vars; // Alias for easy access to top scope (optional, but convenient)
    
    context = undefined; // Execution context (instance or struct)
    // Global ref for optimization
    global_ref = global; 
    
    try_stack = []; // Stack of { ip, sp } for exception handling
    
    run = function(_bytecode) {
        var _code = _bytecode.code;
        var _constants = _bytecode.constants;
        var _len = array_length(_code);
        
        // Reset (Only if fresh run? If recursive call, scope is pre-set)
        if (sp != 0) {
            // Inheriting VM state? Usually new VM for call. 
            // So reset is fine.
        } 
        stack = [];
        sp = 0;
        ip = 0;
        try_stack = [];
        
        // Helper to find variable in scope chain
        var _find_var_scope = function(_name) {
            var _s = current_scope;
            while (_s != undefined) {
                if (variable_struct_exists(_s.vars, _name)) return _s;
                _s = _s.parent;
            }
            return undefined;
        };
        
        var _steps = 0;
        
        while (ip < _len) {
            try {
                // Inner Loop for speed
                while (ip < _len) {
                    _steps++;
                    if (_steps > 200000) {
                         show_debug_message("[ProgVM] Infinite Loop Protection Hit!");
                         return undefined;
                    }
                    
                    // Unpack Op and Arg
                    var _op = _code[ip++];
                    var _arg = _code[ip++];
                    
                    switch (_op) {
                
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
                    
                    // 1. Check Scope Chain
                    var _s = _find_var_scope(_name);
                    
                    if (_s != undefined) {
                        push(_s.vars[$ _name]);
                    }
                    // 2. Context (built-in vars like x, y, dt, or MACROS)
                    else if (context != undefined && variable_struct_exists(context, _name)) {
                        var _val = context[$ _name];
                        if (is_method(_val)) push(method_call(_val, []));
                        else push(_val);
                    }
                    // 3. Global Macros
                    else if (variable_global_exists("proglang_macros") && variable_struct_exists(global.proglang_macros, _name)) {
                         var _val = global.proglang_macros[$ _name];
                         if (is_method(_val)) push(method_call(_val, []));
                         else push(_val);
                    }
                    // 4. Global Exports (Functions as Values)
                    else if (variable_global_exists("proglang_exports") && variable_struct_exists(global.proglang_exports, _name)) {
                         push(global.proglang_exports[$ _name]);
                    }
                    // 5. Global Scripts (Scripts as Values)
                    else if (variable_global_exists("proglang_scripts") && variable_struct_exists(global.proglang_scripts, _name)) {
                         push(global.proglang_scripts[$ _name]);
                    }
                    // 6. Global keyword fallback
                    else if (_name == "global") {
                        push(global);
                    }
                    // 7. Global Variable Fallback
                    else if (variable_global_exists(_name)) {
                        push(variable_global_get(_name));
                    }
                    // 8. Fallback: push name as string for potential function registry lookup
                    else {
                        push(_name);
                    }
                    break;
                }
                
                case PROG_OP.STORE: {
                    var _val = peek(); // Ensure Store DOES NOT pop (Expression semantics)
                    var _name = _constants[_arg];
                    
                    // Scope logic:
                    // If it exists in any parent scope, update it there.
                    // If not, create in CURRENT scope (locals).
                    var _s = _find_var_scope(_name);
                    
                    if (_s != undefined) {
                        _s.vars[$ _name] = _val;
                    } 
                    else if (context != undefined && variable_struct_exists(context, _name)) { // Only context if already exists
                        context[$ _name] = _val; // Update context var
                    } 
                    else {
                        // Create in current scope
                        current_scope.vars[$ _name] = _val;
                    }
                    break;
                }
                
                case PROG_OP.MAKE_CLOSURE: {
                    var _func_data = pop(); // The Constant Struct { type, name, bytecode, is_global }
                    // Create Closure
                    // Captures current_scope as its environment
                    var _closure = {
                        type: "closure",
                        bytecode: _func_data.bytecode,
                        name: _func_data.name,
                        env: current_scope
                    };
                    push(_closure);
                    break;
                }
                
                case PROG_OP.LOAD_GLOBAL: {
                    var _name = _constants[_arg];
                      push(global_ref[$ _name]);
                      break;
                }
                
                case PROG_OP.STORE_GLOBAL: {
                     var _val = peek(); // Peeking to match STORE behavior
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
                
                case PROG_OP.JUMP_IF_NULL: {
                     var _val = peek();
                     if (_val == undefined) ip = _arg;
                     break;
                }
                
                case PROG_OP.JUMP_IF_NOT_NULL: {
                     var _val = peek();
                     if (_val != undefined) ip = _arg;
                     break;
                }
                
                // Exceptions
                case PROG_OP.PUSH_TRY: {
                    array_push(try_stack, { ip: _arg, sp: sp });
                    break;
                }
                
                case PROG_OP.POP_TRY: {
                    array_pop(try_stack);
                    break;
                }
                
                case PROG_OP.THROW: {
                    var _ex = pop();
                    throw _ex; // Will be caught by outer loop
                }
                
                // Iteration
                case PROG_OP.ITER_INIT: {
                    var _col = pop();
                    var _iter = { index: 0, source: _col, type: "unknown" };
                    if (is_array(_col)) {
                        _iter.type = "array";
                        _iter.count = array_length(_col);
                    } else if (is_struct(_col)) {
                        _iter.type = "struct";
                        _iter.keys = struct_get_names(_col);
                        _iter.count = array_length(_iter.keys);
                    }
                    push(_iter);
                    break;
                }
                
                case PROG_OP.ITER_NEXT: {
                    var _iter = peek(); // Don't pop iterator, it stays on stack
                    var _has_next = false;
                    var _val = undefined;
                    
                    if (_iter.type == "array") {
                        if (_iter.index < _iter.count) {
                            _has_next = true;
                            _val = _iter.source[_iter.index++];
                        }
                    } else if (_iter.type == "struct") {
                         if (_iter.index < _iter.count) {
                            _has_next = true;
                             // For struct iteration, usually iterate keys or values?
                             // "for key in struct" -> key.
                             // "for (key, val) in struct"? My parser only supports single var: "for x in y".
                             // Usually "for key in struct".
                             _val = _iter.keys[_iter.index++];
                         }
                    }
                    
                    if (_has_next) {
                        push(_val);
                        push(true);
                    } else {
                        push(false);
                    }
                    break;
                }
                
                // Spread / Array Building
                case PROG_OP.PUSH_ARRAY_EMPTY: {
                    push([]); 
                    break;
                }
                
                case PROG_OP.ARRAY_PUSH: {
                    var _val = pop();
                    var _arr = peek();
                    array_push(_arr, _val);
                    break;
                }
                
                case PROG_OP.ARRAY_SPREAD: {
                    var _src = pop();
                    var _arr = peek();
                    if (is_array(_src)) {
                        array_copy(_arr, array_length(_arr), _src, 0, array_length(_src));
                    }
                    break;
                }
                
                // ----------------------------------------------------------------------
                // CALL HANDLERS (with Closure support)
                // ----------------------------------------------------------------------
                case PROG_OP.CALL_SPREAD: {
                    var _callee = pop();
                    var _args = pop(); // Args Array
                    var _res = undefined;
                    
                    if (is_method(_callee) || is_numeric(_callee)) {
                        _res = method_call(_callee, _args);
                    }
                    else if (is_struct(_callee) && variable_struct_exists(_callee, "type") && _callee.type == "closure") { 
                        // CLOSURE CALL
                        var _sub_vm = new ProgVM();
                        _sub_vm.context = context;
                        
                        // New Scope: Parent is Closure Env
                        _sub_vm.current_scope.parent = _callee.env;
                        
                        for (var j = 0; j < array_length(_args); j++) {
                            _sub_vm.current_scope.vars[$ $"arg{j}"] = _args[j];
                        }
                        _sub_vm.current_scope.vars[$ "argc"] = array_length(_args);
                        
                        _res = _sub_vm.run(_callee.bytecode);
                    }
                    else if (is_struct(_callee) && variable_struct_exists(_callee, "code")) { // Simple Bytecode (no closure env?)
                        // Legacy support or direct bytecode
                        var _sub_vm = new ProgVM();
                        _sub_vm.context = context;
                        for (var j = 0; j < array_length(_args); j++) {
                            _sub_vm.current_scope.vars[$ $"arg{j}"] = _args[j];
                        }
                        _sub_vm.current_scope.vars[$ "argc"] = array_length(_args);
                        _res = _sub_vm.run(_callee);
                    }
                    else if (is_string(_callee)) {
                        // Check built-in functions
                        var _fn_data = (variable_global_exists("proglang_functions") ? global.proglang_functions[$ _callee] : undefined);
                        if (_fn_data != undefined) {
                            _res = _fn_data.func(_args, context);
                        }
                        // Check global exports
                        else if (variable_global_exists("proglang_exports") && variable_struct_exists(global.proglang_exports, _callee)) {
                             var _export_bc = global.proglang_exports[$ _callee];
                             var _sub_vm = new ProgVM();
                             _sub_vm.context = context;
                             for (var j = 0; j < array_length(_args); j++) {
                                 _sub_vm.current_scope.vars[$ $"arg{j}"] = _args[j];
                             }
                             _sub_vm.current_scope.vars[$ "argc"] = array_length(_args);
                             _res = _sub_vm.run(_export_bc);
                        }
                        // Check loaded scripts (single-function files)
                        else if (variable_global_exists("proglang_scripts") && variable_struct_exists(global.proglang_scripts, _callee)) {
                             var _script = global.proglang_scripts[$ _callee];
                             var _script_bc = _script;
                             if (is_struct(_script) && variable_struct_exists(_script, "main")) {
                                 _script_bc = _script.main;
                             }
                             var _sub_vm = new ProgVM();
                             _sub_vm.context = context;
                             for (var j = 0; j < array_length(_args); j++) {
                                 _sub_vm.current_scope.vars[$ $"arg{j}"] = _args[j];
                             }
                             _sub_vm.current_scope.vars[$ "argc"] = array_length(_args);
                             _res = _sub_vm.run(_script_bc);
                        }
                        else if (context != undefined && variable_struct_exists(context, _callee)) {
                             var _ctx_val = context[$ _callee];
                             if (is_method(_ctx_val)) {
                                 _res = method_call(_ctx_val, _args);
                             } else if (is_struct(_ctx_val) && variable_struct_exists(_ctx_val, "type") && _ctx_val.type == "closure") {
                                 // Local Closure Call
                                 var _sub_vm = new ProgVM();
                                 _sub_vm.context = context;
                                 _sub_vm.current_scope.parent = _ctx_val.env;
                                 for (var j = 0; j < array_length(_args); j++) {
                                      _sub_vm.current_scope.vars[$ $"arg{j}"] = _args[j];
                                 }
                                 _sub_vm.current_scope.vars[$ "argc"] = array_length(_args);
                                 _res = _sub_vm.run(_ctx_val.bytecode);

                             } else if (is_struct(_ctx_val) && variable_struct_exists(_ctx_val, "code")) {
                                  // Bytecode call
                                  var _sub_vm = new ProgVM();
                                  _sub_vm.context = context;
                                  for (var j = 0; j < array_length(_args); j++) {
                                      _sub_vm.current_scope.vars[$ $"arg{j}"] = _args[j];
                                  }
                                  _sub_vm.current_scope.vars[$ "argc"] = array_length(_args);
                                  _res = _sub_vm.run(_ctx_val);
                             }
                        } else {
                             // Script asset by name
                             var _asset = asset_get_index(_callee);
                             if (_asset != -1 && asset_get_type(_callee) == asset_script) {
                                 _res = script_execute_ext(_asset, _args);
                             } else {
                                 show_debug_message($"[ProgVM] Unknown Function '{_callee}'");
                             }
                        }
                    }
                    
                    push(_res);
                    break;
                }
                
                case PROG_OP.CALL: {
                     var _argc = _arg;
                     var _callee = pop(); // Function to call
                     
                     var _args = array_create(_argc);
                     for (var i = _argc - 1; i >= 0; i--) {
                         _args[i] = pop();
                     }
                     
                     var _res = undefined;
                     
                      if (is_method(_callee) || is_numeric(_callee)) { // Script ID or Method
                          _res = method_call(_callee, _args);
                      }
                      else if (is_struct(_callee) && variable_struct_exists(_callee, "type") && _callee.type == "closure") { 
                           // CLOSURE CALL
                           var _sub_vm = new ProgVM();
                           _sub_vm.context = context;
                           
                           // New Scope: Parent is Closure Env
                           _sub_vm.current_scope.parent = _callee.env;
                           
                           for (var j = 0; j < array_length(_args); j++) {
                               _sub_vm.current_scope.vars[$ $"arg{j}"] = _args[j];
                           }
                           _sub_vm.current_scope.vars[$ "argc"] = array_length(_args);
                           
                           _res = _sub_vm.run(_callee.bytecode);
                      }
                      else if (is_struct(_callee) && variable_struct_exists(_callee, "code")) { // Bytecode function
                           var _sub_vm = new ProgVM();
                           _sub_vm.context = context;
                           for (var j = 0; j < array_length(_args); j++) {
                               _sub_vm.current_scope.vars[$ $"arg{j}"] = _args[j];
                           }
                           _sub_vm.current_scope.vars[$ "argc"] = array_length(_args);
                           _res = _sub_vm.run(_callee);
                      }
                      else if (is_string(_callee)) { // Named function in Registry
                          // Check built-in functions
                          var _fn_data = (variable_global_exists("proglang_functions") ? global.proglang_functions[$ _callee] : undefined);
                          if (_fn_data != undefined) {
                              _res = _fn_data.func(_args, context); 
                          } 
                          // Check global exports (user-defined global functions)
                          else if (variable_global_exists("proglang_exports") && variable_struct_exists(global.proglang_exports, _callee)) {
                               var _export_bc = global.proglang_exports[$ _callee];
                               var _sub_vm = new ProgVM();
                               _sub_vm.context = context;
                               for (var j = 0; j < array_length(_args); j++) {
                                   _sub_vm.current_scope.vars[$ $"arg{j}"] = _args[j];
                               }
                               _sub_vm.current_scope.vars[$ "argc"] = array_length(_args);
                               _res = _sub_vm.run(_export_bc);
                          }
                          // Check loaded scripts (single-function files)
                          else if (variable_global_exists("proglang_scripts") && variable_struct_exists(global.proglang_scripts, _callee)) {
                               var _script = global.proglang_scripts[$ _callee];
                               var _script_bc = _script;
                               if (is_struct(_script) && variable_struct_exists(_script, "main")) {
                                   _script_bc = _script.main;
                               }
                               var _sub_vm = new ProgVM();
                               _sub_vm.context = context;
                               for (var j = 0; j < array_length(_args); j++) {
                                   _sub_vm.current_scope.vars[$ $"arg{j}"] = _args[j];
                               }
                               _sub_vm.current_scope.vars[$ "argc"] = array_length(_args);
                               _res = _sub_vm.run(_script_bc);
                          }
                          else if (context != undefined && variable_struct_exists(context, _callee)) {
                               var _ctx_val = context[$ _callee];
                               if (is_method(_ctx_val)) {
                                   _res = method_call(_ctx_val, _args);
                               } else if (is_struct(_ctx_val) && variable_struct_exists(_ctx_val, "type") && _ctx_val.type == "closure") {
                                    // Local Closure Call
                                    var _sub_vm = new ProgVM();
                                    _sub_vm.context = context;
                                    _sub_vm.current_scope.parent = _ctx_val.env;
                                    for (var j = 0; j < array_length(_args); j++) {
                                         _sub_vm.current_scope.vars[$ $"arg{j}"] = _args[j];
                                    }
                                    _sub_vm.current_scope.vars[$ "argc"] = array_length(_args);
                                    _res = _sub_vm.run(_ctx_val.bytecode);

                               } else if (is_struct(_ctx_val) && variable_struct_exists(_ctx_val, "code")) {
                                    // Bytecode call from context (local function)
                                    var _sub_vm = new ProgVM();
                                    _sub_vm.context = context;
                                    for (var j = 0; j < array_length(_args); j++) {
                                        _sub_vm.current_scope.vars[$ $"arg{j}"] = _args[j];
                                    }
                                    _sub_vm.current_scope.vars[$ "argc"] = array_length(_args);
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
         } // End Inner Loop
      } catch (_e) { // catch GML error or THROW
          if (array_length(try_stack) > 0) {
              var _handler = array_pop(try_stack);
              ip = _handler.ip;
              sp = _handler.sp;
              push(_e); // Push exception object
              // Loop will continue at new ip
          } else {
              show_debug_message($"[ProgVM] Uncaught Exception: {_e}");
              return undefined;
          }
      }
    } // End Outer Loop
        
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
