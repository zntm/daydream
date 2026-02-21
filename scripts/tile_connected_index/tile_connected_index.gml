function tile_connected_index(_bitmask)
{
    var _res = 0;
    
    // Flip X (Horizontal symmetry check)
    // Neighbors Map (from global.tile_neighbor_offsets):
    // 0: (1, 1) BR, 1: (0, 1) B, 2: (-1, 1) BL
    // 3: (1, 0) R,               4: (-1, 0) L
    // 5: (1, -1) TR, 6: (0, -1) T, 7: (-1, -1) TL
    
    // Symmetry across X-axis (Left <-> Right)
    // Left (4) <-> Right (3)
    // Top Left (7) <-> Top Right (5)
    // Bottom Left (2) <-> Bottom Right (0)
    var _left   = (_bitmask >> 4) & 1;
    var _right  = (_bitmask >> 3) & 1;
    var _tl     = (_bitmask >> 7) & 1;
    var _tr     = (_bitmask >> 5) & 1;
    var _bl     = (_bitmask >> 2) & 1;
    var _br     = (_bitmask >> 0) & 1;
    
    if (_left == _right && _tl == _tr && _bl == _br)
    {
        _res |= 1; // Can flip on X
    }
    
    // Flip Y (Vertical symmetry check)
    // Symmetry across Y-axis (Top <-> Bottom)
    // Top (6) <-> Bottom (1)
    // Top Left (7) <-> Bottom Left (2)
    // Top Right (5) <-> Bottom Right (0)
    var _top    = (_bitmask >> 6) & 1;
    var _bottom = (_bitmask >> 1) & 1;
    
    // Using already extracted _tl, _bl, _tr, _br
    if (_top == _bottom && _tl == _bl && _tr == _br)
    {
        _res |= 2; // Can flip on Y
    }
    
    return _res;
}
