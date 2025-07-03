function control_physics_input(_dt, _id)
{
    with (_id)
    {
        var _direction = input_right - input_left;
        
        if (_direction != 0)
        {
            image_xscale = abs(image_xscale) * _direction;
        }
        
        var _on_ground = tile_meeting(x, y + 1);
        
        xvelocity = lerp_delta(xvelocity, _direction * attribute.get_movement_speed(), 0.3, _dt);
        
        if (jump_count == 0)
        {
            if (!_on_ground)
            {
                timer_coyote += _dt;
            }
            
            if (timer_coyote > PHYSICS_GLOBAL_timer_coyote)
            {
                jump_count = 1;
            }
        }
        
        if (input_jump_pressed)
        {
            ++jump_count;
            
            input_jump_pressed = false;
            
            jump_pressed = 0;
        }
        
        if (!input_jump)
        {
            jump_pressed = 0;
        }
        
        var _jump_time = attribute.get_jump_time();
        
        if (jump_count > attribute.get_jump_count_max())
        {
            jump_pressed = infinity;
        }
        else if (input_jump)
        {
            if (tile_meeting(x, y - 1))
            {
                jump_pressed = infinity;
            }
            else
            {
                jump_pressed += _dt;
            }
        }
        
        if (jump_pressed > 0) && (jump_pressed < _jump_time)
        {
            yvelocity = -attribute.get_jump_height() * _dt * (1 - power(jump_pressed / _jump_time, attribute.get_jump_falloff()));
        }
    }
}