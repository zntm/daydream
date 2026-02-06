/// @desc Cast a ray against the tile world and return precise hit information
/// @param {real} _x1 Starting X position (world coordinates)
/// @param {real} _y1 Starting Y position (world coordinates)
/// @param {real} _x2 Ending X position (world coordinates)
/// @param {real} _y2 Ending Y position (world coordinates)
/// @param {real} [_z=CHUNK_DEPTH_DEFAULT] Depth layer to check
/// @param {real} [_type=ITEM_TYPE_BIT.SOLID] Tile type bitmask to collide with
/// @returns {Struct} RayHit struct: { hit, x, y, normal_x, normal_y, distance, tile }
function tile_raycast(_x1, _y1, _x2, _y2, _z = CHUNK_DEPTH_DEFAULT, _type = ITEM_TYPE_BIT.SOLID)
{
    var _result = {
        hit: false,
        x: _x2,
        y: _y2,
        normal_x: 0,
        normal_y: 0,
        distance: point_distance(_x1, _y1, _x2, _y2),
        tile: undefined
    };
    
    var _dx = _x2 - _x1;
    var _dy = _y2 - _y1;
    var _len = sqrt(_dx * _dx + _dy * _dy);
    
    if (_len == 0) return _result;
    
    // Normalize direction
    var _dir_x = _dx / _len;
    var _dir_y = _dy / _len;
    
    var _item_data = global.item_data;
    
    // DDA setup (Digital Differential Analyzer)
    var _tile_x = floor(_x1 / TILE_SIZE);
    var _tile_y = floor(_y1 / TILE_SIZE);
    
    var _end_tile_x = floor(_x2 / TILE_SIZE);
    var _end_tile_y = floor(_y2 / TILE_SIZE);
    
    var _step_x = (_dir_x >= 0) ? 1 : -1;
    var _step_y = (_dir_y >= 0) ? 1 : -1;
    
    // Distance to next tile boundary
    var _t_max_x, _t_max_y;
    var _t_delta_x, _t_delta_y;
    
    if (_dir_x == 0)
    {
        _t_max_x = infinity;
        _t_delta_x = infinity;
    }
    else
    {
        var _next_x = (_step_x > 0) ? ((_tile_x + 1) * TILE_SIZE) : (_tile_x * TILE_SIZE);
        _t_max_x = (_next_x - _x1) / _dir_x;
        _t_delta_x = abs(TILE_SIZE / _dir_x);
    }
    
    if (_dir_y == 0)
    {
        _t_max_y = infinity;
        _t_delta_y = infinity;
    }
    else
    {
        var _next_y = (_step_y > 0) ? ((_tile_y + 1) * TILE_SIZE) : (_tile_y * TILE_SIZE);
        _t_max_y = (_next_y - _y1) / _dir_y;
        _t_delta_y = abs(TILE_SIZE / _dir_y);
    }
    
    // Maximum tiles to traverse
    var _max_tiles = abs(_end_tile_x - _tile_x) + abs(_end_tile_y - _tile_y) + 2;
    var _iterations = 0;
    
    while (_iterations < _max_tiles)
    {
        _iterations++;
        
        // Check current tile
        var _tile = tile_get(_tile_x, _tile_y, _z);
        
        if (_tile != TILE_EMPTY)
        {
            var _data = _item_data[$ _tile.get_id()];
            
            if (_data.has_type(_type))
            {
                // Compute exact intersection with tile's collision box
                var _tile_world_x = _tile_x * TILE_SIZE;
                var _tile_world_y = _tile_y * TILE_SIZE;
                
                var _tile_xoffset = _tile.get_xoffset();
                var _tile_yoffset = _tile.get_yoffset();
                var _tile_xscale = _tile.get_xscale();
                var _tile_yscale = _tile.get_yscale();
                
                var _box_x1 = _tile_world_x + ((_tile_xoffset + _data.get_collision_box_left()) * _tile_xscale);
                var _box_y1 = _tile_world_y + ((_tile_yoffset + _data.get_collision_box_top()) * _tile_yscale);
                var _box_x2 = _box_x1 + (_data.get_collision_box_right() * _tile_xscale);
                var _box_y2 = _box_y1 + (_data.get_collision_box_bottom() * _tile_yscale);
                
                // Normalize box bounds
                var _bx1 = min(_box_x1, _box_x2);
                var _by1 = min(_box_y1, _box_y2);
                var _bx2 = max(_box_x1, _box_x2);
                var _by2 = max(_box_y1, _box_y2);
                
                var _collision_type = _data.get_collision_box_type();
                
                if (_collision_type == TILE_COLLISION_BOX_TYPE.RECTANGLE)
                {
                    var _hit_info = __raycast_aabb(_x1, _y1, _dir_x, _dir_y, _len, _bx1, _by1, _bx2, _by2);
                    
                    if (_hit_info.hit)
                    {
                        _result.hit = true;
                        _result.x = _hit_info.x;
                        _result.y = _hit_info.y;
                        _result.normal_x = _hit_info.nx;
                        _result.normal_y = _hit_info.ny;
                        _result.distance = _hit_info.t;
                        _result.tile = _tile;
                        return _result;
                    }
                }
                else if (_collision_type == TILE_COLLISION_BOX_TYPE.TRIANGLE)
                {
                    // Triangle: bottom-left, bottom-right, top-right (slope)
                    var _hit_info = __raycast_triangle(_x1, _y1, _dir_x, _dir_y, _len, _bx1, _by2, _bx2, _by2, _bx2, _by1);
                    
                    if (_hit_info.hit)
                    {
                        _result.hit = true;
                        _result.x = _hit_info.x;
                        _result.y = _hit_info.y;
                        _result.normal_x = _hit_info.nx;
                        _result.normal_y = _hit_info.ny;
                        _result.distance = _hit_info.t;
                        _result.tile = _tile;
                        return _result;
                    }
                }
            }
        }
        
        // Have we passed the end?
        if (_tile_x == _end_tile_x && _tile_y == _end_tile_y)
        {
            break;
        }
        
        // Step to next tile (DDA)
        if (_t_max_x < _t_max_y)
        {
            if (_t_max_x > _len) break;
            _tile_x += _step_x;
            _t_max_x += _t_delta_x;
        }
        else
        {
            if (_t_max_y > _len) break;
            _tile_y += _step_y;
            _t_max_y += _t_delta_y;
        }
    }
    
    return _result;
}

/// @desc Ray vs AABB intersection (internal helper)
/// @returns {Struct} { hit, t, x, y, nx, ny }
function __raycast_aabb(_ox, _oy, _dx, _dy, _max_t, _x1, _y1, _x2, _y2)
{
    var _result = { hit: false, t: _max_t, x: 0, y: 0, nx: 0, ny: 0 };
    
    var _t_min = 0;
    var _t_max = _max_t;
    var _nx = 0, _ny = 0;
    
    // X slab
    if (_dx != 0)
    {
        var _inv_dx = 1 / _dx;
        var _t1 = (_x1 - _ox) * _inv_dx;
        var _t2 = (_x2 - _ox) * _inv_dx;
        
        if (_t1 > _t2) { var _tmp = _t1; _t1 = _t2; _t2 = _tmp; }
        
        if (_t1 > _t_min) { _t_min = _t1; _nx = (_dx > 0) ? -1 : 1; _ny = 0; }
        if (_t2 < _t_max) _t_max = _t2;
        
        if (_t_min > _t_max) return _result;
    }
    else
    {
        if (_ox < _x1 || _ox > _x2) return _result;
    }
    
    // Y slab
    if (_dy != 0)
    {
        var _inv_dy = 1 / _dy;
        var _t1 = (_y1 - _oy) * _inv_dy;
        var _t2 = (_y2 - _oy) * _inv_dy;
        
        if (_t1 > _t2) { var _tmp = _t1; _t1 = _t2; _t2 = _tmp; }
        
        if (_t1 > _t_min) { _t_min = _t1; _nx = 0; _ny = (_dy > 0) ? -1 : 1; }
        if (_t2 < _t_max) _t_max = _t2;
        
        if (_t_min > _t_max) return _result;
    }
    else
    {
        if (_oy < _y1 || _oy > _y2) return _result;
    }
    
    if (_t_min >= 0 && _t_min <= _max_t)
    {
        _result.hit = true;
        _result.t = _t_min;
        _result.x = _ox + _dx * _t_min;
        _result.y = _oy + _dy * _t_min;
        _result.nx = _nx;
        _result.ny = _ny;
    }
    
    return _result;
}

/// @desc Ray vs Triangle intersection (internal helper)
/// @returns {Struct} { hit, t, x, y, nx, ny }
function __raycast_triangle(_ox, _oy, _dx, _dy, _max_t, _ax, _ay, _bx, _by, _cx, _cy)
{
    var _result = { hit: false, t: _max_t, x: 0, y: 0, nx: 0, ny: 0 };
    
    // Edge vectors
    var _edges = [
        { x1: _ax, y1: _ay, x2: _bx, y2: _by },
        { x1: _bx, y1: _by, x2: _cx, y2: _cy },
        { x1: _cx, y1: _cy, x2: _ax, y2: _ay }
    ];
    
    var _best_t = _max_t;
    var _hit_found = false;
    var _best_nx = 0, _best_ny = 0;
    
    for (var i = 0; i < 3; ++i)
    {
        var _edge = _edges[i];
        var _ex = _edge.x2 - _edge.x1;
        var _ey = _edge.y2 - _edge.y1;
        
        // 2D cross product for parallel check
        var _denom = _dx * _ey - _dy * _ex;
        
        if (abs(_denom) < 0.0001) continue;
        
        var _t = ((_edge.x1 - _ox) * _ey - (_edge.y1 - _oy) * _ex) / _denom;
        var _u = ((_edge.x1 - _ox) * _dy - (_edge.y1 - _oy) * _dx) / _denom;
        
        if (_t >= 0 && _t < _best_t && _u >= 0 && _u <= 1)
        {
            // Verify point is inside triangle (or on the correct side)
            var _hit_x = _ox + _dx * _t;
            var _hit_y = _oy + _dy * _t;
            
            if (__point_in_triangle(_hit_x, _hit_y, _ax, _ay, _bx, _by, _cx, _cy))
            {
                _best_t = _t;
                _hit_found = true;
                
                // Edge normal (perpendicular, pointing outward)
                var _len = sqrt(_ex * _ex + _ey * _ey);
                _best_nx = _ey / _len;
                _best_ny = -_ex / _len;
                
                // Ensure normal points against ray direction
                if (_best_nx * _dx + _best_ny * _dy > 0)
                {
                    _best_nx = -_best_nx;
                    _best_ny = -_best_ny;
                }
            }
        }
    }
    
    if (_hit_found)
    {
        _result.hit = true;
        _result.t = _best_t;
        _result.x = _ox + _dx * _best_t;
        _result.y = _oy + _dy * _best_t;
        _result.nx = _best_nx;
        _result.ny = _best_ny;
    }
    
    return _result;
}

/// @desc Check if point is inside triangle (helper)
function __point_in_triangle(_px, _py, _ax, _ay, _bx, _by, _cx, _cy)
{
    var _v0x = _cx - _ax, _v0y = _cy - _ay;
    var _v1x = _bx - _ax, _v1y = _by - _ay;
    var _v2x = _px - _ax, _v2y = _py - _ay;
    
    var _dot00 = _v0x * _v0x + _v0y * _v0y;
    var _dot01 = _v0x * _v1x + _v0y * _v1y;
    var _dot02 = _v0x * _v2x + _v0y * _v2y;
    var _dot11 = _v1x * _v1x + _v1y * _v1y;
    var _dot12 = _v1x * _v2x + _v1y * _v2y;
    
    var _inv_denom = 1 / (_dot00 * _dot11 - _dot01 * _dot01);
    var _u = (_dot11 * _dot02 - _dot01 * _dot12) * _inv_denom;
    var _v = (_dot00 * _dot12 - _dot01 * _dot02) * _inv_denom;
    
    return (_u >= 0) && (_v >= 0) && (_u + _v <= 1);
}
