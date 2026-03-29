/// @function cuteify_get_height(_string, _asset_prefix)
/// @desc Gets the height of a cuteify-formatted string
/// @param {String} _string The input string with formatting tags
/// @param {String} _asset_prefix Prefix for asset lookups
/// @returns {Real} Height in pixels
function cuteify_get_height(_string, _asset_prefix = "")
{
    var _ast = cuteify_get(_string, _asset_prefix);
    
    var _height = 0;
    
    for (var i = 0; i <= _ast.line_count; ++i)
    {
        _height += _ast.heights[i];
    }
    
    return _height;
}