/// @desc Resolve Y-axis collision - move body and handle ground/ceiling (instance context version)
/// @param {Struct.PhysicsBody} _body
/// @param {Real} _dt

function physics_resolve_y(_body, _dt)
{
    var _vy = _body.vel_y * _dt;
    
    if (_vy == 0) return;
    
    var _distance = abs(_vy);
    var _direction = sign(_vy);
    var _size = abs(_body.scale_y * 8);
    
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
        
        // Pixel-by-pixel
        for (var i = abs(_offset); i > 0; i -= 1)
        {
            var _fine = _direction * min(i, 1);
            
            if (tile_meeting(_body.pos_x, _body.pos_y + _fine))
            {
                _body.vel_y = 0;
                if (_direction > 0) _body.collision.ground = true;
                else _body.collision.ceiling = true;
                return;
            }
            
            _body.pos_y += _fine;
        }
        break;
    }
}
