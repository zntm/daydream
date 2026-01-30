/// @desc Item drop physics control using new physics system
/// @param {Real} _dt Delta time
/// @param {Id.Instance} _id Item drop instance

function control_physics_item_drop(_id)
{
    var _time = 1 / GAME_TICK;
    
    with (_id)
    {
        is_attracted = false;
        
        physics_body.sync_from_instance(id);
        physics_body.reset_collision();
        
        // During pickup delay, just physics
        if (timer_pickup > 0)
        {
            timer_pickup -= _time;
            
            // Friction on ground
            if (physics_body.collision.ground)
            {
                physics_body.vel_x = lerp_delta(physics_body.vel_x, 0, 0.3, 1);
            }
            
            // Gravity
            physics_body.vel_y += attribute.get_gravity();
            
            physics_move_contact_x(physics_body);
            physics_move_contact_y(physics_body);
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
                physics_body.vel_x = lerp_delta(physics_body.vel_x, 0, 0.3, 1);
            }
            
            var _grav = attribute.get_gravity();
            physics_body.vel_y += _grav;
            
            // show_debug_message($"[PHYSICS] Item Drop {id}: Gravity={_grav}, VelY={physics_body.vel_y}, PosY={physics_body.pos_y}");
            
            physics_move_contact_x(physics_body);
            physics_move_contact_y(physics_body);
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
                physics_body.vel_x = lerp_delta(physics_body.vel_x, 0, 0.3, 1);
            }
            
            physics_body.vel_y += attribute.get_gravity();
            
            physics_move_contact_x(physics_body);
            physics_move_contact_y(physics_body);
            physics_body.sync_to_instance(id);
            
            exit;
        }
        
        // Attract to player
        is_attracted = true;
        var _speed = 5.2;
        
        physics_body.vel_x = lerp_delta(physics_body.vel_x, sign(_inst_x - x) * _speed, 0.02, 1);
        physics_body.vel_y = lerp_delta(physics_body.vel_y, sign(_inst_y - y) * _speed, 0.02, 1);
        
        // No gravity during attraction
        physics_move_contact_x(physics_body);
        physics_move_contact_y(physics_body);
        physics_body.sync_to_instance(id);
    }
}