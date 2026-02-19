/// @desc Resolve collision between two physics bodies
/// @param {Struct.PhysicsBody} _body
/// @param {Struct.PhysicsBody} _other
/// @param {real} [_push_strength=0.5]
function physics_resolve_collision(_body, _other, _push_strength = 0.5)
{
    if (_other == _body) return;
    if (_other[$ "static"] == true && _body[$ "static"] == true) return;
    
    // Get dimensions
    var _half_w = (_body[$ "width"] ?? 8) / 2;
    var _half_h = (_body[$ "height"] ?? 8) / 2;
    var _x1 = _body.pos_x - _half_w;
    var _y1 = _body.pos_y - _half_h;
    var _x2 = _body.pos_x + _half_w;
    var _y2 = _body.pos_y + _half_h;

    var _other_half_w = (_other[$ "width"] ?? 8) / 2;
    var _other_half_h = (_other[$ "height"] ?? 8) / 2;
    var _ox1 = _other.pos_x - _other_half_w;
    var _oy1 = _other.pos_y - _other_half_h;
    var _ox2 = _other.pos_x + _other_half_w;
    var _oy2 = _other.pos_y + _other_half_h;
    
    // AABB overlap check
    if (_x1 >= _ox2 || _x2 <= _ox1 || _y1 >= _oy2 || _y2 <= _oy1)
    {
        return;
    }
    
    // Calculate overlap on each axis
    var _overlap_x, _overlap_y;
    
    if (_body.pos_x < _other.pos_x)
    {
        _overlap_x = _x2 - _ox1;
    }
    else
    {
        _overlap_x = _ox2 - _x1;
    }
    
    if (_body.pos_y < _other.pos_y)
    {
        _overlap_y = _y2 - _oy1;
    }
    else
    {
        _overlap_y = _oy2 - _y1;
    }
    
    // Push apart along minimum overlap axis
    if (_overlap_x < _overlap_y)
    {
        var _push = _overlap_x * _push_strength;
        
        // Backup velocities
        var _vx_body = _body.vel_x;
        var _vx_other = _other.vel_x;
        
        if (_body.pos_x < _other.pos_x)
        {
            // Push body Left
            if (!(_body[$ "static"] ?? false))
            {
                with (_body.id)
                {
                    physics_body.vel_x = -_push;
                    physics_move_contact_x(physics_body);
                }
            }
            
            // Push other Right
            if (!(_other[$ "static"] ?? false))
            {
                with (_other.id)
                {
                    physics_body.vel_x = _push * (1 - _push_strength);
                    physics_move_contact_x(physics_body);
                }
            }
        }
        else
        {
            // Push body Right
            if (!(_body[$ "static"] ?? false))
            {
                with (_body.id)
                {
                    physics_body.vel_x = _push;
                    physics_move_contact_x(physics_body);
                }
            }
            
            // Push other Left
            if (!(_other[$ "static"] ?? false))
            {
                with (_other.id)
                {
                    physics_body.vel_x = -_push * (1 - _push_strength);
                    physics_move_contact_x(physics_body);
                }
            }
        }
        
        // Restore velocities
        _body.vel_x = _vx_body;
        _other.vel_x = _vx_other;
    }
    else
    {
        var _push = _overlap_y * _push_strength;
        
        // Backup velocities
        var _vy_body = _body.vel_y;
        var _vy_other = _other.vel_y;
        
        if (_body.pos_y < _other.pos_y)
        {
            // Push body Up
            if (!(_body[$ "static"] ?? false))
            {
                with (_body.id)
                {
                    physics_body.vel_y = -_push;
                    physics_move_contact_y(physics_body);
                }
            }
            
            // Push other Down
            if (!(_other[$ "static"] ?? false))
            {
                with (_other.id)
                {
                    physics_body.vel_y = _push * (1 - _push_strength);
                    physics_move_contact_y(physics_body);
                }
            }
        }
        else
        {
            // Push body Down
            if (!(_body[$ "static"] ?? false))
            {
                with (_body.id)
                {
                    physics_body.vel_y = _push;
                    physics_move_contact_y(physics_body);
                }
            }
            
            // Push other Up
            if (!(_other[$ "static"] ?? false))
            {
                with (_other.id)
                {
                    physics_body.vel_y = -_push * (1 - _push_strength);
                    physics_move_contact_y(physics_body);
                }
            }
        }
        
        // Restore velocities
        _body.vel_y = _vy_body;
        _other.vel_y = _vy_other;
    }
}
