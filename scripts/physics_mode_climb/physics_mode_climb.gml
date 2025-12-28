/// @desc Climbing movement mode - wall-attached vertical movement
/// @param {Struct.PhysicsBody} _body
/// @param {Struct.InputState} _input
/// @param {Real} _dt

function physics_mode_climb(_body, _input, _dt)
{
    var _attr = _body.attribute;
    
    // Get climb speed (with fallback)
    var _speed = PHYSICS_MOVE_SPEED_CLIMB;
    if (_attr != undefined)
    {
        _speed = _attr[$ "___climb_speed"] ?? _attr.get_movement_speed() * 0.5;
    }
    
    // Horizontal movement (small amount for repositioning)
    _body.vel_x = lerp_delta(_body.vel_x, _input.move_x * _speed * 0.3, PHYSICS_MOVE_ACCEL_CLIMB, _dt);
    
    // Vertical movement on wall
    _body.vel_y = lerp_delta(_body.vel_y, _input.move_y * _speed, PHYSICS_MOVE_ACCEL_CLIMB, _dt);
    
    // Jump off wall
    if (_input.jump_pressed)
    {
        var _wall_dir = _body.collision.wall_left ? 1 : -1;
        var _jump_power = (_attr != undefined) ? _attr.get_jump_height() : PHYSICS_JUMP_HEIGHT;
        var _wall_jump_power = (_attr != undefined) ? (_attr[$ "___wall_jump_power"] ?? PHYSICS_WALL_JUMP_POWER) : PHYSICS_WALL_JUMP_POWER;
        
        _body.vel_x = _wall_dir * _wall_jump_power;
        _body.vel_y = -_jump_power * PHYSICS_WALL_JUMP_VERTICAL_DAMPING * _dt;
        
        // Transition back to ground mode (will be detected next frame)
        _body.mode = MOVEMENT_MODE.GROUND;
        _body.jump.count = 1;  // Wall jump counts as first jump
    }
}
