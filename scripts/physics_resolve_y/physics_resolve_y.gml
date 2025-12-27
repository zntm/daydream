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
    
    // Fast path
    if (_distance <= _size && !tile_meeting(_body.pos_x, _body.pos_y + _vy))
    {
        _body.pos_y += _vy;
        return;
    }
    
    // Step through movement
    var _remaining = _distance;
    
    while (_remaining > 0)
    {
        var _step = min(_remaining, _size);
        var _offset = _direction * _step;
        
        if (!tile_meeting(_body.pos_x, _body.pos_y + _offset))
        {
            _body.pos_y += _offset;
            _remaining -= _step;
            continue;
        }
        
        // Head bump nudge (when jumping into corner)
        if (_direction < 0)
        {
            for (var j = 1; j <= PHYSICS_GLOBAL_THRESHOLD_NUDGE; ++j)
            {
                if (!tile_meeting(_body.pos_x + j, _body.pos_y))
                {
                    _body.pos_x += j;
                    continue;  // Continue outer loop
                }
                if (!tile_meeting(_body.pos_x - j, _body.pos_y))
                {
                    _body.pos_x -= j;
                    continue;
                }
            }
        }
        
        // Binary search
        var _low = 0;
        var _high = abs(_offset);
        var _best = 0;
        
        repeat (4)
        {
            if (_low > _high) break;
             
            var _mid = (_low + _high) div 2;
             if (_mid == 0) 
            {
                _low = 1;
                continue;
            }

            var _test_pos = _body.pos_y + (_direction * _mid);
            if (!tile_meeting(_body.pos_x, _test_pos))
            {
                _best = _mid;
                _low = _mid + 1;
            }
            else
            {
                _high = _mid - 1;
            }
        }
        
        if (_best > 0)
        {
             _body.pos_y += _direction * _best;
        }

        // Hit the ground/ceiling
        _body.vel_y = 0;
        if (_direction > 0) _body.collision.ground = true;
        else _body.collision.ceiling = true;
        return;
    }
}
