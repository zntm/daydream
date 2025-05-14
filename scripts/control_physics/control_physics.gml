function control_physics(_tick, _id)
{
    with (_id)
    {
        var _direction = input_right - input_left;
        
        if (_direction != 0)
        {
            image_xscale = abs(image_xscale) * _direction;
        }
        
        var _physics = entity_value.physics;
        
        xvelocity = lerp_delta(xvelocity, _direction * _physics.movement_speed, 0.08, _tick);
        
        control_physics_x();
        
        if (jump_count == 0)
        {
            if (!tile_meeting(x, y + 1))
            {
                coyote_time += _tick;
            }
            
            if (coyote_time > PHYSICS_GLOBAL_COYOTE_TIME)
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
        
        var _jump_time = _physics.jump_time;
        
        if (jump_count > 2)
        {
            jump_pressed = infinity;
        }
        else if (input_jump)
        {
            if (tile_meeting(x, y - 1))
            {
                jump_pressed = infinity;
            }
            else if (jump_pressed < _jump_time)
            {
                jump_pressed = min(jump_pressed + _tick, _jump_time);
            }
        }
        
        if (jump_pressed < _jump_time)
        {
            if (jump_pressed > 0)
            {
                yvelocity = -_physics.jump_height * (1 - power(jump_pressed / _jump_time, 3.1));
            }
        }
        else
        {
            jump_presed = infinity;
        }
        
        control_physics_y(_physics.gravity * _tick);
        
        if (tile_meeting(x, y + 1))
        {
            jump_pressed = 0;
            
            jump_count = 0;
            coyote_time = 0;
        }
        
        if (tile_meeting(x, y - 1))
        {
            jump_pressed = infinity;
        }
    }
}