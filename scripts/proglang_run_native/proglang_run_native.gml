function proglang_run_native(_bytecode) {
    // 1. Serialize if not already a buffer
    var _buffer = undefined;
    if (is_struct(_bytecode)) {
        _buffer = proglang_serialize(_bytecode);
    } else {
        _buffer = _bytecode;
    }

    // 2. Create and Load VM
    var _handle = proglang_vm_create();
    var _ptr = buffer_get_address(_buffer);
    var _size = buffer_get_size(_buffer);
    
    if (proglang_vm_load(_handle, _ptr, _size) <= 0) {
        proglang_vm_destroy(_handle);
        throw "Failed to load bytecode into Native VM";
    }

    // 3. Inject Global Macros
    var _names = variable_struct_get_names(global.proglang_macros);
    for (var i = 0; i < array_length(_names); i++) {
        var _name = _names[i];
        var _val = global.proglang_macros[$ _name];
        if (is_real(_val) || is_bool(_val)) proglang_vm_define_global_double(_handle, _name, real(_val));
        else if (is_string(_val)) proglang_vm_define_global_string(_handle, _name, _val);
    }

    // 4. Execution Loop with Yield Handling
    var _status = proglang_vm_run(_handle);
    
    while (_status == 2) { // YIELD_EXTERNAL_CALL
        var _arg_count = proglang_vm_get_yield_arg_count(_handle);
        var _callee_name = proglang_vm_get_yield_callee_string(_handle);
        
        // Pop args from native stack back to GML
        var _args = array_create(_arg_count);
        for (var i = _arg_count - 1; i >= 0; i--) {
            // We need a way to check if it's string or double
            // For now let's assume built-ins take doubles or we add a type checker
            _args[i] = proglang_vm_pop_double(_handle);
        }
        proglang_vm_pop_double(_handle); // Pop callee itself

        // Execute Call in GML
        var _result = undefined;
        if (variable_struct_exists(global.proglang_functions, _callee_name)) {
            var _func = global.proglang_functions[$ _callee_name];
            _result = script_execute_ext(_func, _args);
        } else {
            // Check for standard lib functions
            _result = proglang_call_gml_builtin(_callee_name, _args);
        }

        // Push result back
        if (is_real(_result) || is_bool(_result)) proglang_vm_push_double(_handle, real(_result));
        else if (is_string(_result)) proglang_vm_push_string(_handle, _result);
        else proglang_vm_push_double(_handle, 0); // Nil/Null

        // Resume
        _status = proglang_vm_run(_handle);
    }

    // 5. Cleanup and Return Result
    var _final_result = undefined;
    if (_status == 1 || _status == 0) {
        _final_result = proglang_vm_pop_double(_handle);
    } else {
        show_debug_message("Native VM Error status: " + string(_status));
    }

    proglang_vm_destroy(_handle);
    if (is_struct(_bytecode)) buffer_delete(_buffer);

    return _final_result;
}

function proglang_call_gml_builtin(_name, _args) {
    // This handles things like print(), trace(), etc.
    switch (_name) {
        case "print":
        case "trace":
            var _s = "";
            for(var i=0; i<array_length(_args); i++) _s += string(_args[i]) + " ";
            show_debug_message(_s);
            return undefined;
        case "get_timer": return get_timer();
        case "random": return random(_args[0]);
        case "irandom": return irandom(_args[0]);
        // ... add more as needed
    }
    return undefined;
}
