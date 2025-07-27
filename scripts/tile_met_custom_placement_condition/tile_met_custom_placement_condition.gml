function tile_met_custom_placement_condition(_x, _y, _z, _placement_condition)
{
    static __item_type = global.item_type;
    
    var _requirement_values = _placement_condition.values;
    var _requirement_condition = _placement_condition.type;
    
    var _met = 0;
    
    var _length = _placement_condition.values_length;
    
    for (var i = 0; i < _length; ++i)
    {
        var _requirement = _requirement_values[i];
        
        var _z2 = _requirement.z;
        
        var _tile = tile_get(_x + _requirement.xoffset, _y + _requirement.yoffset, ((_z2 == "z") ? _z : _z2));
        
        if (_tile == TILE_EMPTY) continue;
        
        var _requirement_id = _requirement[$ "id"];
        
        if (_requirement_id != undefined)
        {
            if (is_array(_requirement_id)) ? (array_contains(_requirement_id, _tile.get_id())) : (_requirement_id == _tile.get_id())
            {
                ++_met;
            }
            
            continue;
        }
        
        var _types = _requirement[$ "type"];
        
        if (_types != undefined)
        {
            if (global.item_data[$ _tile.get_id()].has_type(_types))
            {
                ++_met;
            }
            
            continue;
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