function control_particle(_dt)
{
    timer_life -= _dt / GAME_TICK;
    
    if (timer_life <= 0)
    {
        instance_destroy();
        
        exit;
    }
    
    var _data = global.particle_data[$ _id];
    
    if (attribute.has_collision_box())
    {
        control_physics_x(_dt);
        control_physics_y(_dt, attribute.get_gravity());
        
        if (tile_meeting(x, y - 1)) || (tile_meeting(x + 1, y)) || (tile_meeting(x, y + 1)) || (tile_meeting(x - 1, y))
        {
            if (_data.get_on_collision_xspeed_type() == PARTICLE_MOVEMENT_TYPE.REFERENCE)
            {
                var _xspeed = _data.get_on_collision_xspeed();
                
                if (_xspeed == "phantasia:weather_wind")
                {
                    _xspeed = global.world_save_data.weather_wind;
                }
                
                xvelocity = (smart_value(_xspeed) + smart_value(_data.get_on_collision_xspeed_offset())) * smart_value(_data.get_on_collision_xspeed_multiplier());
            }
            else
            {
                xvelocity = smart_value(_data.get_on_collision_xspeed());
            }
            
            if (_data.get_on_collision_yspeed_type() == PARTICLE_MOVEMENT_TYPE.REFERENCE)
            {
                var _yspeed = _data.get_on_collision_yspeed();
                
                if (_yspeed == "phantasia:weather_wind")
                {
                    _yspeed = global.world_save_data.weather_wind;
                }
                
                yvelocity = (smart_value(_yspeed) + smart_value(_data.get_on_collision_yspeed_offset())) * smart_value(_data.get_on_collision_yspeed_multiplier());
            }
            else
            {
                yvelocity = smart_value(_data.get_on_collision_yspeed());
            }
        }
    }
    
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    var _camera_width  = global.camera_width;
    var _camera_height = global.camera_height;
    
    if (!rectangle_in_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, _camera_x, _camera_y, _camera_x + _camera_width, _camera_y + _camera_height))
    {
        instance_destroy();
    }
}