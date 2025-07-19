global.item_function = {}

global.item_function[$ "phantasia:spawn_particle"] = function(_x, _y, _parameter)
{
    var _offset = _parameter[$ "offset"];
    
    if (_offset != undefined)
    {
        var _xoffset = _offset[$ "x"];
        
        if (_xoffset != undefined)
        {
            _x += smart_value(_xoffset);
        }
        
        var _yoffset = _offset[$ "y"];
        
        if (_yoffset != undefined)
        {
            _y += smart_value(_yoffset);
        }
    }
    
    spawn_particle(_x * TILE_SIZE, _y * TILE_SIZE, smart_value(_parameter.id));
}