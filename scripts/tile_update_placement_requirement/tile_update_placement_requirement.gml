function tile_update_placement_condition(_x, _y, _z, _item)
{
    var _item_data = global.item_data;
    
    var _data = _item_data[$ _item.get_id()];
    
    var _requirements = _data.get_placement_condition();
    
    if (_requirements == undefined)
    {
        if (_z == CHUNK_DEPTH_FOLIAGE_BACK) || (_z == CHUNK_DEPTH_FOLIAGE_FRONT)
        {
            if
            (tile_get(_x, _y, CHUNK_DEPTH_DEFAULT) != TILE_EMPTY) ||
            (tile_get(_x, _y + 1, CHUNK_DEPTH_DEFAULT) == TILE_EMPTY)
            {
                return false;
            }
        }
        
        return true;
    }
    
    static __item_type = global.item_type;
    
    var _requirement_values = _requirements.values;
    var _requirement_condition = _requirements.type;
    
    var _met = 0;
    
    var _length = _requirements.values_length;
    
    for (var i = 0; i < _length; ++i)
    {
        var _requirement = _requirement_values[i];
        
        var _z2 = _requirement.z;
        
        var _tile = tile_get(_x + _requirement.xoffset, _y + _requirement.yoffset, ((_z2 == "z") ? _z : _z2));
        
        if (_tile == TILE_EMPTY) continue;
        
        var _requirement_id = _requirement[$ "id"];
        
        if (_requirement_id != undefined)
        {
            if ((is_array(_requirement_id)) ? (array_contains(_requirement_id, _tile.get_id())) : (_requirement_id == _tile.get_id()))
            {
                ++_met;
            }
            
            continue;
        }
        
        var _types = _requirement[$ "type"];
        
        if (_types != undefined)
        {
            var _tile_data = _item_data[$ _tile.get_id()];
            
            if (is_array(_types))
            {
                var _types_length = array_length(_types);
                
                for (var j = 0; j < _types_length; ++j)
                {
                    if (_tile_data.has_type(__item_type[$ _types[j]]))
                    {
                        ++_met;
                        
                        continue;
                    }
                }
            }
            else if (_tile_data.has_type(__item_type[$ _types]))
            {
                ++_met;
                
                continue;
            }
        }
    }
    
    if (_requirement_condition == TILE_PLACEMENT_CONDITION_TYPE.EVERY)
    {
        if (_met >= _length)
        {
            return true;
        }
    }
    else
    {
        if (_met > 0)
        {
            return true;
        }
    }
    
    return false;
}