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
    var _audio_emitter = tile_audio_emitter(_x, _y);
    
    sfx_diegetic_play(_audio_emitter, _x * TILE_SIZE, _y * TILE_SIZE, smart_value(_parameter.id));
}

global.item_function[$ "phantasia:tile_grow_crop"] = function(_dt, _x, _y, _z, _parameter)
{
}

global.item_function[$ "phantasia:tile_place"] = function(_dt, _x, _y, _z, _parameter)
{
    static __chunk_depth = global.chunk_depth;
    
    var _condition = _parameter[$ "condition"];
    
    if (_condition != undefined)
    {
        var _condition_length = array_length(_condition);
        
        for (var i = 0; i < _condition_length; ++i)
        {
            var _ = _condition[i];
            
            var _x2 = _.x;
            var _y2 = _.y;
            
            var _offset = _[$ "offset"];
            
            if (_offset != undefined)
            {
                var _xoffset = _offset[$ "x"];
                
                if (_xoffset != undefined)
                {
                    _x2 = smart_value(_xoffset);
                }
                
                var _yoffset = _offset[$ "y"];
                
                if (_yoffset != undefined)
                {
                    _y2 = smart_value(_yoffset);
                }
            }
            
            var _tile = tile_get(_x2, _y2, __chunk_depth[$ _.z]);
            
            var _id = _.id;
            
            if (_id == TILE_EMPTY_ID) 
            {
                if (_tile != TILE_EMPTY) exit;
            }
            else if (_tile == TILE_EMPTY) || ((is_array(_id)) ? !array_contains(_id, _tile.get_id()) : _tile.get_id() != _id) exit;
        }
    }
    
    var _x2 = _parameter.x;
    var _y2 = _parameter.y;
    
    var _offset = _parameter[$ "offset"];
    
    if (_offset != undefined)
    {
        var _xoffset = _offset[$ "x"];
        
        if (_xoffset != undefined)
        {
            _x2 = smart_value(_xoffset);
        }
        
        var _yoffset = _offset[$ "y"];
        
        if (_yoffset != undefined)
        {
            _y2 = smart_value(_yoffset);
        }
    }
    
    var _z2 = __chunk_depth[$ _parameter.z];
    
    tile_place(_x2, _y2, _z2, new Tile(smart_value(_parameter.id)));
    
    tile_update_surrounding(_x2, _y2, _z2);
}