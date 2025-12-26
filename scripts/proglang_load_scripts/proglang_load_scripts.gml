
/// @desc Load all .daydream scripts from datafiles/proglang/
global.proglang_scripts = {};
global.proglang_exports = {}; // Global functions and variables

function proglang_load_scripts() {
    var _dir = "proglang/";
    
    if (!directory_exists(_dir)) {
        show_debug_message("[Proglang] No proglang directory found.");
        return;
    }
    
    var _file = file_find_first(_dir + "*.daydream", 0);
    var _count = 0;
    
    while (_file != "") {
        var _filename = string_replace(_file, ".daydream", "");
        var _path = _dir + _file;
        
        // Read file contents
        var _source = buffer_load_text(_path);
        
        // Compile
        var _bytecode = proglang_compile(_source);
        if (_bytecode != undefined) {
            // Check if file has function definitions
            var _has_functions = false;
            var _file_scope = {}; // Local functions within this file
            
            // Scan constants for function definitions
            for (var i = 0; i < array_length(_bytecode.constants); i++) {
                var _const = _bytecode.constants[i];
                if (is_struct(_const) && struct_exists(_const, "type") && _const.type == "function") {
                    _has_functions = true;
                    var _func_name = _const.name;
                    var _func_bc = _const.bytecode;
                    
                    if (_const.is_global) {
                        // Register as global export
                        global.proglang_exports[$ _func_name] = _func_bc;
                        show_debug_message($"[Proglang] Exported global function: {_func_name}");
                    } else {
                        // File-local function
                        _file_scope[$ _func_name] = _func_bc;
                    }
                }
            }
            
            if (!_has_functions) {
                // No fn/function declarations = entire file is single implicit function
                global.proglang_scripts[$ _filename] = _bytecode;
                show_debug_message($"[Proglang] Loaded script: {_filename}");
            } else {
                // Store file scope for local function access within this file
                global.proglang_scripts[$ _filename] = {
                    main: _bytecode,
                    scope: _file_scope
                };
                show_debug_message($"[Proglang] Loaded module: {_filename}");
            }
            
            _count++;
        } else {
            show_debug_message($"[Proglang] Failed to compile: {_file}");
        }
        
        _file = file_find_next();
    }
    file_find_close();
    
    show_debug_message($"[Proglang] Loaded {_count} scripts/modules.");
}

/// @desc Execute a named function (global export or script)
/// @param {string} _name Function name
/// @param {array} _args Arguments to pass
/// @param {struct} _context Execution context
function proglang_call(_name, _args = [], _context = {}) {
    var _bytecode = undefined;
    
    // Check global exports first
    if (struct_exists(global.proglang_exports, _name)) {
        _bytecode = global.proglang_exports[$ _name];
    }
    // Then check scripts
    else if (struct_exists(global.proglang_scripts, _name)) {
        var _script = global.proglang_scripts[$ _name];
        if (is_struct(_script) && struct_exists(_script, "main")) {
            _bytecode = _script.main;
        } else {
            _bytecode = _script;
        }
    }
    
    if (_bytecode == undefined) {
        show_debug_message($"[Proglang] Function not found: {_name}");
        return undefined;
    }
    
    var _vm = new ProgVM();
    _vm.context = _context;
    
    // Pass arguments as arg0, arg1, etc.
    for (var i = 0; i < array_length(_args); i++) {
        _vm.locals[$ $"arg{i}"] = _args[i];
    }
    _vm.locals[$ "argc"] = array_length(_args);
    
    return _vm.run(_bytecode);
}
