/// @desc Ground movement mode - normal gravity, horizontal movement with jumping
/// @param {Struct.PhysicsBody} _body
/// @param {Struct.InputState} _input
/// @param {Real} _dt

function physics_mode_ground(_body, _input)
{
    var _attr = _body.attribute;
    
    // Horizontal movement
    var _move_speed = (_attr != undefined) ? _attr.get_movement_speed() : PHYSICS_MOVE_SPEED_GROUND;
    
    if (_input.sprint_held)
    {
        _move_speed *= 1.25;
    }
    
    var _target_vx = _input.move_x * _move_speed;
    
    if (variable_instance_exists(_body.id, "timer_dash") && _body.id.timer_dash > 0)
    {
        // Skip horizontal acceleration during dash/knockback/special movement
    }
    else
    {
        _body.vel_x = lerp_delta(_body.vel_x, _target_vx, PHYSICS_MOVE_ACCEL_GROUND, 1);
    }
    
    // Gravity
    var _gravity = (_attr != undefined) ? _attr.get_gravity() : PHYSICS_GRAVITY_DEFAULT;
    var _accel = _gravity / 2;
    
    _body.vel_y = clamp(
        _body.vel_y + _accel,
        -PHYSICS_TERMINAL_VELOCITY,
        PHYSICS_TERMINAL_VELOCITY
    );
    
    // Jump processing
    physics_process_jump(_body, _input);
    
    // Apply second half of gravity (Verlet integration)
    _body.vel_y = clamp(
        _body.vel_y + _accel,
        -PHYSICS_TERMINAL_VELOCITY,
        PHYSICS_TERMINAL_VELOCITY
    );
}
