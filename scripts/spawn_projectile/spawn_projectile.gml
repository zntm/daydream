function spawn_projectile(_x, _y, _id, _damage, _xscale = 1, _yscale = 1)
{
    var _data = global.projectile_data[$ _id];
    
    with (instance_create_layer(_x, _y, "Instances", obj_Projectile))
    {
        id._id = _id;
        damage = _damage;
        
        attribute = _data.get_attribute();
        
        if (attribute != undefined) && (attribute.has_collision_box())
        {
            var _scale = smart_value(_data.get_scale());
            
            init_entity_physics(_scale, _scale);
        }
        else
        {
            var _scale = smart_value(_data.get_scale());
            
            entity_set_scale(_scale, _scale);
        }
        
        image_xscale *= _xscale;
        image_yscale *= _yscale;
        
        if (_data.get_xspeed_type() == PARTICLE_MOVEMENT_TYPE.REFERENCE)
        {
            var _xspeed = world_get_reference(_data.get_xspeed());
            
            xvelocity = _xscale * (smart_value(_xspeed) + smart_value(_data.get_xspeed_offset())) * smart_value(_data.get_xspeed_multiplier());
        }
        else
        {
            xvelocity = _xscale * smart_value(_data.get_xspeed());
        }
        
        if (_data.get_yspeed_type() == PARTICLE_MOVEMENT_TYPE.REFERENCE)
        {
            var _yspeed = world_get_reference(_data.get_yspeed());
            
            yvelocity = _yscale * (smart_value(_yspeed) + smart_value(_data.get_yspeed_offset())) * smart_value(_data.get_yspeed_multiplier());
        }
        else
        {
            yvelocity = _yscale * smart_value(_data.get_yspeed());
        }
        
        rotation_increment = smart_value(_data.get_rotation_increment());
        
        image_angle = smart_value(_data.get_rotation());
        
        timer_life = smart_value(_data.get_lifetime());
        timer_life_max = timer_life;
        
        return id;
    }
}