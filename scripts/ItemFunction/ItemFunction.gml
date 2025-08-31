global.item_function = {}

global.item_function[$ "phantasia:spawn_particle"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
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

global.item_function[$ "phantasia:spawn_projectile"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
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
    
    var _id = smart_value(_parameter.id);
    var _damage = smart_value(_parameter.damage);
    
    spawn_projectile(_x * TILE_SIZE, _y * TILE_SIZE, _id, _damage);
}

global.item_function[$ "phantasia:sfx_play"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    var _audio_emitter = tile_audio_emitter(_x, _y);
    
    sfx_diegetic_play(_audio_emitter, _x * TILE_SIZE, _y * TILE_SIZE, smart_value(_parameter.id));
}

global.item_function[$ "phantasia:tile_grow_crop"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
}

global.item_function[$ "phantasia:tile_place"] = function(_dt, _x, _y, _z, _xscale, _yscale, _parameter)
{
    static __chunk_depth = global.chunk_depth;
    
    var _condition = _parameter[$ "condition"];
    
    if (_condition != undefined)
    {
        var _condition_length = array_length(_condition);
        
        for (var i = 0; i < _condition_length; ++i)
        {
            var _ = _condition[i];
            
            var _xoffset = _[$ "x"];
            
            var _x2 = (_xoffset != undefined) ? (_x + smart_value(_xoffset)) : _x;
            
            var _yoffset = _[$ "y"];
            
            var _y2 = (_yoffset != undefined) ? (_y + smart_value(_yoffset)) : _y;
            
            var _tile = tile_get(_x2, _y2, __chunk_depth[$ _.z]);
            
            var _id = _.id;
            
            if (_id == TILE_EMPTY_ID)
            {
                if (_tile != TILE_EMPTY) exit;
            }
            else if (_tile == TILE_EMPTY) || ((is_array(_id)) ? !array_contains(_id, _tile.get_id()) : _tile.get_id() != _id) exit;
        }
    }
    
    var _xoffset = _parameter[$ "x"];
    
    var _x2 = (_xoffset != undefined) ? (_x + smart_value(_xoffset)) : _x;
    
    var _yoffset = _parameter[$ "y"];
    
    var _y2 = (_yoffset != undefined) ? (_y + smart_value(_yoffset)) : _y;
    
    var _z2 = __chunk_depth[$ _parameter.z];
    
    var _id = smart_value(_parameter.id);
    
    if (_id != TILE_EMPTY_ID)
    {
        tile_place(_x2, _y2, _z2, new Tile(_id));
    }
    else
    {
        tile_place(_x2, _y2, _z2, TILE_EMPTY_ID);
    }
    
    tile_update_surrounding(_x2, _y2, _z2);
}