/// @desc Spawn a projectile using new physics system
/// @param {Real} _x X position
/// @param {Real} _y Y position  
/// @param {String} _id Projectile data ID
/// @param {Real} _damage Damage value
/// @param {Real} [_xscale] Horizontal scale/direction
/// @param {Real} [_yscale] Vertical scale/direction
/// @param {Id.Instance} [_owner] Owner instance for tracking

function spawn_projectile(_x, _y, _id, _damage, _xscale = 1, _yscale = 1, _owner = noone)
{
    var _data = global.projectile_data[$ _id];
    
    with (instance_create_layer(_x, _y, "Instances", obj_Projectile))
    {
        id._id = _id;
        damage = _damage;
        owner = _owner;
        
        attribute = _data.get_attribute();
        
        // Create physics body
        physics_body = new PhysicsBody(attribute);
        physics_body.pos_x = x;
        physics_body.pos_y = y;
        
        var _scale = smart_value(_data.get_scale());
        physics_body.scale_x = _scale * _xscale;
        physics_body.scale_y = _scale * _yscale;
        
        image_xscale = physics_body.scale_x;
        image_yscale = physics_body.scale_y;
        
        // Set velocity
        if (_data.get_xspeed_type() == PARTICLE_MOVEMENT_TYPE.REFERENCE)
        {
            var _xspeed = world_get_reference(_data.get_xspeed());
            physics_body.vel_x = _xscale * (smart_value(_xspeed) + smart_value(_data.get_xspeed_offset())) * smart_value(_data.get_xspeed_multiplier());
        }
        else
        {
            physics_body.vel_x = _xscale * smart_value(_data.get_xspeed());
        }
        
        if (_data.get_yspeed_type() == PARTICLE_MOVEMENT_TYPE.REFERENCE)
        {
            var _yspeed = world_get_reference(_data.get_yspeed());
            physics_body.vel_y = _yscale * (smart_value(_yspeed) + smart_value(_data.get_yspeed_offset())) * smart_value(_data.get_yspeed_multiplier());
        }
        else
        {
            physics_body.vel_y = _yscale * smart_value(_data.get_yspeed());
        }
        
        rotation_increment = smart_value(_data.get_rotation_increment());
        image_angle = smart_value(_data.get_rotation());
        
        timer_life = smart_value(_data.get_lifetime());
        timer_life_max = timer_life;
        
        return id;
    }
}