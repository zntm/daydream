/// @desc Flying movement mode - no gravity, 360° movement
/// @param {Struct.PhysicsBody} _body
/// @param {Struct.InputState} _input
/// @param {Real} _dt

function physics_mode_fly(_body, _input, _dt)
{
    var _attr = _body.attribute;
    
    // Get fly speed (with fallback)
    var _speed = 8.65;  // Default creative mode speed
    if (_attr != undefined)
    {
        _speed = _attr[$ "___fly_speed"] ?? _attr.get_movement_speed() * 2;
    }
    
    var _accel = 0.25;
    
    // 360° movement
    var _target_vx = _input.move_x * _speed;
    var _target_vy = _input.move_y * _speed;
    
    _body.vel_x = lerp_delta(_body.vel_x, _target_vx, _accel, _dt);
    _body.vel_y = lerp_delta(_body.vel_y, _target_vy, _accel, _dt);
    
    // No gravity, no jumps in fly mode
}
