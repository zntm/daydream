function control_physics(_dt, _id)
{
    with (_id)
    {
        var _direction = input_right - input_left;
        
        if (_direction != 0)
        {
            image_xscale = abs(image_xscale) * _direction;
        }
        
        var _physics = entity_value.physics;
        
        xvelocity = lerp_delta(xvelocity, _direction * _physics.movement_speed * _dt, 0.3, _dt);
        
        control_physics_x();
        
        if (jump_count == 0)
        {
            if (!tile_meeting(x, y + 1))
            {
                coyote_time += _dt;
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
        
        if (jump_count > _physics.jump_count_max)
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
                jump_pressed += _dt;
            }
        }
        
        var _is_jumping = false;
        
        if (jump_pressed >= _jump_time)
        {
            jump_pressed = infinity;
        }
        else if (jump_pressed > 0)
        {
            yvelocity = -_physics.jump_height * _dt * (1 - power(jump_pressed / _jump_time, _physics.jump_falloff));
        }
        
        control_physics_y(_dt, _physics.gravity);
        
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