function spawn_particle(_x, _y, _id, _colour = c_white)
{
    var _data = global.particle_data[$ _id];
    
    with (instance_create_layer(_x, _y, "Instances", obj_Particle))
    {
        id._id = _id;
        
        attribute = _data.get_attribute();
        
        if (attribute.has_collision_box())
        {
            init_entity_physics(smart_value(_data.get_scale()));
        }
        else
        {
        	entity_scale = smart_value(_data.get_scale());
        }
        
        if (_data.get_xspeed_type() == PARTICLE_MOVEMENT_TYPE.REFERENCE)
        {
            var _xspeed = _data.get_xspeed();
            
            if (_xspeed == "phantasia:weather_wind")
            {
                _xspeed = global.world_save_data.weather_wind;
            }
            
            xvelocity = (smart_value(_xspeed) + smart_value(_data.get_xspeed_offset())) * smart_value(_data.get_xspeed_multiplier());
        }
        else
        {
            xvelocity = smart_value(_data.get_xspeed());
        }
        
        if (_data.get_yspeed_type() == PARTICLE_MOVEMENT_TYPE.REFERENCE)
        {
            var _yspeed = _data.get_yspeed();
            
            if (_yspeed == "phantasia:weather_wind")
            {
                _yspeed = global.world_save_data.weather_wind;
            }
            
            yvelocity = (smart_value(_yspeed) + smart_value(_data.get_yspeed_offset())) * smart_value(_data.get_yspeed_multiplier());
        }
        else
        {
            yvelocity = smart_value(_data.get_yspeed());
        }
        
        rotation_increment = smart_value(_data.get_rotation_increment());
        
        image_angle = smart_value(_data.get_rotation());
        image_blend = _colour;
        
        timer_life = smart_value(_data.get_lifetime());
        timer_life_max = timer_life;
    }
}