/// @desc Process jump input and update velocity
/// @param {Struct.PhysicsBody} _body
/// @param {Struct.InputState} _input
/// @param {Real} _dt

function physics_process_jump(_body, _input, _dt)
{
    var _attr = _body.attribute;
    var _jump = _body.jump;
    
    var _jump_max = (_attr != undefined) ? _attr.get_jump_count_max() : 1;
    var _jump_time = (_attr != undefined) ? _attr.get_jump_time() : 12;
    var _jump_height = (_attr != undefined) ? _attr.get_jump_height() : 28.5;
    var _jump_falloff = (_attr != undefined) ? _attr.get_jump_falloff() : 2.2;
    
    // Coyote time - allow jumping shortly after leaving ground
    if (_jump.count == 0 && !_body.collision.ground)
    {
        _jump.coyote_time += _dt;
        
        if (_jump.coyote_time > PHYSICS_GLOBAL_timer_coyote)
        {
            _jump.count = 1;  // Lost coyote time
        }
    }
    
    // Jump initiation
    if (_input.jump_pressed && _jump.count < _jump_max)
    {
        ++_jump.count;
        _jump.held_time = 0;
    }
    
    // Check if over max jumps
    if (_jump.count > _jump_max)
    {
        _jump.held_time = infinity;
    }
    
    // Variable height jump - holding jump goes higher
    if (_input.jump_held)
    {
        // Check for ceiling collision
        if (_body.collision.ceiling)
        {
            _jump.held_time = infinity;
        }
        else
        {
            _jump.held_time += _dt;
            
            if (_jump.held_time > 0 && _jump.held_time < _jump_time)
            {
                // Curved jump force - stronger at start, weaker as held
                var _progress = _jump.held_time / _jump_time;
                var _force = 1 - power(_progress, _jump_falloff);
                
                _body.vel_y = -_jump_height * _dt * _force;
            }
        }
    }
    else
    {
        _jump.held_time = infinity;  // Released - no more jump force
    }
}
