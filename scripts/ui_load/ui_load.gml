/// @desc Load and compile a .ui file
/// @param {String} _path Path to the .ui file
/// @returns {Struct.UICompileResult} Compilation result with definitions
function ui_load(_path)
{
    var _result = new UICompileResult();
    
    // Read file contents
    var _file = file_text_open_read(_path);
    if (_file == -1)
    {
        _result.success = false;
        _result.error = $"Failed to open file: {_path}";
        return _result;
    }
    
    var _source = "";
    while (!file_text_eof(_file))
    {
        _source += file_text_read_string(_file);
        if (!file_text_eof(_file))
        {
            _source += "\n";
        }
        file_text_readln(_file);
    }
    file_text_close(_file);
    
    // Tokenize
    var _lexer = new UILexer(_source);
    var _tokens = _lexer.tokenize();
    
    if (_lexer.had_error)
    {
        _result.success = false;
        _result.error = $"Lexer error in {_path}: {_lexer.error}";
        return _result;
    }
    
    // Parse
    var _parser = new UIParser(_tokens);
    var _ast = _parser.parse();
    
    if (_parser.had_error)
    {
        _result.success = false;
        _result.error = $"Parser error in {_path}: {_parser.error}";
        return _result;
    }
    
    // Compile
    var _compiler = new UICompiler();
    _result = _compiler.compile(_ast);
    
    return _result;
}

/// @desc Load a .ui file from the included files
/// @param {String} _path Path relative to included files (e.g., "ui/main_menu.ui")
/// @returns {Struct.UICompileResult} Compilation result
function ui_load_included(_path)
{
    var _result = new UICompileResult();
    
    // Read from included files (working_directory)
    var _full_path = working_directory + _path;
    
    if (!file_exists(_full_path))
    {
        _result.success = false;
        _result.error = $"UI file not found: {_path}";
        return _result;
    }
    
    return ui_load(_full_path);
}

/// @desc Global cache for loaded UI definitions
global.ui_cache = {};

/// @desc Load a UI file with caching
/// @param {String} _path Path to the .ui file
/// @returns {Struct.UICompileResult} Cached or freshly compiled result
function ui_load_cached(_path)
{
    // Check cache
    var _cached = global.ui_cache[$ _path];
    if (_cached != undefined)
    {
        return _cached;
    }
    
    // Load and cache
    var _result = ui_load_included(_path);
    if (_result.success)
    {
        global.ui_cache[$ _path] = _result;
    }
    
    return _result;
}

/// @desc Get a specific definition from a loaded UI file
/// @param {String} _path Path to the .ui file
/// @param {String} _name Name of the definition to get
/// @returns {Struct.UIDefinition|undefined} The definition or undefined
function ui_get_definition(_path, _name)
{
    var _result = ui_load_cached(_path);
    if (!_result.success)
    {
        show_debug_message($"UI Load Error: {_result.error}");
        return undefined;
    }
    
    var _def = _result.definitions[$ _name];
    if (_def == undefined)
    {
        show_debug_message($"UI Definition '{_name}' not found in {_path}");
        return undefined;
    }
    
    // Return a clone so links can be set independently
    return _def.clone();
}

/// @desc Quick helper to load and spawn a UI in one call
/// @param {String} _path Path to .ui file
/// @param {String} _name Definition name
/// @param {Struct} _links Optional link bindings
/// @returns {Struct.UIElement|undefined} Spawned element
function ui_load_and_spawn(_path, _name, _links = {})
{
    var _def = ui_get_definition(_path, _name);
    if (_def == undefined)
    {
        return undefined;
    }
    
    // Apply links
    var _link_keys = struct_get_names(_links);
    for (var i = 0; i < array_length(_link_keys); ++i)
    {
        var _key = _link_keys[i];
        _def.set_link(_key, _links[$ _key]);
    }
    
    return ui_spawn(_def);
}

/// @desc Clear the UI cache
function ui_cache_clear()
{
    global.ui_cache = {};
}
