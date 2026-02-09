/// @desc Proglang Script Loading and Path Resolution
/// Handles loading .daydream files with secure path traversal

/// Base directory for all proglang scripts (sandbox root)
#macro PROGLANG_BASE_DIR ($"{PROGRAM_DIRECTORY_RESOURCES}/data/scripts")

if (!variable_global_exists("proglang_scripts")) global.proglang_scripts = {};
if (!variable_global_exists("proglang_exports")) global.proglang_exports = {};
if (!variable_global_exists("proglang_modules")) global.proglang_modules = {};

/// @desc Initialize proglang by recursively loading all .daydream scripts
/// @param {string} _directory Directory to load from
/// @param {string} _namespace Namespace prefix for scripts
/// @param {string} _path Internal logic for recursion (do not set manually)
function init_proglang_recursive(_directory, _namespace = "", _path = "") {
    show_debug_message($"[Daydream] Init Proglang Recursive Called with: {_directory}");
    
    // Normalize directory separators
    _directory = string_replace_all(_directory, "\\", "/");
    if (string_ends_with(_directory, "/")) _directory = string_delete(_directory, string_length(_directory), 1);

    // Get file list
    var _files = [];
    var _dir_files = [];
    
    // First pass: Collect all files and directories
    var _f = file_find_first($"{_directory}/*", fa_directory);
    while (_f != "") {
        if (_f != "." && _f != "..") {
            array_push(_dir_files, _f);
        }
        _f = file_find_next();
    }
    file_find_close();
    
    // Check which are directories and which are files
    // Note: directory_exists works nicely, but file_exists can be tricky with extensions on some platforms.
    
    var _files_length = array_length(_dir_files);
    
    show_debug_message($"[Daydream] Scanning directory: {_directory} (Found {_files_length} items)");
    
    for (var i = 0; i < _files_length; i++) {
        var _file = _dir_files[i];
        var _full_path = $"{_directory}/{_file}";
        var _rel_path = _path == "" ? _file : $"{_path}/{_file}";
        
        if (directory_exists(_full_path)) {
            // It's a directory, recurse
            init_proglang_recursive(_full_path, _namespace, _rel_path);
        }
        else if (string_ends_with(_file, ".daydream")) {
            // It's a script file
            var _filename = string_replace(_file, ".daydream", "");
            
            // Construct ID
            var _id_path = _path == "" ? _filename : $"{_path}/{_filename}";
            var _script_id = _namespace == "" ? _id_path : $"{_namespace}:{_id_path}";
            
            show_debug_message($"[Daydream] Loading Script: {_script_id} from {_full_path}");
            
            var _source = buffer_load_text(_full_path);
            if (_source == undefined) {
                show_debug_message($"[Daydream] ERROR: Failed to load content for {_script_id}");
                continue;
            }
            
            var _bytecode = proglang_compile(_source);
            if (_bytecode == undefined) {
                show_debug_message($"[Daydream] ERROR: Failed to compile {_script_id}");
                continue;
            }
            
            // Handle Exports / Functions
            var _has_functions = false;
            var _file_scope = {};
            
            for (var j = 0; j < array_length(_bytecode.constants); j++) {
                var _const = _bytecode.constants[j];
                // Support both Array and Struct format for functions
                if (is_array(_const) && array_length(_const) >= PROG_FUNC.SIZE && _const[PROG_FUNC.TYPE] == "function") {
                    if (_const[PROG_FUNC.IS_GLOBAL]) {
                        global.proglang_exports[$ _const[PROG_FUNC.NAME]] = _const[PROG_FUNC.BYTECODE];
                        _has_functions = true;
                    } else {
                        _file_scope[$ _const[PROG_FUNC.NAME]] = _const[PROG_FUNC.BYTECODE];
                        _has_functions = true;
                    }
                }
                else if (is_struct(_const) && struct_exists(_const, "type") && _const.type == "function") {
                    if (_const.is_global) {
                        global.proglang_exports[$ _const.name] = _const.bytecode;
                        _has_functions = true;
                    } else {
                        _file_scope[$ _const.name] = _const.bytecode;
                        _has_functions = true;
                    }
                }
            }
            
            if (!_has_functions) {
                global.proglang_scripts[$ _script_id] = _bytecode;
            } else {
                var _module = array_create(PROG_MODULE.SIZE);
                _module[PROG_MODULE.MAIN] = _bytecode;
                _module[PROG_MODULE.SCOPE] = _file_scope;
                global.proglang_scripts[$ _script_id] = _module;
            }
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
            // Check if the current path starts with the base directory
            var _current_path = "";
            for (var j = 0; j < array_length(_result_parts); j++) {
                if (j > 0) _current_path += "/";
                _current_path += _result_parts[j];
            }
            
            // Determine minimum parts based on whether path is absolute (contains base dir)
            var _min_parts = 0;
            if (string_pos(PROGLANG_BASE_DIR, _current_path) == 1) {
                // Absolute path - cannot go above base directory
                _min_parts = _root_len;
            }
            
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
    
    // Preserve namespace if it was present
    if (string_pos(":", _path) > 0) {
        var _colon_pos = string_pos(":", _path);
        var _ns = string_copy(_path, 1, _colon_pos);
        if (string_pos(_ns, _resolved) != 1) {
             // If resolution didn't already include it (e.g. absolute path with NS)
             // This is a bit complex, but for now we assume absolute paths with NS stay absolute
             // _resolved = _ns + _resolved; 
        }
    }
    
    return _resolved;
}

/// @desc Split path into segments
/// @param {string} _path Path to split
/// @returns {array} Array of path segments
function proglang_split_path(_path) {
    var _parts = [];
    var _current = "";
    var _length = string_length(_path);
    
    for (var i = 1; i <= _length; i++) {
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
        // Strip virtual namespace for physical file access
        var _physical_path = _resolved;
        var _colon_pos = string_pos(":", _physical_path);
        if (_colon_pos > 0) {
            _physical_path = string_delete(_physical_path, 1, _colon_pos);
        }
        
        _full_path = $"{PROGLANG_BASE_DIR}/{_physical_path}";
        if (!string_ends_with(_full_path, ".daydream")) {
            _full_path += ".daydream";
        }
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
    var _vm = proglang_vm_create();
    
    _vm[@ PROG_VM.ACTIVE_MODULE] = global.proglang_modules[$ _resolved];
    _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__dirname"] = proglang_get_directory(_full_path);
    _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__filename"] = _full_path;
    
    proglang_vm_run(_vm, _bytecode);
    
    proglang_vm_free(_vm);
    
    global.proglang_modules[$ _resolved].loaded = true;
    
    return global.proglang_modules[$ _resolved].exports;
}

/// @desc Execute a named script or function
/// @param {string} _name Script/function name
/// @param {array} _args Arguments
/// @param {struct} _context Execution context
/// @returns {any} Result
function proglang_call(_name, _args = [], _context = {}) {
    show_debug_message($"[Daydream] Proglang Call: {_name}");
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
    
    var _vm = proglang_vm_create();
    _vm[@ PROG_VM.CONTEXT] = _context;
    
    // Set directory context for import/export resolution
    var _dirname = proglang_get_directory(_name);
    _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__dirname"] = _dirname;
    _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__filename"] = _name;
    
    for (var i = 0; i < array_length(_args); i++) {
        _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ $"arg{i}"] = _args[i];
    }
    _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "argc"] = array_length(_args);
    
    var _result = proglang_vm_run(_vm, _bytecode);
    proglang_vm_free(_vm);
    return _result;
}
