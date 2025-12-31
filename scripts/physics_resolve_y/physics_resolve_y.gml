/// @desc Resolve Y-axis collision - Hybrid (Binary Search + Iterative Stepping)
/// @param {Struct.PhysicsBody} _body
/// @param {Real} _dt

function physics_resolve_y(_body, _dt)
{
    var _vy = _body.vel_y * _dt;
    
    if (_vy == 0) return;
    
    var _direction = sign(_vy);
    var _distance = abs(_vy);
    
    // 1. Initial overlap check (stuck protection)
    if (tile_meeting(_body.pos_x, _body.pos_y))
    {
        if (!tile_meeting(_body.pos_x, _body.pos_y - _direction))
        {
            _body.pos_y -= _direction;
        }
    }
    
    // 2. Fast Path: Check destination
    if (!tile_meeting(_body.pos_x, _body.pos_y + _vy))
    {
        _body.pos_y += _vy;
        return;
    }
    
    // 3. Binary Chop (High Precision)
    var _dist_remain = _distance;
    var _low = 0;
    var _high = _dist_remain;
    var _best = 0;
    
    // Perform binary search to find the furthest safe distance
    while ((_high - _low) > 0.01)
    {
        var _mid = (_low + _high) * 0.5;
        if (!tile_meeting(_body.pos_x, _body.pos_y + (_direction * _mid)))
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
        _body.pos_y += _direction * _best;
    }
    
    // Collision Response
    _body.vel_y = 0;
    if (_direction > 0) _body.collision.ground = true;
    else _body.collision.ceiling = true;
}
