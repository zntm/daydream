global.item_function = {}

global.item_function[$ "phantasia:spawn_particle"] = function(_x, _y, _parameter)
{
    var _offset = _parameter[$ "offset"];
    
    if (_offset != undefined)
    {
        var _xoffset = _offset[$ "x"];
        
        if (_xoffset != undefined)
        {
            _x += smart_value(smart_value_parse(_xoffset));
        }
        
        var _yoffset = _offset[$ "y"];
        
        if (_yoffset != undefined)
        {
            _y += smart_value(smart_value_parse(_yoffset));
        }
    }
    
    show_debug_message($"{_x} {_y} {smart_value(smart_value_parse(_parameter.id))}")
    
    spawn_particle(_x * TILE_SIZE, _y * TILE_SIZE, smart_value(smart_value_parse(_parameter.id)));
}