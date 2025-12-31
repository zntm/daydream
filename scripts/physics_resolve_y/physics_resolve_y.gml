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
    
    // 3. Hybrid approach
    // Step A: Binary Search to get close quickly (optimization for high speeds/fps drops)
    
    var _dist_remain = _distance;
    
    if (_dist_remain > 4)
    {
        var _low = 0;
        var _high = _dist_remain;
        var _best = 0;
        
        while ((_high - _low) > 2)
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
        
        _body.pos_y += _direction * _best;
        _dist_remain -= _best;
    }
    
    // Step B: Iterative Stepping for the final gap (Pixel-Perfect Accuracy)
    
    var _move = 0;
    var _limit = ceil(_dist_remain);
    var _hit = false;
    
    for (var i = 1; i <= _limit; ++i)
    {
        if (!tile_meeting(_body.pos_x, _body.pos_y + _direction))
        {
            _body.pos_y += _direction;
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
        if (_final_fraction > 0 && !tile_meeting(_body.pos_x, _body.pos_y + (_direction * _final_fraction)))
        {
             _body.pos_y += _direction * _final_fraction;
        }
    }
    else
    {
        // Hit logic
        _body.vel_y = 0;
        if (_direction > 0) _body.collision.ground = true;
        else _body.collision.ceiling = true;
    }
}
