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
        
        if (instance_exists(_inst)) && (_inst.hp > 0)
        {
            control_entity_damage(_inst, (owner != undefined) ? owner : id, damage);
            
            if (_data.is_destroy_on_collision())
            {
                instance_destroy();
                exit;
            }
        }
    }
    
    // --- Physics & Tile Collision ---
    if (attribute != undefined)
    {
        control_physics_x(_dt);
        control_physics_y(_dt, attribute.get_gravity());
        
        if (attribute.has_collision_box()) && ((tile_meeting(x, y - 1)) || (tile_meeting(x + 1, y)) || (tile_meeting(x, y + 1)) || (tile_meeting(x - 1, y)))
        {
            if (_data.is_destroy_on_collision())
            {
                instance_destroy();
                exit;
            }
            
            if (_data.get_on_collision_xspeed_type() == PROJECTILE_MOVEMENT_TYPE.REFERENCE)
            {
                var _xspeed = world_get_reference(_data.get_on_collision_xspeed());
                
                xvelocity = (smart_value(_xspeed) + smart_value(_data.get_on_collision_xspeed_offset())) * smart_value(_data.get_on_collision_xspeed_multiplier());
            }
            else
            {
                xvelocity = smart_value(_data.get_on_collision_xspeed());
            }
            
            if (_data.get_on_collision_yspeed_type() == PROJECTILE_MOVEMENT_TYPE.REFERENCE)
            {
                var _yspeed = world_get_reference(_data.get_on_collision_yspeed());
                
                yvelocity = (smart_value(_yspeed) + smart_value(_data.get_on_collision_yspeed_offset())) * smart_value(_data.get_on_collision_yspeed_multiplier());
            }
            else
            {
                yvelocity = smart_value(_data.get_on_collision_yspeed());
            }
        }
    }
}