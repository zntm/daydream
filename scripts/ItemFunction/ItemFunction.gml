global.item_function = {}

global.item_function[$ "phantasia:spawn_particle"] = function(_dt, _x, _y, _z, _parameter)
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

global.item_function[$ "phantasia:sfx_play"] = function(_dt, _x, _y, _z, _parameter)
{
    sfx_diegetic_play(tile_audio_emitter(_x, _y), _x * TILE_SIZE, _y * TILE_SIZE, _parameter.id);
}

global.item_function[$ "phantasia:tile_grow_crop"] = function(_dt, _x, _y, _z, _parameter)
{
}

global.item_function[$ "phantasia:tile_place"] = function(_dt, _x, _y, _z, _parameter)
{
}