/// @desc Move X-axis with binary chop collision (swept)
/// @param {Struct.PhysicsBody} _body
function physics_move_contact_x(_body)
{
    var _vx = _body.vel_x;
    
    if (_vx == 0) return;
    
    var _distance = abs(_vx);
    var _direction = sign(_vx);
    
    // 1. Fast Path: Swept collision check for the whole move
    if (!tile_meeting_swept(_body.pos_x, _body.pos_y, _body.pos_x + _vx, _body.pos_y))
    {
        _body.pos_x += _vx;
        return;
    }
    
    // 2. Binary Chop (Swept)
    var _current_x = _body.pos_x;
    var _step = _distance;
    
    // Perform binary search to find the furthest safe distance
    // Using a fixed number of iterations for consistent performance (e.g., 10 iterations = ~0.001 precision for 10px move)
    // Or keep the epsilon approach for variable precision
    while (_step > 0.01)
    {
        _step *= 0.5;
        var _target_x = _current_x + (_direction * _step);
        
        // Check if the gap between current safe pos and target is clear
        if (!tile_meeting_swept(_current_x, _body.pos_y, _target_x, _body.pos_y))
        {
            _current_x = _target_x;
        }
    }
    
    _body.pos_x = _current_x;
    
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
    
    // 1. Fast Path: Swept collision check for the whole move
    if (!tile_meeting_swept(_body.pos_x, _body.pos_y, _body.pos_x, _body.pos_y + _vy))
    {
        _body.pos_y += _vy;
        return;
    }
    
    // 2. Binary Chop (Swept)
    var _current_y = _body.pos_y;
    var _step = _distance;
    
    // Perform binary search to find the furthest safe distance
    while (_step > 0.01)
    {
        _step *= 0.5;
        var _target_y = _current_y + (_direction * _step);
        
        // Check if the gap between current safe pos and target is clear
        if (!tile_meeting_swept(_body.pos_x, _current_y, _body.pos_x, _target_y))
        {
            _current_y = _target_y;
        }
    }
    
    _body.pos_y = _current_y;
    
    // Collision Response
    _body.vel_y = 0;
    if (_direction > 0) _body.collision.ground = true;
    else _body.collision.ceiling = true;
}
