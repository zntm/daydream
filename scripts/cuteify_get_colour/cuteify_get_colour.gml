/// @function cuteify_get_colour(_string, _asset_prefix)
/// @desc Gets the last colour specified in a cuteify-formatted string
/// @param {String} _string The input string with formatting tags
/// @param {String} _asset_prefix Prefix for asset lookups
/// @returns {Constant.colour|Real} The last colour found, or current draw colour if none
function cuteify_get_colour(_string, _asset_prefix = "")
{
    var _ast = cuteify_get(_string, _asset_prefix);
    
    var _colour = draw_get_colour();
    
    for (var i = 0; i <= _ast.line_count; ++i)
    {
        var _line_nodes = _ast.lines[i];
        var _node_count = array_length(_line_nodes);
        
        for (var j = 0; j < _node_count; ++j)
        {
            var _node = _line_nodes[j];
            
            if (_node.type == CUTEIFY_NODE.COLOUR)
            {
                _colour = _node.value;
            }
        }
    }
    
    return _colour;
}