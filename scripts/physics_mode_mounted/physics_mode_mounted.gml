/// @desc Mounted movement mode - rider follows mount physics
/// @param {Struct.PhysicsBody} _body The rider's body
/// @param {Struct.InputState} _input
/// @param {Real} _dt

function physics_mode_mounted(_body, _input, _dt)
{
    var _mount = _body.mount;
    
    if (_mount == undefined)
    {
        _body.mode = MOVEMENT_MODE.GROUND;
        return;
    }
    
    // Get mount data for offsets
    var _mount_id = _mount.mount_id;
    var _mount_data = global.mount_data[$ _mount_id];
    
    var _offset_x = 0;
    var _offset_y = -16;  // Default: sit on top
    
    if (_mount_data != undefined)
    {
        _offset_x = _mount_data.rider_offset_x;
        _offset_y = _mount_data.rider_offset_y;
    }
    
    // Pass input to mount if rider-controlled
    var _controlled = (_mount_data != undefined) ? _mount_data.controlled_by_rider : true;
    
    if (_controlled)
    {
        // Run mount's physics with rider's input
        physics_step(_mount, _input, _dt);
    }
    
    // Rider follows mount position
    _body.pos_x = _mount.pos_x + _offset_x;
    _body.pos_y = _mount.pos_y + _offset_y;
    _body.vel_x = _mount.vel_x;
    _body.vel_y = _mount.vel_y;
    
    // Copy collision state from mount
    _body.collision.ground = _mount.collision.ground;
    _body.collision.ceiling = _mount.collision.ceiling;
    _body.collision.wall_left = _mount.collision.wall_left;
    _body.collision.wall_right = _mount.collision.wall_right;
    
    // Check for dismount
    if (_input.mount_pressed)
    {
        mount_dismount(_body);
    }
}

/// @desc Mount a creature or summoned mount
/// @param {Struct.PhysicsBody} _rider
/// @param {Struct.PhysicsBody} _mount
/// @returns {Bool} Success
function mount_creature(_rider, _mount)
{
    // Already mounted
    if (_mount.rider != undefined) return false;
    
    _rider.mount = _mount;
    _mount.rider = _rider;
    _rider.mode = MOVEMENT_MODE.MOUNTED;
    
    return true;
}

/// @desc Dismount from current mount
/// @param {Struct.PhysicsBody} _rider
function mount_dismount(_rider)
{
    if (_rider.mount == undefined) return;
    
    var _mount = _rider.mount;
    
    // Unlink
    _mount.rider = undefined;
    _rider.mount = undefined;
    _rider.mode = MOVEMENT_MODE.GROUND;
    
    // Position rider beside mount
    var _direction = sign(_mount.vel_x);
    if (_direction == 0) _direction = 1;
    
    _rider.pos_x = _mount.pos_x + 16 * _direction;
    _rider.pos_y = _mount.pos_y;
    _rider.vel_x = _mount.vel_x * 0.5;
    _rider.vel_y = 0;
}
