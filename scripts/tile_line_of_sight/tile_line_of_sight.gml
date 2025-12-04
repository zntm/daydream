/// @desc Returns true if there is a clear line of sight between two points (no solid tiles blocking)
/// @param {real} _x1 Starting X position
/// @param {real} _y1 Starting Y position
/// @param {real} _x2 Ending X position
/// @param {real} _y2 Ending Y position
/// @returns {bool} True if line of sight is clear
function tile_line_of_sight(_x1, _y1, _x2, _y2)
{
    var _item_data = global.item_data;
    
    // Convert to tile coordinates
    var _tile_x1 = floor(_x1 / TILE_SIZE);
    var _tile_y1 = floor(_y1 / TILE_SIZE);
    var _tile_x2 = floor(_x2 / TILE_SIZE);
    var _tile_y2 = floor(_y2 / TILE_SIZE);
    
    // DDA (Digital Differential Analyzer) algorithm for line traversal
    var _dx = abs(_tile_x2 - _tile_x1);
    var _dy = abs(_tile_y2 - _tile_y1);
    
    var _sx = (_tile_x1 < _tile_x2) ? 1 : -1;
    var _sy = (_tile_y1 < _tile_y2) ? 1 : -1;
    
    var _err = _dx - _dy;
    
    var _current_x = _tile_x1;
    var _current_y = _tile_y1;
    
    // Maximum iterations to prevent infinite loops
    var _max_iterations = _dx + _dy + 2;
    var _iteration = 0;
    
    while (_iteration < _max_iterations)
    {
        _iteration++;
        
        // Skip checking the starting tile (where the creature is)
        if (_current_x != _tile_x1 || _current_y != _tile_y1)
        {
            // Check if this tile blocks line of sight
            var _tile = tile_get(_current_x, _current_y, CHUNK_DEPTH_DEFAULT);
            
            if (_tile != TILE_EMPTY)
            {
                var _data = _item_data[$ _tile.get_id()];
                
                // Solid tiles block line of sight
                if (_data.has_type(ITEM_TYPE_BIT.SOLID))
                {
                    return false;
                }
            }
            
            // Also check wall layer
            var _wall = tile_get(_current_x, _current_y, CHUNK_DEPTH_WALL);
            
            if (_wall != TILE_EMPTY)
            {
                var _wall_data = _item_data[$ _wall.get_id()];
                
                if (_wall_data.has_type(ITEM_TYPE_BIT.SOLID))
                {
                    return false;
                }
            }
        }
        
        // Check if we've reached the destination
        if (_current_x == _tile_x2 && _current_y == _tile_y2)
        {
            return true;
        }
        
        // Move to next tile
        var _e2 = _err * 2;
        
        if (_e2 > -_dy)
        {
            _err -= _dy;
            _current_x += _sx;
        }
        
        if (_e2 < _dx)
        {
            _err += _dx;
            _current_y += _sy;
        }
    }
    
    // Reached max iterations - assume blocked
    return false;
}
