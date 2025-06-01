function control_physics_item_drop(_dt)
{
    var _time = _dt / GAME_TICK;
    
    if (time_pickup > 0)
    {
        time_pickup -= _time;
        
        if (tile_meeting(x, y + 1))
        {
            xvelocity = lerp_delta(xvelocity, 0, 0.3, _dt);
        }
        
        control_physics(_dt, id);
        
        exit;
    }
    
    inst = instance_nearest(x, y, obj_Player);
    
    if (!instance_exists(inst))
    {
        if (tile_meeting(x, y + 1))
        {
            xvelocity = lerp_delta(xvelocity, 0, 0.3, _dt);
        }
        
        control_physics(_dt, id);
        
        exit;
    }
    
    var _inst_x = inst.x;
    var _inst_y = inst.y;
    
    var _distance = point_distance(x, y, _inst_x, _inst_y);
    
    if (_distance >= 6.5 * TILE_SIZE)
    {
        if (tile_meeting(x, y + 1))
        {
            xvelocity = lerp_delta(xvelocity, 0, 0.3, _dt);
        }
        
        control_physics(_dt, id);
        
        exit;
    }
    
    var _speed = 6.4 * _dt;
    
    xvelocity = lerp_delta(xvelocity, sign(_inst_x - x) * _speed, 0.02, _dt);
    yvelocity = lerp_delta(yvelocity, sign(_inst_y - y) * _speed, 0.02, _dt);
    
    control_physics(_dt, id, 0);
}