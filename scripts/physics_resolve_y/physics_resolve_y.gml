/// @desc Resolve Y-axis collision - move body and handle ground/ceiling (instance context version)
/// @param {Struct.PhysicsBody} _body
/// @param {Real} _dt

function physics_resolve_y(_body, _dt)
{
    var _vy = _body.vel_y * _dt;
    
    if (_vy == 0) return;
    
    var _distance = abs(_vy);
    var _direction = sign(_vy);
    var _size = abs(_body.scale_y * PHYSICS_TILE_CHECK_SIZE);
    
    // Check if immediately blocked
    if (tile_meeting(_body.pos_x, _body.pos_y + _direction))
    {
        _body.vel_y = 0;
        if (_direction > 0) _body.collision.ground = true;
        else _body.collision.ceiling = true;
        return;
    }
    
    // Fast path - no collision at destination
    var _dest_y = _body.pos_y + _vy;
    
    // Tunneling prevention: check midpoints for large movements
    var _tunneling_safe = true;
    if (_distance > PHYSICS_TILE_CHECK_SIZE * 2)
    {
        var _mid_count = ceil(_distance / (PHYSICS_TILE_CHECK_SIZE * 2));
        for (var i = 1; i < _mid_count; ++i)
        {
            var _p = _body.pos_y + (_vy * (i / _mid_count));
            if (tile_meeting(_body.pos_x, _p))
            {
                _tunneling_safe = false;
                break;
            }
        }
    }
    
    if (_tunneling_safe && !tile_meeting(_body.pos_x, _dest_y))
    {
        _body.pos_y = _dest_y;
        return;
    }
    
    // Head bump nudge (when jumping into corner)
    if (_direction < 0)
    {
        for (var j = 1; j <= PHYSICS_GLOBAL_THRESHOLD_NUDGE; ++j)
        {
            if (!tile_meeting(_body.pos_x + j, _body.pos_y))
            {
                _body.pos_x += j;
                break;
            }
            if (!tile_meeting(_body.pos_x - j, _body.pos_y))
            {
                _body.pos_x -= j;
                break;
            }
        }
    }
    
    // Collision detected: Binary search for contact point
    // Complexity: O(log(distance)) with early termination
    var _low = 0;
    var _high = _distance;
    var _best = 0;
    
    // Early termination when sub-pixel precision reached (< 0.5px)
    while ((_high - _low) >= 0.5)
    {
        var _mid = (_low + _high) * 0.5;  // Multiply is faster than divide
        var _test_pos = _body.pos_y + (_direction * _mid);
        
        if (!tile_meeting(_body.pos_x, _test_pos))
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
    _body.pos_y += _direction * _best;
    
    // Handle collision state
    _body.vel_y = 0;
    if (_direction > 0) _body.collision.ground = true;
    else _body.collision.ceiling = true;
}
