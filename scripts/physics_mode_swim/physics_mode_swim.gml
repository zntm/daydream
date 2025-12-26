/// @desc Swimming movement mode - buoyancy, drag, 360° movement
/// @param {Struct.PhysicsBody} _body
/// @param {Struct.InputState} _input
/// @param {Real} _dt

function physics_mode_swim(_body, _input, _dt)
{
    var _attr = _body.attribute;
    
    // Get swim speed (with fallback)
    var _speed = 2.5;
    if (_attr != undefined)
    {
        _speed = _attr[$ "___swim_speed"] ?? _attr.get_movement_speed() * 0.7;
    }
    
    var _accel = 0.15;  // More sluggish than air
    var _drag = 0.92;   // Water resistance
    
    // 360° movement with drag
    var _target_vx = _input.move_x * _speed;
    var _target_vy = _input.move_y * _speed;
    
    // Apply drag first
    _body.vel_x *= _drag;
    _body.vel_y *= _drag;
    
    // Then lerp towards target
    _body.vel_x = lerp_delta(_body.vel_x, _target_vx, _accel, _dt);
    _body.vel_y = lerp_delta(_body.vel_y, _target_vy, _accel, _dt);
    
    // Subtle buoyancy (float upward when not moving)
    if (_input.move_y == 0)
    {
        _body.vel_y -= PHYSICS_BUOYANCY * _dt;
    }
    
    // Jump input makes you swim upward faster
    if (_input.jump_held)
    {
        _body.vel_y = lerp_delta(_body.vel_y, -_speed, _accel * 2, _dt);
    }
}
