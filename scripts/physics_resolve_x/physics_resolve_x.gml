/// @desc Resolve X-axis collision - move body and handle wall collisions (instance context version)
/// @param {Struct.PhysicsBody} _body
/// @param {Real} _dt

function physics_resolve_x(_body, _dt)
{
    var _vx = _body.vel_x * _dt;
    
    if (_vx == 0) return;
    
    var _distance = abs(_vx);
    var _direction = sign(_vx);
    var _size = abs(_body.scale_x * 8);
    
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
        
        // Pixel-by-pixel for precision
        for (var i = abs(_offset); i > 0; i -= 1)
        {
            var _fine = _direction * min(i, 1);
            
            if (!tile_meeting(_body.pos_x + _fine, _body.pos_y))
            {
                _body.pos_x += _fine;
                continue;
            }
            
            _body.vel_x = 0;
            if (_direction > 0) _body.collision.wall_right = true;
            else _body.collision.wall_left = true;
            return;
        }
        break;
    }
}
