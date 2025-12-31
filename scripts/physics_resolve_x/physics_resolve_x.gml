/// @desc Resolve X-axis collision - Hybrid (Binary Search + Iterative Stepping)
/// @param {Struct.PhysicsBody} _body
/// @param {Real} _dt

function physics_resolve_x(_body, _dt)
{
    var _vx = _body.vel_x * _dt;
    
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
    
    // 3. Hybrid approach
    // Step A: Binary Search to get close quickly (optimization for high speeds)
    // Only worth it if distance is significant (e.g. > 4 pixels)
    
    var _dist_remain = _distance;
    
    if (_dist_remain > 4)
    {
        var _low = 0;
        var _high = _dist_remain;
        var _best = 0;
        
        // Search until range is small (~2px)
        while ((_high - _low) > 2)
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
        
        // Move the safe amount found by binary search
        _body.pos_x += _direction * _best;
        _dist_remain -= _best;
    }
    
    // Step B: Iterative Stepping for the final gap (Pixel-Perfect Accuracy)
    // Now we are close (within ~2-4px + remainder), so O(N) is cheap here.
    
    var _move = 0;
    var _limit = ceil(_dist_remain);
    var _hit = false;
    
    for (var i = 1; i <= _limit; ++i)
    {
        if (!tile_meeting(_body.pos_x + _direction, _body.pos_y))
        {
            _body.pos_x += _direction;
            _move += 1;
        }
        else
        {
            _hit = true;
            break;
        }
    }
    
    // Handle sub-pixel remainder if no hit
    if (!_hit)
    {
        var _final_fraction = _dist_remain - _move;
        if (_final_fraction > 0 && !tile_meeting(_body.pos_x + (_direction * _final_fraction), _body.pos_y))
        {
             _body.pos_x += _direction * _final_fraction;
        }
    }
    else
    {
        // Hit logic
        _body.vel_x = 0;
        if (_direction > 0) _body.collision.wall_right = true;
        else _body.collision.wall_left = true;
    }
}
