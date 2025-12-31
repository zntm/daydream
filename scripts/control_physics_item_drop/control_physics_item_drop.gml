/// @desc Item drop physics control using new physics system
/// @param {Real} _dt Delta time
/// @param {Id.Instance} _id Item drop instance

function control_physics_item_drop(_dt, _id)
{
    var _time = _dt / GAME_TICK;
    
    with (_id)
    {
        physics_body.sync_from_instance(id);
        
        // During pickup delay, just physics
        if (timer_pickup > 0)
        {
            timer_pickup -= _time;
            
            // Friction on ground
            if (physics_body.collision.ground)
            {
                physics_body.vel_x = lerp_delta(physics_body.vel_x, 0, 0.3, _dt);
            }
            
            // Gravity
            physics_body.vel_y += attribute.get_gravity() * _dt;
            
            physics_resolve_x(physics_body, _dt);
            physics_resolve_y(physics_body, _dt);
            physics_body.sync_to_instance(id);
            
            exit;
        }
        
        // Cache player search
        if ((current_time % 100) < (1000 / 60)) || (!instance_exists(inst))
        {
            inst = instance_nearest(x, y, obj_Player);
        }
        
        if (!instance_exists(inst))
        {
            // No player - just physics
            if (physics_body.collision.ground)
            {
                physics_body.vel_x = lerp_delta(physics_body.vel_x, 0, 0.3, _dt);
            }
            
            physics_body.vel_y += attribute.get_gravity() * _dt;
            
            physics_resolve_x(physics_body, _dt);
            physics_resolve_y(physics_body, _dt);
            physics_body.sync_to_instance(id);
            
            exit;
        }
        
        var _inst_x = inst.x;
        var _inst_y = inst.y;
        var _distance = point_distance(x, y, _inst_x, _inst_y);
        
        if (_distance >= 6.5 * TILE_SIZE)
        {
            // Too far from player - just physics
            if (physics_body.collision.ground)
            {
                physics_body.vel_x = lerp_delta(physics_body.vel_x, 0, 0.3, _dt);
            }
            
            physics_body.vel_y += attribute.get_gravity() * _dt;
            
            physics_resolve_x(physics_body, _dt);
            physics_resolve_y(physics_body, _dt);
            physics_body.sync_to_instance(id);
            
            exit;
        }
        
        // Attract to player
        var _speed = 5.2;
        
        physics_body.vel_x = lerp_delta(physics_body.vel_x, sign(_inst_x - x) * _speed, 0.02, _dt);
        physics_body.vel_y = lerp_delta(physics_body.vel_y, sign(_inst_y - y) * _speed, 0.02, _dt);
        
        // No gravity during attraction
        physics_resolve_x(physics_body, _dt);
        physics_resolve_y(physics_body, _dt);
        physics_body.sync_to_instance(id);
    }
}