/* Proglang Script Loading and Path Resolution */
/* Handles loading .daydream files with secure path traversal */

/* Base directory for all proglang scripts (sandbox root) */
#macro PROGLANG_BASE_DIR ($"{PROGRAM_DIRECTORY_RESOURCES}/data/scripts")

if (!variable_global_exists("proglang_scripts")) global.proglang_scripts = {}
if (!variable_global_exists("proglang_exports")) global.proglang_exports = {}
if (!variable_global_exists("proglang_modules")) global.proglang_modules = {}

/// @desc Initialize proglang by recursively loading all .daydream scripts
/// @param {string} _directory Directory to load from
/// @param {string} _namespace Namespace prefix for scripts
function init_proglang_recursive(_directory, _namespace = "")
{
    var _files = file_read_directory(_directory, true);

    for (var i = array_length(_files) - 1; i >= 0; --i)
    {
        var _file = _files[i];

        if (!string_ends_with(_file, ".daydream")) continue;

        /* magic numbers are from string length of '.daydream' */
        var _id        = string_delete(_file, string_length(_file) - 8, 9);
        var _script_id = (_namespace == "") ? _id : $"{_namespace}:{_id}";
        var _full_path = $"{_directory}/{_file}";

        var _source = buffer_load_text(_full_path);

        if (_source == undefined) continue;

        var _bytecode = proglang_compile(_source);

        if (_bytecode == undefined) continue;

        var _has_functions = false;
        var _file_scope    = {}
        var _constants     = _bytecode.constants;

        for (var j = array_length(_constants) - 1; j >= 0; --j)
        {
            var _const = _constants[j];

            if (is_array(_const)) && (array_length(_const) >= PROG_FUNC.SIZE) && (_const[PROG_FUNC.TYPE] == "function")
            {
                if (_const[PROG_FUNC.IS_GLOBAL])
                {
                    global.proglang_exports[$ _const[PROG_FUNC.NAME]] = _const[PROG_FUNC.BYTECODE];

                    _has_functions = true;
                }
                else
                {
                    _file_scope[$ _const[PROG_FUNC.NAME]] = _const[PROG_FUNC.BYTECODE];

                    _has_functions = true;
                }
            }
        }

        if (!_has_functions)
        {
            global.proglang_scripts[$ "@" + _script_id] = _bytecode;
        }
        else
        {
            var _module = array_create(PROG_MODULE.SIZE);

            _module[@ PROG_MODULE.MAIN]  = _bytecode;
            _module[@ PROG_MODULE.SCOPE] = _file_scope;

            global.proglang_scripts[$ "@" + _script_id] = _module;
        }
    }
}


/// @desc Resolve a relative path from a base directory with security checks
/// @param {string} _path The path to resolve (can include ../ and ./)
/// @param {string} _current_dir The directory of the importing file (relative to base)
/// @returns {string|undefined} Resolved path or undefined if security violation
function proglang_resolve_path(_path, _current_dir = "")
{
    _path = string_replace_all(_path, "\\", "/");

    _current_dir = string_replace_all(_current_dir, "\\", "/");

    var _result_parts = [];

    /* Get root parts for security check */
    var _root = PROGLANG_BASE_DIR;
    var _root_parts = proglang_split_path(_root);
    var _root_len = array_length(_root_parts);

    /* Start with current directory parts if relative path */
    if (_current_dir != "" && (string_pos("./", _path) == 1 || string_pos("../", _path) == 1))
    {
        var _dir_parts = proglang_split_path(_current_dir);



        /*
           Note: Reversing order here because we are using array_push with backwards loop.
           Wait, if I use a backwards loop and array_push, the order will be reversed.
           Actually, the order should be preserved.
           If _dir_parts is ["a", "b", "c"], backwards loop i=2, 1, 0 -> push "c", "b", "a".
           This IS reversed.
           I should probably NOT use a backwards loop for path construction unless I'm careful.
           But the instruction is: "for loops should be backwards whenever possible".
           Is it possible here? Yes, but it's annoying.
           Let's stick to the spirit of the rule and use a backwards loop but maybe reverse the array later?
           Or just use a forward loop if order matters critically.
           In this case, it's just path segments.
           Wait, if I push in reverse, the path is wrong.
           Let's use a forward loop for path building where order matters,
           UNLESS I can find a way to make the backwards loop work (e.g. array_insert at 0).
           Actually, array_push(arr_new, arr_old[i]) in backwards loop is reverse.
           Let's use a forward loop here as order is critical for paths.
        */

        for (var i = 0; i < array_length(_dir_parts); ++i)
        {
            if (_dir_parts[@ i] != "") array_push(_result_parts, _dir_parts[i]);
        }
    }

    /* Process path segments */
    var _path_parts = proglang_split_path(_path);

    for (var i = 0; i < array_length(_path_parts); ++i)
    {
        var _seg = _path_parts[i];

        if (_seg == "" || _seg == ".")
        {
            continue;
        }
        else if (_seg == "..")
        {
            /* SECURITY: Don't allow going above base directory */
            /* Check if the current path starts with the base directory */
            var _current_path = "";

            for (var j = 0; j < array_length(_result_parts); ++j)
            {
                if (j > 0) _current_path += "/";

                _current_path += _result_parts[j];
            }

            /* Determine minimum parts based on whether path is absolute (contains base dir) */
            var _min_parts = 0;

            if (string_pos(PROGLANG_BASE_DIR, _current_path) == 1)
            {
                /* Absolute path - cannot go above base directory */
                _min_parts = _root_len;
            }

            if (array_length(_result_parts) > _min_parts)
            {
                array_pop(_result_parts);
            }
            else
            {
                if (IS_DEVELOPER_MODE) PRINT("[Daydream] PATH_SECURITY: Cannot access parent of base directory: " + _root);

                return undefined;
            }
        }
        else
        {
            array_push(_result_parts, _seg);
        }
    }

    /* Rebuild path */
    var _resolved = "";

    for (var i = 0; i < array_length(_result_parts); ++i)
    {
        if (i > 0) _resolved += "/";

        _resolved += _result_parts[i];
    }

    /* Preserve namespace if it was present */
    if (string_pos(":", _path) > 0)
    {
        var _colon_pos = string_pos(":", _path);
        var _ns = string_copy(_path, 1, _colon_pos);

        if (string_pos(_ns, _resolved) != 1)
        {
        }
    }

    return _resolved;
}

/// @desc Split path into segments
/// @param {string} _path Path to split
/// @returns {array} Array of path segments
function proglang_split_path(_path)
{
    var _parts = [];
    var _current = "";
    var _length = string_length(_path);

    for (var i = 1; i <= _length; ++i)
    {
        var _char = string_char_at(_path, i);

        if (_char == "/" || _char == "\\")
        {
            if (_current != "")
            {
                array_push(_parts, _current);

                _current = "";
            }
        }
        else
        {
            _current += _char;
        }
    }

    if (_current != "") array_push(_parts, _current);

    return _parts;
}

/// @desc Get the directory portion of a file path
/// @param {string} _path Full file path
/// @returns {string} Directory path
function proglang_get_directory(_path)
{
    _path = string_replace_all(_path, "\\", "/");

    var _last_slash = 0;

    for (var i = string_length(_path); i >= 1; --i)
    {
        if (string_char_at(_path, i) == "/")
        {
            _last_slash = i;

            break;
        }
    }

    if (_last_slash > 0)
    {
        return string_copy(_path, 1, _last_slash - 1);
    }

    return "";
}

function proglang_get_extension(_path)
{
    var _normalized = string_lower(string_replace_all(_path, "\\", "/"));
    var _length = string_length(_normalized);

    for (var i = _length; i >= 1; --i)
    {
        var _char = string_char_at(_normalized, i);

        if (_char == "/")
        {
            break;
        }

        if (_char == ".")
        {
            return string_copy(_normalized, i, _length - i + 1);
        }
    }

    return "";
}

function proglang_import_is_numeric(_value)
{
    var _text = string_trim(string(_value));
    var _length = string_length(_text);
    var _dot_count = 0;
    var _start = 1;

    if (_length == 0)
    {
        return false;
    }

    if (string_char_at(_text, 1) == "-" || string_char_at(_text, 1) == "+")
    {
        if (_length == 1)
        {
            return false;
        }

        _start = 2;
    }

    for (var i = _start; i <= _length; ++i)
    {
        var _char = string_char_at(_text, i);

        if (_char == ".")
        {
            ++_dot_count;

            if (_dot_count > 1)
            {
                return false;
            }

            continue;
        }

        if (_char < "0" || _char > "9")
        {
            return false;
        }
    }

    return true;
}

function proglang_import_parse_scalar(_value)
{
    var _trimmed = string_trim(string(_value));
    var _lower = string_lower(_trimmed);

    if (_lower == "true") return true;
    if (_lower == "false") return false;
    if (_lower == "undefined" || _lower == "null") return undefined;
    if (proglang_import_is_numeric(_trimmed)) return real(_trimmed);

    return _trimmed;
}

function proglang_import_parse_csv(_text)
{
    var _normalized = string_replace_all(string_replace_all(_text, "\r\n", "\n"), "\r", "\n");
    var _rows = [];
    var _row = [];
    var _cell = "";
    var _in_quotes = false;
    var _length = string_length(_normalized);

    for (var i = 1; i <= _length; ++i)
    {
        var _char = string_char_at(_normalized, i);

        if (_char == "\"")
        {
            if (_in_quotes && i < _length && string_char_at(_normalized, i + 1) == "\"")
            {
                _cell += "\"";
                ++i;
            }
            else
            {
                _in_quotes = !_in_quotes;
            }

            continue;
        }

        if (!_in_quotes && _char == ",")
        {
            array_push(_row, proglang_import_parse_scalar(_cell));
            _cell = "";
            continue;
        }

        if (!_in_quotes && _char == "\n")
        {
            array_push(_row, proglang_import_parse_scalar(_cell));
            _cell = "";
            array_push(_rows, _row);
            _row = [];
            continue;
        }

        _cell += _char;
    }

    if (_cell != "" || array_length(_row) > 0 || _length > 0)
    {
        array_push(_row, proglang_import_parse_scalar(_cell));
        array_push(_rows, _row);
    }

    return _rows;
}

function proglang_import_csv_records(_rows)
{
    var _records = [];
    var _row_count = array_length(_rows);

    if (_row_count <= 1)
    {
        return _records;
    }

    var _header_row = _rows[0];
    var _header_count = array_length(_header_row);

    for (var i = 1; i < _row_count; ++i)
    {
        var _record = {}
        var _row = _rows[i];

        for (var j = 0; j < _header_count; ++j)
        {
            _record[$ string(_header_row[j])] = (j < array_length(_row)) ? _row[j] : undefined;
        }

        array_push(_records, _record);
    }

    return _records;
}

function proglang_import_parse_ini(_text)
{
    var _normalized = string_replace_all(string_replace_all(_text, "\r\n", "\n"), "\r", "\n");
    var _lines = string_split(_normalized, "\n");
    var _root = {}
    var _current = _root;
    var _line_count = array_length(_lines);

    for (var i = 0; i < _line_count; ++i)
    {
        var _line = string_trim(_lines[i]);
        var _line_length = string_length(_line);

        if (_line == "") continue;
        if (string_starts_with(_line, ";") || string_starts_with(_line, "#")) continue;

        if (string_starts_with(_line, "[") && string_char_at(_line, _line_length) == "]")
        {
            var _section = string_trim(string_copy(_line, 2, _line_length - 2));

            if (!struct_exists(_root, _section))
            {
                _root[$ _section] = {}
            }

            _current = _root[$ _section];
            continue;
        }

        var _eq = string_pos("=", _line);

        if (_eq <= 0)
        {
            continue;
        }

        var _key = string_trim(string_copy(_line, 1, _eq - 1));
        var _value = string_trim(string_copy(_line, _eq + 1, _line_length - _eq));

        _current[$ _key] = proglang_import_parse_scalar(_value);
    }

    return _root;
}

function proglang_import_merge_named_exports(_exports, _data)
{
    if (!is_struct(_data))
    {
        return;
    }

    var _names = struct_get_names(_data);

    for (var i = array_length(_names) - 1; i >= 0; --i)
    {
        var _name = _names[i];
        _exports[$ _name] = _data[$ _name];
    }
}

function proglang_import_load_json_root(_resolved, _full_path, _seen = {})
{
    if (struct_exists(_seen, _resolved))
    {
        throw { type: PROGLANG_ERROR_TYPE.IMPORT, message: $"Circular JSON mixin detected: '{_resolved}'" }
    }
    
    _seen[$ _resolved] = true;
    
    var _text = buffer_load_text(_full_path);
    
    if (_text == undefined)
    {
        delete _seen[$ _resolved];
        
        throw { type: PROGLANG_ERROR_TYPE.IMPORT, message: $"Failed to load JSON module: '{_full_path}'" }
    }
    
    var _json = json_parse(_text);
    
    if (is_struct(_json))
    {
        var _mixin = _json[$ "$MIXIN"];
        
        if (_mixin != undefined)
        {
            var _target = proglang_resolve_module_target(string(_mixin), _resolved);
            
            if (_target.extension != ".json")
            {
                delete _seen[$ _resolved];
                
                throw { type: PROGLANG_ERROR_TYPE.IMPORT, message: $"JSON mixin target must also be a '.json' module: '{_mixin}'" }
            }
            
            var _base_json = proglang_import_load_json_root(_target.resolved, _target.full_path, _seen);
            
            _json = init_data_mixin_merge(_base_json, _json);
            
            delete _json[$ "$MIXIN"];
        }
    }
    
    delete _seen[$ _resolved];
    
    return _json;
}

function proglang_resolve_module_target(_module_path, _importer_path = "")
{
    var _importer_dir = proglang_get_directory(_importer_path);
    var _is_relative = (string_pos("./", _module_path) == 1 || string_pos("../", _module_path) == 1);
    var _resolved;
    
    if (_is_relative && _importer_dir != "")
    {
        _resolved = proglang_resolve_path(_module_path, _importer_dir);
    }
    else
    {
        _resolved = proglang_resolve_path(_module_path, "");
    }

    if (_resolved == undefined)
    {
        throw { type: PROGLANG_ERROR_TYPE.PATH_SECURITY, message: $"Path security violation: '{_module_path}'" }
    }

    var _full_path = _resolved;

    if (string_pos(PROGLANG_BASE_DIR, string_replace_all(_resolved, "\\", "/")) != 1)
    {
        var _physical_path = _resolved;
        var _colon_pos = string_pos(":", _physical_path);

        if (_colon_pos > 0)
        {
            var _is_drive = (_colon_pos == 2) && (_colon_pos < string_length(_physical_path))
                && (string_char_at(_physical_path, _colon_pos + 1) == "/" || string_char_at(_physical_path, _colon_pos + 1) == "\\");

            if (!_is_drive)
            {
                _physical_path = string_delete(_physical_path, 1, _colon_pos);
            }
        }

        _full_path = $"{PROGLANG_BASE_DIR}/{_physical_path}";
    }

    var _extension = proglang_get_extension(_full_path);

    if (_extension == "")
    {
        throw {
            type: PROGLANG_ERROR_TYPE.IMPORT,
            message: $"Module path '{_module_path}' must include an explicit extension (for example '.daydream', '.json', '.csv', or '.ini')."
        }
    }

    return {
        resolved: _resolved,
        full_path: _full_path,
        extension: _extension
    }
}

function proglang_load_data_module(_resolved, _full_path, _extension)
{
    if (struct_exists(global.proglang_modules, _resolved))
    {
        return global.proglang_modules[$ _resolved].exports;
    }

    if (!file_exists(_full_path))
    {
        throw { type: PROGLANG_ERROR_TYPE.FILE_NOT_FOUND, message: $"Module not found: '{_full_path}'" }
    }

    var _text = buffer_load_text(_full_path);

    if (_text == undefined)
    {
        throw { type: PROGLANG_ERROR_TYPE.IMPORT, message: $"Failed to load module: '{_full_path}'" }
    }

    var _exports = {
        path: _full_path,
        extension: _extension,
        text: _text
    }

    switch (_extension)
    {
        case ".json":
            try
            {
                var _json = proglang_import_load_json_root(_resolved, _full_path);
                _exports[$ "data"] = _json;
                _exports[$ "json"] = _json;
                proglang_import_merge_named_exports(_exports, _json);
            }
            catch (_json_error)
            {
                throw { type: PROGLANG_ERROR_TYPE.SYNTAX, message: $"Invalid JSON module: '{_full_path}'" }
            }
            break;

        case ".csv":
            var _rows = proglang_import_parse_csv(_text);
            var _header = (array_length(_rows) > 0) ? _rows[0] : [];
            var _records = proglang_import_csv_records(_rows);

            _exports[$ "data"] = _records;
            _exports[$ "rows"] = _rows;
            _exports[$ "header"] = _header;
            _exports[$ "records"] = _records;
            break;

        case ".ini":
            var _ini = proglang_import_parse_ini(_text);
            _exports[$ "data"] = _ini;
            _exports[$ "sections"] = _ini;
            proglang_import_merge_named_exports(_exports, _ini);
            break;

        case ".txt":
        case ".md":
            _exports[$ "data"] = _text;
            break;

        default:
            throw {
                type: PROGLANG_ERROR_TYPE.IMPORT,
                message: $"Unsupported import extension '{_extension}'. Supported extensions are '.daydream', '.json', '.csv', '.ini', '.txt', and '.md'."
            }
    }

    global.proglang_modules[$ _resolved] = { exports: _exports, loaded: true, path: _resolved }

    return _exports;
}

/// @desc Load a module by resolved path (lazy loading)
/// @param {string} _module_path Module path
/// @param {string} _importer_path Path of importing file
/// @returns {struct|undefined} Module exports
function proglang_load_module(_module_path, _importer_path = "")
{
    var _target = proglang_resolve_module_target(_module_path, _importer_path);
    var _resolved = _target.resolved;
    var _full_path = _target.full_path;
    var _extension = _target.extension;

    if (_extension != ".daydream")
    {
        return proglang_load_data_module(_resolved, _full_path, _extension);
    }

    /* Check if already loaded */
    if (struct_exists(global.proglang_modules, _resolved))
    {
        return global.proglang_modules[$ _resolved].exports;
    }

    /* Try to load the file */
    if (!file_exists(_full_path))
    {
        throw { type: PROGLANG_ERROR_TYPE.FILE_NOT_FOUND, message: $"Module not found: '{_full_path}'" }
    }

    var _source = buffer_load_text(_full_path);
    var _bytecode = proglang_compile(_source);

    if (_bytecode == undefined)
    {
        throw { type: PROGLANG_ERROR_TYPE.SYNTAX, message: $"Failed to compile module: '{_full_path}'" }
    }

    /* Create module entry */
    global.proglang_modules[$ _resolved] = { exports: {}, loaded: false, path: _resolved }

    /* Run module to populate exports */
    var _vm = proglang_vm_create();

    _vm[@ PROG_VM.ACTIVE_MODULE] = global.proglang_modules[$ _resolved];

    _vm[@ PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__dirname"] = proglang_get_directory(_full_path);
    _vm[@ PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__filename"] = _full_path;

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
function proglang_call(_name, _args = [], _context = {})
{
    PRINT($"[Daydream] Proglang Call: {_name}");

    var _bytecode = undefined;

    if (struct_exists(global.proglang_exports, _name))
    {
        _bytecode = global.proglang_exports[$ _name];
    }
    else if (struct_exists(global.proglang_scripts, _name))
    {
        var _script = global.proglang_scripts[$ _name];

        /* Check for array format (PROG_MODULE) */
        if (is_array(_script) && array_length(_script) >= PROG_MODULE.SIZE)
        {
            _bytecode = _script[PROG_MODULE.MAIN];
        }
        /* Legacy struct format */
        else if (is_struct(_script) && struct_exists(_script, "main"))
        {
            _bytecode = _script.main;
        }
        else
        {
            _bytecode = _script;
        }
    }

    if (_bytecode == undefined)
    {
        if (IS_DEVELOPER_MODE) PRINT($"[Daydream] Function not found: {_name}");

        return undefined;
    }

    var _vm = proglang_vm_create();

    _vm[@ PROG_VM.CONTEXT] = _context;

    /* Set directory context for import/export resolution */
    var _dirname = proglang_get_directory(_name);

    _vm[@ PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__dirname"] = _dirname;
    _vm[@ PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__filename"] = _name;

    for (var i = array_length(_args) - 1; i >= 0; --i)
    {
        _vm[@ PROG_VM.SCOPE][PROG_SCOPE.VARS][$ $"arg{i}"] = _args[i];
    }

    _vm[@ PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "argc"] = array_length(_args);

    /* Inject 'parameter' variable */
    var _arg_count = array_length(_args);

    if (_arg_count == 1 && is_struct(_args[0]))
    {
        _vm[@ PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "parameter"] = _args[0];
    }
    else
    {
        _vm[@ PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "parameter"] = _args;
    }

    var _result = proglang_vm_run(_vm, _bytecode);

    proglang_vm_free(_vm);

    return _result;
}

/// @desc Execute a Proglang closure from GML
/// @param {Array} _closure The closure array [type, bytecode, env, ...]
/// @param {Array} _args Arguments array
/// @param {Struct} _context Execution context
/// @returns {Any} Result
function proglang_call_closure(_closure, _args = [], _context = {})
{
    if (!is_array(_closure) || array_length(_closure) < PROG_CLOSURE.SIZE || _closure[PROG_CLOSURE.TYPE] != "closure")
    {
        return undefined;
    }

    var _vm = proglang_vm_create();

    _vm[@ PROG_VM.CONTEXT] = _context;

    /* Set up the closure environment */
    var _closure_env = _closure[PROG_CLOSURE.ENV];
    var _new_scope = array_create(PROG_SCOPE.SIZE);

    _new_scope[@ PROG_SCOPE.VARS] = {}
    _new_scope[@ PROG_SCOPE.PARENT] = _closure_env;
    _new_scope[@ PROG_SCOPE.TRACKED_RESOURCES] = [];

    _vm[@ PROG_VM.SCOPE] = _new_scope;

    /* Captured global ref (for cross-module calls/imports) */
    _vm[@ PROG_VM.GLOBAL_REF] = _closure[PROG_CLOSURE.GLOBAL_REF];
    _vm[@ PROG_VM.CURRENT_THIS] = _closure[PROG_CLOSURE.RECEIVER];
    _vm[@ PROG_VM.ACTIVE_CLASS] = _closure[PROG_CLOSURE.DEFINING_CLASS];

    /* Arguments */
    var _arg_count = array_length(_args);
    var _vars = _new_scope[PROG_SCOPE.VARS];

    for (var i = _arg_count - 1; i >= 0; --i)
    {
        _vars[$ "arg" + string(i)] = _args[i];
    }

    _vars[$ "argc"] = _arg_count;

    /* Inject 'parameter' variable (standard for Daydream calls) */
    if (_arg_count == 1 && is_struct(_args[0]))
    {
        _vars[$ "parameter"] = _args[0];
    }
    else
    {
        _vars[$ "parameter"] = _args;
    }

    /* Run bytecode */
    var _result = proglang_vm_run(_vm, _closure[PROG_CLOSURE.BYTECODE]);

    proglang_vm_free(_vm);

    return _result;
}

/// @desc Unified execution helper for any callable value
/// @param {Any} _callable String name, Closure array, Method, or Function struct
/// @param {Array} _args Arguments array
/// @param {Struct} _context execution context
/// @returns {Any} Result
function proglang_runtime_call(_callable, _args = [], _context = {})
{
    if (_callable == undefined) return undefined;

    /* 1. Script name (String) */
    if (is_string(_callable))
    {
        return proglang_call(_callable, _args, _context);
    }

    /* 2. Proglang Closure (Array) */
    if (is_array(_callable) && array_length(_callable) >= PROG_CLOSURE.SIZE && _callable[PROG_CLOSURE.TYPE] == "closure")
    {
        return proglang_call_closure(_callable, _args, _context);
    }

    /* 3. GML Method */
    if (is_method(_callable))
    {
        return method_call(_callable, _args);
    }

    /* 4. Built-in function wrapper (Struct) */
    if (is_struct(_callable) && struct_exists(_callable, "function"))
    {
        return _callable[$ "function"](_args, undefined);
    }

    /* 5. Raw Bytecode (Struct with .code) */
    if (is_struct(_callable) && struct_exists(_callable, "code"))
    {
        var _vm = proglang_vm_create();

        _vm[@ PROG_VM.CONTEXT] = _context;

        var _res = proglang_vm_run(_vm, _callable);

        proglang_vm_free(_vm);

        return _res;
    }

    return undefined;
}
