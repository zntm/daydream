/// @desc Resolve X-axis collision - move body and handle wall collisions (instance context version)
/// @param {Struct.PhysicsBody} _body
/// @param {Real} _dt

function physics_resolve_x(_body, _dt)
{
    var _vx = _body.vel_x * _dt;
    
    if (_vx == 0) return;
    
    var _distance = abs(_vx);
    var _direction = sign(_vx);
    var _size = abs(_body.scale_x * PHYSICS_TILE_CHECK_SIZE);
    
    // Check if immediately blocked
    if (tile_meeting(_body.pos_x + _direction, _body.pos_y))
    {
        _body.vel_x = 0;
        if (_direction > 0) _body.collision.wall_right = true;
        else _body.collision.wall_left = true;
        return;
    }
    
    // Fast path - no collision at destination
    var _dest_x = _body.pos_x + _vx;
    
    // Tunneling prevention: check midpoints for large movements
    var _tunneling_safe = true;
    if (_distance > PHYSICS_TILE_CHECK_SIZE * 2)
    {
        var _mid_count = ceil(_distance / (PHYSICS_TILE_CHECK_SIZE * 2));
        for (var i = 1; i < _mid_count; ++i)
        {
            var _p = _body.pos_x + (_vx * (i / _mid_count));
            if (tile_meeting(_p, _body.pos_y))
            {
                _tunneling_safe = false;
                break;
            }
        }
    }
    
    if (_tunneling_safe && !tile_meeting(_dest_x, _body.pos_y))
    {
        _body.pos_x = _dest_x;
        return;
    }
    
    // Collision detected: Binary search for contact point
    // Complexity: O(log(distance)) with early termination
    // Max iterations: ceil(log2(distance / 0.5)) = ~10 for 512px movement
    var _low = 0;
    var _high = _distance;
    var _best = 0;
    
    // Early termination when sub-pixel precision reached (< 0.5px)
    while ((_high - _low) >= 0.5)
    {
        var _mid = (_low + _high) * 0.5;  // Multiply is faster than divide
        var _test_pos = _body.pos_x + (_direction * _mid);
        
        if (!tile_meeting(_test_pos, _body.pos_y))
        {
            _best = _mid;
            _low = _mid;
        }
        else
        {
            _high = _mid;
        }
    }
    
    // Commit best move
    _body.pos_x += _direction * _best;
    
    // Handle collision state
    _body.vel_x = 0;
    if (_direction > 0) _body.collision.wall_right = true;
    else _body.collision.wall_left = true;
}
