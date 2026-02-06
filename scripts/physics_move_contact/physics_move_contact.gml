/// @desc Move X-axis with binary chop collision (swept)
/// @param {Struct.PhysicsBody} _body
function physics_move_contact_x(_body)
{
    var _vx = _body.vel_x;
    
    if (_vx == 0) return;
    
    var _distance = abs(_vx);
    var _direction = sign(_vx);
    
    // Horizontal collision ignores platforms (usually)
    // Adjust this mask if your game treats side-collisions with platforms as blocked
    var _collision_mask = ITEM_TYPE_BIT.SOLID;
    
    // Get collision dimensions from body's attribute for network-safe physics
    var _coll_w = (_body.attribute != undefined && _body.attribute.has_collision_box()) ? _body.attribute.get_collision_box_width() : 8;
    var _coll_h = (_body.attribute != undefined && _body.attribute.has_collision_box()) ? _body.attribute.get_collision_box_height() : 8;
    
    // 1. Fast Path: Swept collision check for the whole move
    if (!tile_meeting_swept(_body.pos_x, _body.pos_y, _body.pos_x + _vx, _body.pos_y, CHUNK_DEPTH_DEFAULT, _collision_mask, undefined, _coll_w, _coll_h))
    {
        _body.pos_x += _vx;
        return;
    }
    
    // 2. Binary Chop
    var _low = 0;
    var _high = _distance;
    
    // Keep chopping until precision is high enough
    while ((_high - _low) > 0.05)
    {
        var _mid = (_low + _high) * 0.5;
        var _target_x = _body.pos_x + (_direction * _mid);
        
        // Check if path to mid is clear
        if (!tile_meeting_swept(_body.pos_x, _body.pos_y, _target_x, _body.pos_y, CHUNK_DEPTH_DEFAULT, _collision_mask, undefined, _coll_w, _coll_h))
        {
            _low = _mid; // Safe to move at least this far
        }
        else
        {
            _high = _mid; // Blocked somewhere before or at mid
        }
    }
    
    // Apply safe movement
    _body.pos_x += (_direction * _low);
    
    // Collision Response
    _body.vel_x = 0;
    if (_direction > 0) _body.collision.wall_right = true;
    else _body.collision.wall_left = true;
}

/// @desc Move Y-axis with binary chop collision (swept)
/// @param {Struct.PhysicsBody} _body
function physics_move_contact_y(_body)
{
    var _vy = _body.vel_y;
    
    if (_vy == 0) return;
    
    var _distance = abs(_vy);
    var _direction = sign(_vy);
    
    // Vertical collision: Down = Solid + Platform, Up = Solid only
    var _collision_mask = ITEM_TYPE_BIT.SOLID;
    if (_direction > 0)
    {
        _collision_mask |= ITEM_TYPE_BIT.PLATFORM;
    }
    
    // Get collision dimensions from body's attribute for network-safe physics
    var _coll_w = (_body.attribute != undefined && _body.attribute.has_collision_box()) ? _body.attribute.get_collision_box_width() : 8;
    var _coll_h = (_body.attribute != undefined && _body.attribute.has_collision_box()) ? _body.attribute.get_collision_box_height() : 8;
    
    // 1. Fast Path: Swept collision check for the whole move
    if (!tile_meeting_swept(_body.pos_x, _body.pos_y, _body.pos_x, _body.pos_y + _vy, CHUNK_DEPTH_DEFAULT, _collision_mask, undefined, _coll_w, _coll_h))
    {
        _body.pos_y += _vy;
        return;
    }
    
    // 2. Binary Chop
    var _low = 0;
    var _high = _distance;
    
    while ((_high - _low) > 0.05)
    {
        var _mid = (_low + _high) * 0.5;
        var _target_y = _body.pos_y + (_direction * _mid);
        
        // Check if path to mid is clear
        if (!tile_meeting_swept(_body.pos_x, _body.pos_y, _body.pos_x, _target_y, CHUNK_DEPTH_DEFAULT, _collision_mask, undefined, _coll_w, _coll_h))
        {
            _low = _mid;
        }
        else
        {
            _high = _mid;
        }
    }
    
    // Apply safe movement
    _body.pos_y += (_direction * _low);
    
    // Collision Response
    _body.vel_y = 0;
    if (_direction > 0) _body.collision.ground = true;
    else _body.collision.ceiling = true;
}
