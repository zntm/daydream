/// @function cuteify_get_width(_string, _asset_prefix)
/// @desc Gets the width of a cuteify-formatted string
/// @param {String} _string The input string with formatting tags
/// @param {String} _asset_prefix Prefix for asset lookups
/// @returns {Real} Width in pixels
function cuteify_get_width(_string, _asset_prefix = "")
{
    var _ast = cuteify_get(_string, _asset_prefix);
    
    var _width = 0;
    
    for (var i = 0; i <= _ast.line_count; ++i)
    {
        _width = max(_width, _ast.widths[i]);
    }
    
    return _width;
}