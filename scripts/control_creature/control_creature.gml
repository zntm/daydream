function control_creature(_dt)
{
    var _data = global.creature_data[$ _id];
    
    if (chance(0.01 * _dt))
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
    
    control_physics_input(_dt, id);
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