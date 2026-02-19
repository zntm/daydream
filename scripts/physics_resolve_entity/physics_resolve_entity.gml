/// @desc Resolve entity-entity collisions using spatial grid or simple list
/// @param {Struct.PhysicsBody} _body The body to resolve
/// @param {Struct.SpatialGrid|Array} _entities Either a SpatialGrid or an array of bodies to check against
/// @param {real} [_push_strength=0.5] How much to push bodies apart (0-1)
function physics_resolve_entity(_body, _entities, _push_strength = 0.5)
{
    var _half_w = (_body[$ "width"] ?? 8) / 2;
    var _half_h = (_body[$ "height"] ?? 8) / 2;
    
    var _x1 = _body.pos_x - _half_w;
    var _y1 = _body.pos_y - _half_h;
    var _x2 = _body.pos_x + _half_w;
    var _y2 = _body.pos_y + _half_h;
    
    var _nearby;
    
    // Support both SpatialGrid and raw array
    if (is_struct(_entities) && struct_exists(_entities, "query_rect"))
    {
        _nearby = _entities.query_rect(_x1, _y1, _x2, _y2, _body);
    }
    else if (is_array(_entities))
    {
        _nearby = _entities;
    }
    else
    {
        return;
    }
    
    var _count = array_length(_nearby);
    
    for (var i = 0; i < _count; ++i)
    {
        var _other = _nearby[i];
        
        if (_other == _body) continue;
        if (_other[$ "static"] == true) continue;  // Skip static bodies
        
        var _other_half_w = (_other[$ "width"] ?? 8) / 2;
        var _other_half_h = (_other[$ "height"] ?? 8) / 2;
        
        var _ox1 = _other.pos_x - _other_half_w;
        var _oy1 = _other.pos_y - _other_half_h;
        var _ox2 = _other.pos_x + _other_half_w;
        var _oy2 = _other.pos_y + _other_half_h;
        
        // AABB overlap check
        if (_x1 >= _ox2 || _x2 <= _ox1 || _y1 >= _oy2 || _y2 <= _oy1)
        {
            continue;  // No collision
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
        
        // Push apart along minimum overlap axis (MTV - Minimum Translation Vector)
        // Push apart along minimum overlap axis (MTV - Minimum Translation Vector)
        if (_overlap_x < _overlap_y)
        {
            var _push = _overlap_x * _push_strength;
            
            // Backup velocities
            var _vx_body = _body.vel_x;
            var _vx_other = _other.vel_x;
            
            if (_body.pos_x < _other.pos_x)
            {
                // Push body Left
                with (_body.id)
                {
                    physics_body.vel_x = -_push;
                    physics_move_contact_x(physics_body);
                }
                
                // Push other Right
                with (_other.id)
                {
                    physics_body.vel_x = _push * (1 - _push_strength);
                    physics_move_contact_x(physics_body);
                }
            }
            else
            {
                // Push body Right
                with (_body.id)
                {
                    physics_body.vel_x = _push;
                    physics_move_contact_x(physics_body);
                }
                
                // Push other Left
                with (_other.id)
                {
                    physics_body.vel_x = -_push * (1 - _push_strength);
                    physics_move_contact_x(physics_body);
                }
            }
            
            // Restore velocities (and sync back position from physics body to be safe, though move_contact updates body.pos)
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
                with (_body.id)
                {
                    physics_body.vel_y = -_push;
                    physics_move_contact_y(physics_body);
                }
                
                // Push other Down
                with (_other.id)
                {
                    physics_body.vel_y = _push * (1 - _push_strength);
                    physics_move_contact_y(physics_body);
                }
            }
            else
            {
                // Push body Down
                with (_body.id)
                {
                    physics_body.vel_y = _push;
                    physics_move_contact_y(physics_body);
                }
                
                // Push other Up
                with (_other.id)
                {
                    physics_body.vel_y = -_push * (1 - _push_strength);
                    physics_move_contact_y(physics_body);
                }
            }
            
            // Restore velocities
            _body.vel_y = _vy_body;
            _other.vel_y = _vy_other;
        }
    }
}

/// @desc Check if two bodies are colliding (no resolution, just detection)
/// @param {Struct.PhysicsBody} _body_a
/// @param {Struct.PhysicsBody} _body_b
/// @returns {bool}
function physics_bodies_overlap(_body_a, _body_b)
{
    var _half_wa = (_body_a[$ "width"] ?? 8) / 2;
    var _half_ha = (_body_a[$ "height"] ?? 8) / 2;
    var _half_wb = (_body_b[$ "width"] ?? 8) / 2;
    var _half_hb = (_body_b[$ "height"] ?? 8) / 2;
    
    var _ax1 = _body_a.pos_x - _half_wa;
    var _ay1 = _body_a.pos_y - _half_ha;
    var _ax2 = _body_a.pos_x + _half_wa;
    var _ay2 = _body_a.pos_y + _half_ha;
    
    var _bx1 = _body_b.pos_x - _half_wb;
    var _by1 = _body_b.pos_y - _half_hb;
    var _bx2 = _body_b.pos_x + _half_wb;
    var _by2 = _body_b.pos_y + _half_hb;
    
    return (_ax1 < _bx2 && _ax2 > _bx1 && _ay1 < _by2 && _ay2 > _by1);
}
