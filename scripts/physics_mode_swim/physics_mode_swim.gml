/// @desc Swimming movement mode - buoyancy, drag, 360° movement
/// @param {Struct.PhysicsBody} _body
/// @param {Struct.InputState} _input

function physics_mode_swim(_body, _input)
{
    var _attr = _body.attribute;
    
    // Get swim speed (with fallback)
    var _speed = PHYSICS_MOVE_SPEED_SWIM;
    if (_attr != undefined)
    {
        _speed = _attr[$ "___swim_speed"] ?? _attr.get_movement_speed() * 0.7;
    }
    
    var _accel = PHYSICS_MOVE_ACCEL_SWIM;  // More sluggish than air
    var _drag = PHYSICS_MOVE_DRAG_SWIM;   // Water resistance
    
    // 360° movement with drag
    var _target_vx = _input.move_x * _speed;
    var _target_vy = _input.move_y * _speed;
    
    // Apply drag first
    _body.vel_x *= _drag;
    _body.vel_y *= _drag;
    
    // Then lerp towards target
    _body.vel_x = lerp_delta(_body.vel_x, _target_vx, _accel);
    _body.vel_y = lerp_delta(_body.vel_y, _target_vy, _accel);

    // If you're not actively swimming upward, you should slowly sink.
    if (!_input.jump_held) && (_input.move_y == 0)
    {
        _body.vel_y = lerp_delta(_body.vel_y, _speed * 0.35, _accel);
    }
    
    // Jump input makes you swim upward faster
    if (_input.jump_held)
    {
        _body.vel_y = lerp_delta(_body.vel_y, -_speed, _accel * 2);
    }
}
