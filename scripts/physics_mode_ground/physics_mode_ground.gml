/// @desc Ground movement mode - normal gravity, horizontal movement with jumping
/// @param {Struct.PhysicsBody} _body
/// @param {Struct.InputState} _input
/// @param {Real} _dt

#macro PHYSICS_TERMINAL_VELOCITY 24
#macro PHYSICS_BUOYANCY 0.5

function physics_mode_ground(_body, _input, _dt)
{
    var _attr = _body.attribute;
    
    // Horizontal movement
    var _move_speed = (_attr != undefined) ? _attr.get_movement_speed() : 3.1;
    var _target_vx = _input.move_x * _move_speed;
    
    _body.vel_x = lerp_delta(_body.vel_x, _target_vx, 0.3, _dt);
    
    // Gravity
    var _gravity = (_attr != undefined) ? _attr.get_gravity() : PHYSICS_GLOBAL_GRAVITY;
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
