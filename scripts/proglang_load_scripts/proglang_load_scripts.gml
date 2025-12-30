/// @desc Proglang Script Loading and Path Resolution
/// Handles loading .daydream files with secure path traversal

/// Base directory for all proglang scripts (sandbox root)
#macro PROGLANG_BASE_DIR ($"{PROGRAM_DIRECTORY_RESOURCES}/data/scripts")

global.proglang_scripts = {}
global.proglang_exports = {}
global.proglang_modules = {}

/// @desc Initialize proglang by recursively loading all .daydream scripts
/// @param {string} _directory Directory to load from
/// @param {string} _namespace Namespace prefix for scripts
function init_proglang_recursive(_directory, _namespace = "") {
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; i++) {
        var _file = _files[i];
        var _subdirectory = $"{_directory}/{_file}";
        var _rel_path = _namespace == "" ? _file : $"{_namespace}/{_file}";
        
        // Recurse into subdirectories
        if (directory_exists(_subdirectory)) {
            init_proglang_recursive(_subdirectory, _rel_path);
            continue;
        }
        
        // Only process .daydream files
        if (!string_ends_with(_file, ".daydream")) continue;
        
        var _filename = string_delete(_file, string_length(_file) - 8, 9); // Remove .daydream
        var _script_id = _namespace == "" ? _filename : $"{_namespace}/{_filename}";
        
        var _source = buffer_load_text(_subdirectory);
        if (_source == undefined)
        {
            if (IS_DEVELOPER_MODE) show_debug_message($"[Daydream] Failed to load: {_script_id}");
            continue;
        }
        
        var _bytecode = proglang_compile(_source);
        if (_bytecode == undefined)
        {
            if (IS_DEVELOPER_MODE) show_debug_message($"[Daydream] Failed to compile: {_script_id}");
            continue;
        }
        
        var _has_functions = false;
        var _file_scope = {}
        
        // Scan for function definitions (supports both struct and array format)
        for (var j = 0; j < array_length(_bytecode.constants); j++) {
            var _const = _bytecode.constants[j];
            var _is_func = false;
            var _func_name = "";
            var _func_bc = undefined;
            var _func_is_global = false;
            
            // Check for array format (PROG_FUNC enum)
            if (is_array(_const) && array_length(_const) >= PROG_FUNC.SIZE && _const[PROG_FUNC.TYPE] == "function") {
                _is_func = true;
                _func_name = _const[PROG_FUNC.NAME];
                _func_bc = _const[PROG_FUNC.BYTECODE];
                _func_is_global = _const[PROG_FUNC.IS_GLOBAL];
            }
            // Legacy struct format
            else if (is_struct(_const) && struct_exists(_const, "type") && _const.type == "function") {
                _is_func = true;
                _func_name = _const.name;
                _func_bc = _const.bytecode;
                _func_is_global = _const.is_global;
            }
            
            if (_is_func) {
                _has_functions = true;
                if (_func_is_global) {
                    global.proglang_exports[$ _func_name] = _func_bc;
                    if (IS_DEVELOPER_MODE) show_debug_message($"[Daydream] Exported: {_func_name} from {_script_id}");
                } else {
                    _file_scope[$ _func_name] = _func_bc;
                }
            }
        }
        
        if (!_has_functions) {
            global.proglang_scripts[$ _script_id] = _bytecode;
            if (IS_DEVELOPER_MODE) show_debug_message($"[Daydream] Loaded script: {_script_id}");
        } else {
            // Array-based module storage (PROG_MODULE enum)
            var _module_arr = array_create(PROG_MODULE.SIZE);
            _module_arr[PROG_MODULE.MAIN] = _bytecode;
            _module_arr[PROG_MODULE.SCOPE] = _file_scope;
            global.proglang_scripts[$ _script_id] = _module_arr;
            if (IS_DEVELOPER_MODE) show_debug_message($"[Daydream] Loaded module: {_script_id}");
        }
    }
}

/// @desc Resolve a relative path from a base directory with security checks
/// @param {string} _path The path to resolve (can include ../ and ./)
/// @param {string} _current_dir The directory of the importing file (relative to base)
/// @returns {string|undefined} Resolved path or undefined if security violation
function proglang_resolve_path(_path, _current_dir = "") {
    _path = string_replace_all(_path, "\\", "/");
    _current_dir = string_replace_all(_current_dir, "\\", "/");
    
    /*
    // Remove .daydream extension if present
    if (string_ends_with(_path, ".daydream")) {
        _path = string_copy(_path, 1, string_length(_path) - 9);
    }
    */
    
    var _result_parts = [];
    
    // Get root parts for security check
    var _root = PROGLANG_BASE_DIR;
    var _root_parts = proglang_split_path(_root);
    var _root_len = array_length(_root_parts);
    
    // Start with current directory parts if relative path
    if (_current_dir != "" && (string_pos("./", _path) == 1 || string_pos("../", _path) == 1)) {
        var _dir_parts = proglang_split_path(_current_dir);
        for (var i = 0; i < array_length(_dir_parts); i++) {
            if (_dir_parts[i] != "") array_push(_result_parts, _dir_parts[i]);
        }
    }
    
    // Process path segments
    var _path_parts = proglang_split_path(_path);
    for (var i = 0; i < array_length(_path_parts); i++) {
        var _seg = _path_parts[i];
        
        if (_seg == "" || _seg == ".") {
            continue;
        } else if (_seg == "..") {
            // SECURITY: Don't allow going above base directory
            // If _current_dir is absolute (contains root), we must stay within _root_len
            // If _current_dir is empty (virtual path from root), we must stay within virtual root (0)
            var _min_parts = (_current_dir == "") ? 0 : _root_len;
            
            if (array_length(_result_parts) > _min_parts) {
                array_pop(_result_parts);
            } else {
                if (IS_DEVELOPER_MODE) show_debug_message("[Daydream] PATH_SECURITY: Cannot access parent of base directory: " + _root);
                return undefined;
            }
        } else {
            array_push(_result_parts, _seg);
        }
    }
    
    // Rebuild path
    var _resolved = "";
    for (var i = 0; i < array_length(_result_parts); i++) {
        if (i > 0) _resolved += "/";
        _resolved += _result_parts[i];
    }
    
    return _resolved;
}

/// @desc Split path into segments
/// @param {string} _path Path to split
/// @returns {array} Array of path segments
function proglang_split_path(_path) {
    var _parts = [];
    var _current = "";
    var _len = string_length(_path);
    
    for (var i = 1; i <= _len; i++) {
        var _char = string_char_at(_path, i);
        if (_char == "/" || _char == "\\") {
            if (_current != "") {
                array_push(_parts, _current);
                _current = "";
            }
        } else {
            _current += _char;
        }
    }
    if (_current != "") array_push(_parts, _current);
    
    return _parts;
}

/// @desc Get the directory portion of a file path
/// @param {string} _path Full file path
/// @returns {string} Directory path
function proglang_get_directory(_path) {
    _path = string_replace_all(_path, "\\", "/");
    var _last_slash = 0;
    for (var i = string_length(_path); i >= 1; i--) {
        if (string_char_at(_path, i) == "/") {
            _last_slash = i;
            break;
        }
    }
    if (_last_slash > 0) {
        return string_copy(_path, 1, _last_slash - 1);
    }
    return "";
}

/// @desc Load a module by resolved path (lazy loading)
/// @param {string} _module_path Module path
/// @param {string} _importer_path Path of importing file
/// @returns {struct|undefined} Module exports
function proglang_load_module(_module_path, _importer_path = "") {
    var _importer_dir = proglang_get_directory(_importer_path);
    var _is_relative = (string_pos("./", _module_path) == 1 || string_pos("../", _module_path) == 1);
    
    // For relative paths, resolve from importer's actual directory
    // For absolute paths, use the standard base directory
    var _full_path;
    var _resolved;
    
    if (_is_relative && _importer_dir != "") {
        // Relative import: resolve from the importing file's directory
        _resolved = proglang_resolve_path(_module_path, _importer_dir);
        // (IS_DEVELOPER_MODE) show_debug_message($"[Daydream] Resolving relative path: '{_module_path}' from '{_importer_dir}' -> '{_resolved}'");
        if (_resolved == undefined) {
            throw { type: PROGLANG_ERROR_TYPE.PATH_SECURITY, message: $"Path security violation: '{_module_path}'" }
        }
        //_full_path = $"{PROGLANG_BASE_DIR}/{_resolved}";
        _full_path = _resolved;
    } else {
        // Absolute import: use base directory
        _resolved = proglang_resolve_path(_module_path, "");
        // if (IS_DEVELOPER_MODE) show_debug_message($"[Daydream] Resolving absolute path: '{_module_path}' -> '{_resolved}'");
        if (_resolved == undefined) {
            throw { type: PROGLANG_ERROR_TYPE.PATH_SECURITY, message: $"Path security violation: '{_module_path}'" }
        }
        _full_path = $"{PROGLANG_BASE_DIR}/{_resolved}";
    }
    
    // Check if already loaded
    if (struct_exists(global.proglang_modules, _resolved)) {
        return global.proglang_modules[$ _resolved].exports;
    }
    
    // Try to load the file
    if (!file_exists(_full_path)) {
        throw { type: PROGLANG_ERROR_TYPE.FILE_NOT_FOUND, message: $"Module not found: '{_full_path}'" }
    }
    
    var _source = buffer_load_text(_full_path);
    var _bytecode = proglang_compile(_source);
    
    if (_bytecode == undefined) {
        throw { type: PROGLANG_ERROR_TYPE.SYNTAX, message: $"Failed to compile module: '{_full_path}'" }
    }
    
    // Create module entry
    global.proglang_modules[$ _resolved] = { exports: {}, loaded: false, path: _resolved }
    
    // Run module to populate exports
    var _vm = ProgVM_create();
    
    _vm[@ PROG_VM.ACTIVE_MODULE] = global.proglang_modules[$ _resolved];
    _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__dirname"] = proglang_get_directory(_full_path);
    _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__filename"] = _full_path;
    
    ProgVM_run(_vm, _bytecode);
    
    ProgVM_free(_vm);
    
    global.proglang_modules[$ _resolved].loaded = true;
    
    return global.proglang_modules[$ _resolved].exports;
}

/// @desc Execute a named script or function
/// @param {string} _name Script/function name
/// @param {array} _args Arguments
/// @param {struct} _context Execution context
/// @returns {any} Result
function proglang_call(_name, _args = [], _context = {}) {
    var _bytecode = undefined;
    
    if (struct_exists(global.proglang_exports, _name)) {
        _bytecode = global.proglang_exports[$ _name];
    } else if (struct_exists(global.proglang_scripts, _name)) {
        var _script = global.proglang_scripts[$ _name];
        // Check for array format (PROG_MODULE)
        if (is_array(_script) && array_length(_script) >= PROG_MODULE.SIZE) {
            _bytecode = _script[PROG_MODULE.MAIN];
        }
        // Legacy struct format
        else if (is_struct(_script) && struct_exists(_script, "main")) {
            _bytecode = _script.main;
        }
        else {
            _bytecode = _script;
        }
    }
    
    if (_bytecode == undefined) {
        if (IS_DEVELOPER_MODE) show_debug_message($"[Daydream] Function not found: {_name}");
        return undefined;
    }
    
    var _vm = ProgVM_create();
    _vm[@ PROG_VM.CONTEXT] = _context;
    
    // Set directory context for import/export resolution
    var _dirname = proglang_get_directory(_name);
    _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__dirname"] = _dirname;
    _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__filename"] = _name;
    
    for (var i = 0; i < array_length(_args); i++) {
        _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ $"arg{i}"] = _args[i];
    }
    _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "argc"] = array_length(_args);
    
    var _result = ProgVM_run(_vm, _bytecode);
    ProgVM_free(_vm);
    return _result;
}
