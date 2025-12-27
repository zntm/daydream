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
    
    // Fast path - small movement with no collision
    if (_distance <= _size && !tile_meeting(_body.pos_x + _vx, _body.pos_y))
    {
        _body.pos_x += _vx;
        return;
    }
    
    // Step through movement
    var _remaining = _distance;
    
    while (_remaining > 0)
    {
        var _step = min(_remaining, _size);
        var _offset = _direction * _step;
        
        if (!tile_meeting(_body.pos_x + _offset, _body.pos_y))
        {
            _body.pos_x += _offset;
            _remaining -= _step;
            continue;
        }
        
        // Binary search for precision (limit 4 iterations for size 8-16)
        var _low = 0;
        var _high = abs(_offset);
        var _best = 0;
        
        // 4 iterations covers range up to 16 pixels precision
        repeat (4) 
        {
            if (_low > _high) break;
            
            var _mid = (_low + _high) div 2;
            if (_mid == 0) // Tiny step optimization
            {
                _low = 1; 
                continue;
            }
            
            var _test_pos = _body.pos_x + (_direction * _mid);
            if (!tile_meeting(_test_pos, _body.pos_y))
            {
                _best = _mid;
                _low = _mid + 1;
            }
            else
            {
                _high = _mid - 1;
            }
        }
        
        // Commit best move
        if (_best > 0)
        {
            _body.pos_x += _direction * _best;
        }

        // We hit the wall (since we entered this block because full step failed)
        _body.vel_x = 0;
        if (_direction > 0) _body.collision.wall_right = true;
        else _body.collision.wall_left = true;
        return;
        break;
    }
}
