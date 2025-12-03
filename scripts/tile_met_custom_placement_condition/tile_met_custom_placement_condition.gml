function tile_met_custom_placement_condition(_x, _y, _z, _condition, _item_data = global.item_data, _self_id = undefined)
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
            _condition_amount += tile_met_custom_placement_condition(_x, _y, _z, _c, _item_data, _self_id);
            
            continue;
        }
        
        var _xoffset = _value[$ "xoffset"] ?? 0;
        var _yoffset = _value[$ "yoffset"] ?? 0;
        
        var _z2 = _value.z;
        
        if (_z2 == "default")
        {
            _z2 = CHUNK_DEPTH_DEFAULT;
        }
        else if (_z2 == "wall")
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
                var _match = false;
                
                if (is_array(_id))
                {
                    if (array_contains(_id, "$EMPTY")) || (array_contains(_id, TILE_EMPTY))
                    {
                        _match = true;
                    }
                }
                else if (_id == "$EMPTY") || (_id == TILE_EMPTY)
                {
                    _match = true;
                }
                
                if (_match)
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
            var _match = false;
            var _tile_id = _tile.get_id();
            
            if (is_array(_id))
            {
                if (array_contains(_id, _tile_id))
                {
                    _match = true;
                }
                else if (_self_id != undefined) && (array_contains(_id, "$ID")) && (_tile_id == _self_id)
                {
                    _match = true;
                }
            }
            else
            {
                if (_id == _tile_id)
                {
                    _match = true;
                }
                else if (_self_id != undefined) && (_id == "$ID") && (_tile_id == _self_id)
                {
                    _match = true;
                }
            }
            
            if (_match)
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
    
    if (_condition_type == "every")
    {
        return (_condition_amount == _condition_values_length);
    }
    
    return (_condition_amount > 0);
}