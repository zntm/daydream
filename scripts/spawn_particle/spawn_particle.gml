/// @function spawn_particle(_x, _y, _id, _colour)
/// @desc Spawn a particle using the optimized pool system
/// @param {real} _x X position
/// @param {real} _y Y position
/// @param {string} _id Particle data ID
/// @param {real} _colour Optional blend colour (default: c_white)
/// @returns {real} Pool index of spawned particle, or -1 if using legacy system
function spawn_particle(_x, _y, _id, _colour = c_white)
{
    var _data = global.particle_data[$ _id];
    
    if (_data == undefined) return -1;
    
    // Check if particle needs collision physics (use legacy system for these)
    var _attribute = _data.get_attribute();
    var _needs_collision = (_attribute != undefined) && (_attribute.has_collision_box());
    
    if (_needs_collision)
    {
        // Use legacy instance-based system for particles with collision
        with (instance_create_layer(_x, _y, "Instances", obj_Particle))
        {
            id._id = _id;
            
            attribute = _attribute;
            
            init_entity_physics(smart_value(_data.get_scale()));
            
            if (_data.get_xspeed_type() == PARTICLE_MOVEMENT_TYPE.REFERENCE)
            {
                var _xspeed = world_get_reference(_data.get_xspeed());
                
                xvelocity = (smart_value(_xspeed) + smart_value(_data.get_xspeed_offset())) * smart_value(_data.get_xspeed_multiplier());
            }
            else
            {
                xvelocity = smart_value(_data.get_xspeed());
            }
            
            if (_data.get_yspeed_type() == PARTICLE_MOVEMENT_TYPE.REFERENCE)
            {
                var _yspeed = world_get_reference(_data.get_yspeed());
                
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
        
        return -1; // Indicate legacy system used
    }
    
    // Use optimized pool system for simple particles
    return global.particle_pool.spawn(_x, _y, _id, _colour);
}
