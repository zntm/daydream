function tile_placement_requirement(_x, _y, _z, _item)
{
    var _item_data = global.item_data;
    
    var _data = _item_data[$ _item.get_id()];
    
    var _requirements = _data.get_placement_requirement();
    
    if (_requirements == undefined)
    {
        if (_z != CHUNK_DEPTH_DEFAULT)
        {
            if (tile_get(_x, _y, CHUNK_DEPTH_WALL) != TILE_EMPTY)
            {
                return true;
            }
        }
        else if (_z == CHUNK_DEPTH_WALL)
        {
            if (tile_get(_x, _y, CHUNK_DEPTH_DEFAULT) != TILE_EMPTY)
            {
                return true;
            }
        }
        else if (_z == CHUNK_DEPTH_FOLIAGE_BACK) || (_z == CHUNK_DEPTH_FOLIAGE_FRONT)
        {
            if (tile_get(_x, _y, CHUNK_DEPTH_DEFAULT) != TILE_EMPTY)
            {
                return false;
            }
        }
        
        if
        (tile_get(_x - 1, _y, _z) == TILE_EMPTY) &&
        (tile_get(_x, _y - 1, _z) == TILE_EMPTY) &&
        (tile_get(_x + 1, _y, _z) == TILE_EMPTY) &&
        (tile_get(_x, _y + 1, _z) == TILE_EMPTY)
        {
            return false;
        }
    }
    else
    {
        static __z = {
            "wall": CHUNK_DEPTH_WALL,
            "default": CHUNK_DEPTH_DEFAULT
        }
        
        static __item_type = global.item_type;
        
        var _length = array_length(_requirements);
        
        for (var i = 0; i < _length; ++i)
        {
            var _requirement = _requirements[i];
            
            var _tile = tile_get(_x + _requirement.xoffset, _y + _requirement.yoffset, __z[$ _requirement.z]);
            
            var _requirement_id = _requirement[$ "id"];
            
            if (_tile == TILE_EMPTY)
            {
                if (_requirement_id == "air") continue;
                
                return false;
            }
            
            _tile = _item.get_id();
            
            if (_requirement_id != undefined)
            {
                if (is_array(_requirement_id)) ? (!array_contains(_requirement_id, _item)) : (_requirement_id != _item)
                {
                    return false;
                }
            }
            
            var _types = _requirement[$ "type"];
            
            if (_types != undefined)
            {
                var _tile_data = _item_data[$ _tile];
                
                if (is_array(_types))
                {
                    var _types_length = array_length(_types);
                    
                    for (var j = 0; j < _types_length; ++j)
                    {
                        if (!_tile_data.has_type(__item_type[$ _types[j]]))
                        {
                            return false;
                        }
                    }
                }
                else if (!_tile_data.has_type(__item_type[$ _types]))
                {
                    return false;
                }
            }
        }
    }
    
    return true;
}