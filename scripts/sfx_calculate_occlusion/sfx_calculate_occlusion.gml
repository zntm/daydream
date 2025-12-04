/// @description Calculate sound occlusion between two points
/// @param {Real} _x1 Start x position (player)
/// @param {Real} _y1 Start y position (player)
/// @param {Real} _x2 End x position (sound source)
/// @param {Real} _y2 End y position (sound source)
/// @return {Real} Occlusion value (0.0 to 1.0)
function sfx_calculate_occlusion(_x1, _y1, _x2, _y2)
{
    var _tile_x1 = round(_x1 / TILE_SIZE);
    var _tile_y1 = round(_y1 / TILE_SIZE);
    var _tile_x2 = round(_x2 / TILE_SIZE);
    var _tile_y2 = round(_y2 / TILE_SIZE);
    
    var _distance = point_distance(_tile_x1, _tile_y1, _tile_x2, _tile_y2);
    
    // If very close, no occlusion
    if (_distance < 2)
    {
        return 0;
    }
    
    // Cast ray from player to sound source
    var _dx = _tile_x2 - _tile_x1;
    var _dy = _tile_y2 - _tile_y1;
    
    var _steps = ceil(_distance);
    var _blocking_tiles = 0;
    
    var _item_data = global.item_data;
    
    // Check each step along the ray
    for (var i = 1; i < _steps; ++i)
    {
        var _t = i / _steps;
        
        var _check_x = round(_tile_x1 + (_dx * _t));
        var _check_y = round(_tile_y1 + (_dy * _t));
        
        var _tile = tile_get(_check_x, _check_y, CHUNK_DEPTH_DEFAULT);
        
        if (_tile != TILE_EMPTY)
        {
            var _data = _item_data[$ _tile.get_id()];
            
            // Only count solid, non-transparent tiles
            if (!_data.is_transparent())
            {
                _blocking_tiles++;
            }
        }
    }
    
    // Return occlusion value (0.0 to 1.0)
    // Each blocking tile adds 0.2 occlusion, capped at 1.0
    return min(1.0, _blocking_tiles * 0.2);
}
