#macro PHYSICS_GLOBAL_SLIPPERINESS 0.2

function control_physics_x(_collision = true, _world_height = global.world_data[$ global.world.dimension].get_world_height())
{
    static __tile_meeting = function(_x, _y, _world_height)
    {
        var _tile = tile_meeting(_x, _y, undefined, undefined, _world_height);
        
        if (!_tile)
        {
            return false;
        }
        
        return !global.item_data[$ _tile.get_item_id()].has_type(ITEM_TYPE_BIT.PLATFORM);
    }
    
    var _xvelocity = xvelocity;
    /*
    if (object_index != obj_Item_Drop) && (knockback_time > 0)
    {
        _ = max(1, abs(_)) * knockback_direction;
        
        _speed = buffs[$ "knockback"] * (knockback_time / buffs[$ "knockback_time"]);
    }
    */
    if (_xvelocity == 0)
    {
        return false;
    }
    
    var _distance = abs(_xvelocity);
    var _direction = sign(_xvelocity);
    
    if (__tile_meeting(x + _distance, y, _world_height))
    {
        xvelocity = 0;
        
        return false;
    }
    
    var _size = image_xscale * 8;
    
    if (!_collision) || ((_distance <= _size) && (!__tile_meeting(x + _xvelocity, y, _world_height)))
    {
        x += _distance;
        
        return false;
    }
    
    for (var i = _distance; i > 0; i -= _size)
    {
        var _tick = _direction * min(i, _size);
        
        if (!__tile_meeting(x + _tick, y, _world_height))
        {
            x += _tick;
            
            continue;
        }
        
        for (var j = abs(min(_size, _tick)); j > 0; --j)
        {
            var _offset = min(j, 1) * _direction;
            
            if (__tile_meeting(x + _offset, y, _world_height))
            {
                return true;
            }
            
            x += _offset;
        }
        
        break;
    }
    
    return false;
}