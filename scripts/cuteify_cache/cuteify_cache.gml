/// @desc Global cache for cuteify ASTs
global.__cuteify_cache = {}

/// @desc Retrieves the parsed AST for a string, using cache if available
/// @param {String} _string Input string
/// @param {String} _asset_prefix Asset prefix (influences caching)
/// @returns {Struct} Evaluated AST
function cuteify_get(_string, _asset_prefix = "")
{
    var _key = string(draw_get_font()) + ":" + _asset_prefix + ":" + _string;
    
    if (struct_exists(global.__cuteify_cache, _key))
    {
        return global.__cuteify_cache[$ _key];
    }
    
    var _ast = cuteify_parse(_string, _asset_prefix);
    global.__cuteify_cache[$ _key] = _ast;
    
    return _ast;
}

/// @desc Clears the cuteify cache (e.g. when changing languages, fonts, etc)
function cuteify_clear_cache()
{
    global.__cuteify_cache = {}
}
