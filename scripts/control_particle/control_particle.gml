/// @desc Particle control using new physics system
/// @param {Real} _dt Delta time

function control_particle(_dt)
{
    timer_life -= _dt / GAME_TICK;
    
    if (timer_life <= 0)
    {
        instance_destroy();
        exit;
    }
    
    var _data = global.particle_data[$ _id];
    
    if (physics_body != undefined && attribute != undefined && attribute.has_collision_box())
    {
        // Physics-enabled particle
        physics_body.sync_from_instance(id);
        
        // Apply gravity
        physics_body.vel_y += attribute.get_gravity() * _dt / 2;
        
        // Resolve collisions
        physics_resolve_x(physics_body, _dt);
        physics_resolve_y(physics_body, _dt);
        
        physics_body.sync_to_instance(id);
        
        // Check for tile collision and apply on_collision behavior
        if (tile_meeting(x, y - 1) || tile_meeting(x + 1, y) || tile_meeting(x, y + 1) || tile_meeting(x - 1, y))
        {
            if (_data.get_on_collision_xspeed_type() == PARTICLE_MOVEMENT_TYPE.REFERENCE)
            {
                var _xspeed = world_get_reference(_data.get_on_collision_xspeed());
                physics_body.vel_x = (smart_value(_xspeed) + smart_value(_data.get_on_collision_xspeed_offset())) * smart_value(_data.get_on_collision_xspeed_multiplier());
            }
            else
            {
                physics_body.vel_x = smart_value(_data.get_on_collision_xspeed());
            }
            
            if (_data.get_on_collision_yspeed_type() == PARTICLE_MOVEMENT_TYPE.REFERENCE)
            {
                var _yspeed = world_get_reference(_data.get_on_collision_yspeed());
                physics_body.vel_y = (smart_value(_yspeed) + smart_value(_data.get_on_collision_yspeed_offset())) * smart_value(_data.get_on_collision_yspeed_multiplier());
            }
            else
            {
                physics_body.vel_y = smart_value(_data.get_on_collision_yspeed());
            }
        }
    }
    else
    {
        // Simple particles without collision - just move by velocity
        if (physics_body != undefined)
        {
            x += physics_body.vel_x * (_dt / GAME_TICK);
            y += physics_body.vel_y * (_dt / GAME_TICK);
        }
        
        // Apply rotation
        if (variable_instance_exists(id, "rotation_increment"))
        {
            image_angle += rotation_increment * (_dt / GAME_TICK);
        }
    }
    
    // Destroy if off-camera
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    var _camera_width = global.camera_width;
    var _camera_height = global.camera_height;
    
    if (!rectangle_in_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, _camera_x, _camera_y, _camera_x + _camera_width, _camera_y + _camera_height))
    {
        instance_destroy();
    }
}