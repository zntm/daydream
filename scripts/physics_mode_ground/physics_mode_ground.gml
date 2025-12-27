/// @desc Ground movement mode - normal gravity, horizontal movement with jumping
/// @param {Struct.PhysicsBody} _body
/// @param {Struct.InputState} _input
/// @param {Real} _dt

function physics_mode_ground(_body, _input, _dt)
{
    var _attr = _body.attribute;
    
    // Horizontal movement
    var _move_speed = (_attr != undefined) ? _attr.get_movement_speed() : PHYSICS_MOVE_SPEED_GROUND;
    var _target_vx = _input.move_x * _move_speed;
    
    _body.vel_x = lerp_delta(_body.vel_x, _target_vx, PHYSICS_MOVE_ACCEL_GROUND, _dt);
    
    // Gravity
    var _gravity = (_attr != undefined) ? _attr.get_gravity() : PHYSICS_GRAVITY_DEFAULT;
    var _accel = _gravity * _dt / 2;
    
    _body.vel_y = clamp(
        _body.vel_y + _accel,
        -PHYSICS_TERMINAL_VELOCITY,
        PHYSICS_TERMINAL_VELOCITY
    );
    
    // Jump processing
    physics_process_jump(_body, _input, _dt);
    
    // Apply second half of gravity (Verlet integration)
    _body.vel_y = clamp(
        _body.vel_y + _accel,
        -PHYSICS_TERMINAL_VELOCITY,
        PHYSICS_TERMINAL_VELOCITY
    );
}
