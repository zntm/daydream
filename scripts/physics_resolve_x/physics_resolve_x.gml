/// @desc Resolve X-axis collision - Hybrid (Binary Search + Iterative Stepping)
/// @param {Struct.PhysicsBody} _body
/// @param {Real} _dt

function physics_resolve_x(_body)
{
    var _vx = _body.vel_x;
    
    if (_vx == 0) return;
    
    var _direction = sign(_vx);
    var _distance = abs(_vx);
    
    // 1. Initial overlap check (stuck protection)
    if (tile_meeting(_body.pos_x, _body.pos_y))
    {
        if (!tile_meeting(_body.pos_x - _direction, _body.pos_y))
        {
            _body.pos_x -= _direction;
        }
    }
    
    // 2. Fast Path: Check destination
    if (!tile_meeting(_body.pos_x + _vx, _body.pos_y))
    {
        _body.pos_x += _vx;
        return;
    }
    
    // 3. Binary Chop (High Precision)
    var _dist_remain = _distance;
    var _low = 0;
    var _high = _dist_remain;
    var _best = 0;
    
    // Perform binary search to find the furthest safe distance
    // 0.01 precision is sufficient for sub-pixel movement
    while ((_high - _low) > 0.01)
    {
        var _mid = (_low + _high) * 0.5;
        if (!tile_meeting(_body.pos_x + (_direction * _mid), _body.pos_y))
        {
            _best = _mid;
            _low = _mid;
        }
        else
        {
            _high = _mid;
        }
    }
    
    // Apply the best safe movement
    if (_best > 0)
    {
        _body.pos_x += _direction * _best;
    }
    
    // Collision Response
    _body.vel_x = 0;
    if (_direction > 0) _body.collision.wall_right = true;
    else _body.collision.wall_left = true;
}
