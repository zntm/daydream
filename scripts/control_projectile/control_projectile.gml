/// @desc Projectile control using new physics system
/// @param {Real} _dt Delta time

function control_projectile(_dt)
{
    timer_life -= _dt / GAME_TICK;
    
    if (timer_life <= 0)
    {
        instance_destroy();
        exit;
    }
    
    var _data = global.projectile_data[$ _id];
    
    // --- Entity Collision ---
    if (damage > 0)
    {
        var _inst = instance_place(x, y, obj_Creature);
        
        if (instance_exists(_inst) && _inst.hp > 0)
        {
            control_entity_damage(_inst, (owner != undefined) ? owner : id, damage);
            
            if (_data.is_destroy_on_collision())
            {
                instance_destroy();
                exit;
            }
        }
    }
    
    // --- Physics ---
    if (physics_body != undefined && attribute != undefined)
    {
        physics_body.sync_from_instance(id);
        
        // Apply gravity
        if (attribute.get_gravity() != 0)
        {
            physics_body.vel_y += attribute.get_gravity() * _dt / 2;
        }
        
        // Resolve collisions
        physics_resolve_x(physics_body, _dt);
        physics_resolve_y(physics_body, _dt);
        
        physics_body.sync_to_instance(id);
        
        // Tile collision behavior
        if (attribute.has_collision_box() && (tile_meeting(x, y - 1) || tile_meeting(x + 1, y) || tile_meeting(x, y + 1) || tile_meeting(x - 1, y)))
        {
            if (_data.is_destroy_on_collision())
            {
                instance_destroy();
                exit;
            }
            
            if (_data.get_on_collision_xspeed_type() == PROJECTILE_MOVEMENT_TYPE.REFERENCE)
            {
                var _xspeed = world_get_reference(_data.get_on_collision_xspeed());
                physics_body.vel_x = (smart_value(_xspeed) + smart_value(_data.get_on_collision_xspeed_offset())) * smart_value(_data.get_on_collision_xspeed_multiplier());
            }
            else
            {
                physics_body.vel_x = smart_value(_data.get_on_collision_xspeed());
            }
            
            if (_data.get_on_collision_yspeed_type() == PROJECTILE_MOVEMENT_TYPE.REFERENCE)
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
}