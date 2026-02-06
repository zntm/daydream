/// @desc Spatial Grid for efficient entity queries using spatial hashing
/// @param {real} _cell_size Size of each grid cell (typically TILE_SIZE or 2*TILE_SIZE)
function SpatialGrid(_cell_size = TILE_SIZE * 2) constructor
{
    cell_size = _cell_size;
    inv_cell_size = 1 / _cell_size;
    cells = {}  // Map of "x,y" -> array of bodies
    body_cells = {}  // Map of body id -> array of cell keys (for fast removal)
    
    /// @desc Get the cell key for a world position
    /// @param {real} _x World X
    /// @param {real} _y World Y
    /// @returns {string} Cell key
    static get_cell_key = function(_x, _y)
    {
        var _cx = floor(_x * inv_cell_size);
        var _cy = floor(_y * inv_cell_size);
        return string(_cx) + "," + string(_cy);
    }
    
    /// @desc Get all cell keys that an AABB overlaps
    /// @param {real} _x1 Left
    /// @param {real} _y1 Top
    /// @param {real} _x2 Right
    /// @param {real} _y2 Bottom
    /// @returns {array} Array of cell keys
    static get_cells_for_aabb = function(_x1, _y1, _x2, _y2)
    {
        var _cx1 = floor(_x1 * inv_cell_size);
        var _cy1 = floor(_y1 * inv_cell_size);
        var _cx2 = floor(_x2 * inv_cell_size);
        var _cy2 = floor(_y2 * inv_cell_size);
        
        var _keys = [];
        for (var _cx = _cx1; _cx <= _cx2; ++_cx)
        {
            for (var _cy = _cy1; _cy <= _cy2; ++_cy)
            {
                array_push(_keys, string(_cx) + "," + string(_cy));
            }
        }
        return _keys;
    }
    
    /// @desc Add a body to the grid
    /// @param {Struct} _body Must have: id, pos_x, pos_y, width, height (or use PhysicsBody)
    static add = function(_body)
    {
        var _id = _body.id;
        var _half_w = (_body[$ "width"] ?? 8) / 2;
        var _half_h = (_body[$ "height"] ?? 8) / 2;
        
        var _x1 = _body.pos_x - _half_w;
        var _y1 = _body.pos_y - _half_h;
        var _x2 = _body.pos_x + _half_w;
        var _y2 = _body.pos_y + _half_h;
        
        var _keys = get_cells_for_aabb(_x1, _y1, _x2, _y2);
        body_cells[$ _id] = _keys;
        
        for (var i = 0; i < array_length(_keys); ++i)
        {
            var _key = _keys[i];
            if (!struct_exists(cells, _key))
            {
                cells[$ _key] = [];
            }
            array_push(cells[$ _key], _body);
        }
    }
    
    /// @desc Remove a body from the grid
    /// @param {Struct} _body
    static remove = function(_body)
    {
        var _id = _body.id;
        var _keys = body_cells[$ _id];
        
        if (_keys == undefined) return;
        
        for (var i = 0; i < array_length(_keys); ++i)
        {
            var _key = _keys[i];
            var _cell = cells[$ _key];
            
            if (_cell != undefined)
            {
                var _index = array_get_index(_cell, _body);
                if (_index >= 0)
                {
                    array_delete(_cell, _index, 1);
                }
            }
        }
        
        struct_remove(body_cells, _id);
    }
    
    /// @desc Update a body's position in the grid (call after moving)
    /// @param {Struct} _body
    static update = function(_body)
    {
        remove(_body);
        add(_body);
    }
    
    /// @desc Query all bodies overlapping a rectangle
    /// @param {real} _x1 Left
    /// @param {real} _y1 Top
    /// @param {real} _x2 Right
    /// @param {real} _y2 Bottom
    /// @param {Struct} [_exclude] Optional body to exclude from results
    /// @returns {array} Array of bodies (may contain duplicates - use ds_map or set if needed)
    static query_rect = function(_x1, _y1, _x2, _y2, _exclude = undefined)
    {
        var _keys = get_cells_for_aabb(_x1, _y1, _x2, _y2);
        var _found = [];
        var _seen = {}  // Deduplication
        
        for (var i = 0; i < array_length(_keys); ++i)
        {
            var _key = _keys[i];
            var _cell = cells[$ _key];
            
            if (_cell != undefined)
            {
                for (var j = 0; j < array_length(_cell); ++j)
                {
                    var _body = _cell[j];
                    var _id = _body.id;
                    
                    if (_body == _exclude) continue;
                    if (struct_exists(_seen, _id)) continue;
                    
                    // AABB overlap check
                    var _half_w = (_body[$ "width"] ?? 8) / 2;
                    var _half_h = (_body[$ "height"] ?? 8) / 2;
                    var _bx1 = _body.pos_x - _half_w;
                    var _by1 = _body.pos_y - _half_h;
                    var _bx2 = _body.pos_x + _half_w;
                    var _by2 = _body.pos_y + _half_h;
                    
                    if (_bx1 < _x2 && _bx2 > _x1 && _by1 < _y2 && _by2 > _y1)
                    {
                        _seen[$ _id] = true;
                        array_push(_found, _body);
                    }
                }
            }
        }
        
        return _found;
    }
    
    /// @desc Query all bodies at a point
    /// @param {real} _x
    /// @param {real} _y
    /// @param {Struct} [_exclude]
    /// @returns {array}
    static query_point = function(_x, _y, _exclude = undefined)
    {
        return query_rect(_x - 1, _y - 1, _x + 1, _y + 1, _exclude);
    }
    
    /// @desc Clear all bodies from the grid
    static clear = function()
    {
        cells = {}
        body_cells = {}
    }
}
