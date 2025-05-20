function control_physics_y(_dt, _gravity = PHYSICS_GLOBAL_GRAVITY, _collision = true, _nudge = true, _world_height = global.world_data[$ global.world.dimension].get_world_height())
{
    static __tile_meeting = function(_x, _y, _direction, _world_height)
    {
        var _tile = tile_meeting(_x, _y, undefined, undefined, _world_height);
        
        if (!_tile)
        {
            return false;
        }
        
        var _data = global.item_data[$ _tile.get_item_id()];
        
        if (_data.has_type(ITEM_TYPE_BIT.PLATFORM))
        {
            return (_direction >= 0);
        }
        
        return true;
    }
    
    var _acceleration = _gravity * _dt / 2;
    
    yvelocity = clamp(yvelocity + _acceleration, -PHYSICS_GLOBAL_TERMINAL_YVELOCITY, PHYSICS_GLOBAL_TERMINAL_YVELOCITY);
    
    var _yvelocity = yvelocity;
    
    yvelocity = clamp(yvelocity + _acceleration, -PHYSICS_GLOBAL_TERMINAL_YVELOCITY, PHYSICS_GLOBAL_TERMINAL_YVELOCITY);
    
    var _distance = abs(_yvelocity);
    var _direction = sign(_yvelocity);
    
    var _size = abs(image_yscale * 8);
    
    if (__tile_meeting(x, y + _direction, _direction, _world_height))
    {
        yvelocity = 0;
        
        return true;
    }
    
    if (!_collision) || ((_distance <= _size) && (!__tile_meeting(x, y + _yvelocity, _direction, _world_height)))
    {
        y += _yvelocity;
        
        return false;
    }
    
    for (var i = _distance; i > 0; i -= _size)
    {
        var _tick = _direction * min(i, _size);
        
        if (!__tile_meeting(x, y + _tick, _direction, _world_height))
        {
            y += _tick;
            
            continue;
        }
        
        if (_nudge) && (_yvelocity < 0)
        {
            var _nudged = false;
            
            for (var j = 0; j < PHYSICS_GLOBAL_THRESHOLD_NUDGE; ++j)
            {
                if (!__tile_meeting(x + j, y, 1, _world_height))
                {
                    x += j;
                    
                    _nudged = true;
                    
                    break;
                }
                
                if (!__tile_meeting(x - j, y, -1, _world_height))
                {
                    x -= j;
                    
                    _nudged = true;
                    
                    break;
                }
            }
            
            if (_nudged) continue;
        }
        
        var _break = false;
        
        for (var j = abs(_tick); j > 0; j -= 1)
        {
            var _2 = _direction * min(j, 1);
            
            if (__tile_meeting(x, y + _2, _direction, _world_height))
            {
                _break = true;
                
                break;
            }
            
            y += _2;
        }
        
        if (_break)
        {
            yvelocity = 0;
        }
        
        break;
    }
    
    return false;
}