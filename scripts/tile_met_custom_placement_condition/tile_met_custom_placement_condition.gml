function tile_met_custom_placement_condition(_x, _y, _z, _condition, _item_data = global.item_data)
{
    var _condition_type = _condition.type;
    
    var _condition_values = _condition.values;
    var _condition_values_length = array_length(_condition_values);
    
    var _condition_amount = 0;
    
    for (var i = 0; i < _condition_values_length; ++i)
    {
        var _value = _condition_values[i];
        
        var _c = _value[$ "condition"];
        
        if (_c != undefined)
        {
            _condition_amount += tile_met_custom_placement_condition(_x, _y, _z, _c, _item_data);
            
            continue;
        }
        
        var _xoffset = 0;
        var _yoffset = 0;
        
        var _offset = _value[$ "offset"];
        
        if (_offset != undefined)
        {
            _xoffset = _offset[$ "x"] ?? 0;
            _yoffset = _offset[$ "y"] ?? 0;
        }
        
        var _z2 = _value.z;
        
        if (_z2 == "default")
        {
            _z2 = CHUNK_DEPTH_DEFAULT;
        }
        
        if (_z2 == "wall")
        {
            _z2 = CHUNK_DEPTH_WALL;
        }
        
        if (_z2 == "z")
        {
            _z2 = _z;
        }
        
        var _tile = tile_get(_x + _xoffset, _y + _yoffset, ((_z2 == "z") ? _z : _z2));
        
        var _id = _value[$ "id"];
        
        if (_tile == TILE_EMPTY)
        {
            if (_id != undefined)
            {
                if (is_array(_id)) ? (array_contains(_id, TILE_EMPTY_ID)) : (_id == TILE_EMPTY_ID)
                {
                    ++_condition_amount;
                }
                else if (_value[$ "is_not"])
                {
                    ++_condition_amount;
                }
            }
            
            continue;
        }
        
        if (_id != undefined)
        {
            if (is_array(_id)) ? (array_contains(_id, _tile.get_id())) : (_id == _tile.get_id())
            {
                ++_condition_amount;
            }
            else if (_value[$ "is_not"])
            {
                ++_condition_amount;
            }
            
            continue;
        }
        
        var _type = _value[$ "type"];
        
        if (_type != undefined)
        {
            if (_item_data[$ _tile.get_id()].has_type(_type))
            {
                ++_condition_amount;
            }
            else if (_value[$ "is_not"])
            {
                ++_condition_amount;
            }
            
            continue;
        }
    }
    
    show_debug_message($"{_condition_type} {_condition_amount} {_condition_values_length}")
    
    if (_condition_type == "every")
    {
        return (_condition_amount == _condition_values_length);
    }
    
    return (_condition_amount > 0);
}