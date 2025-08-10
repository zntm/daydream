function control_creature(_dt)
{
    var _data = global.creature_data[$ _id];
    
    if (timer_immunity <= 0)
    {
        var _inst = instance_place(x, y, obj_Tool);
        
        if (instance_exists(_inst))
        {
            timer_immunity = 4;
            
            inst_predator = _inst.inst_owner;
            
            repeat (irandom_range(8, 14))
            {
                spawn_particle(x - irandom_range(-TILE_SIZE / 2, TILE_SIZE / 2), y - irandom_range(-TILE_SIZE / 2, TILE_SIZE / 2), "phantasia:entity/damage");
            }
        }
    }
    
    if (timer_immunity > 0)
    {
        timer_immunity = max(0, timer_immunity - (_dt / GAME_TICK));
        
        if (timer_immunity <= 0)
        {
            inst_predator = noone;
        }
    }
    
    if (timer_immunity > 0)
    {
        var _direction = x - inst_predator.x;
        
        if (chance(0.1 * _dt))
        {
            if (_direction > 0)
            {
                input_left  = false;
                input_right = true;
            }
            else
            {
                input_left  = true;
                input_right = false;
            }
        }
    }
    else if (chance(0.01 * _dt))
    {
        if (chance(0.2))
        {
            if (input_left) || (input_right)
            {
                input_left = input_right;
                input_right = !input_left;
            }
            else
            {
                if (chance(0.5))
                {
                    input_left = true;
                    input_right = false;
                }
                else
                {
                    input_left = false;
                    input_right = true;
                }
            }
        }
        else
        {
            input_left = false;
            input_right = false;
        }
    }
    
    var _direction = input_right - input_left;
    
    if (_direction != 0)
    {
        image_xscale = abs(image_xscale) * _direction;
        
        if (!input_jump)
        {
            var _xto = x + (_direction * attribute.get_collision_box_width());
            
            if (tile_meeting(x, y + 1)) && (tile_meeting(_xto, y - 1)) && (entity_ai_fall_detection(_xto, y - (TILE_SIZE * 2), -attribute.get_collision_box_height(), 2) >= 2)
            {
                input_jump = true;
                input_jump_pressed = true;
            }
        }
    }
    
    control_physics_input(_dt, id, ((timer_panic > 0) ? 1.5 : 1));
    control_physics(_dt, id);
    
    control_entity_sfx(_dt);
    
    control_physics_input_after(_dt, id);
    
    if (attribute.has_boolean(ATTRIBUTE_BOOLEAN.HAS_REGENERATION))
    {
        control_entity_regeneration(_dt / GAME_TICK);
    }
    
    if (input_jump) && (chance(0.4 * _dt))
    {
        input_jump = false;
        input_jump_pressed = false;
    }
}