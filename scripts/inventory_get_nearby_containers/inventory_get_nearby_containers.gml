/// @desc Gets all container inventories within a range of a position.
/// @param {real} _x World X position.
/// @param {real} _y World Y position.
/// @param {real} _range Range in pixels.
/// @return {array<array<Inventory>>} Array of inventory arrays.
function inventory_get_nearby_containers(_x, _y, _range)
{
    var _results = [];
    var _range_sq = _range * _range;
    
    for (var i = chunk_in_view_length - 1; i >= 0; --i)
    {
        var _c = chunk_in_view[i];
        
        if (_c == undefined) || !(_c.boolean & CHUNK_BOOL.GENERATED) continue;
        
        var _containers = _c.chunk_containers;
        
        for (var j = array_length(_containers) - 1; j >= 0; --j)
        {
            var _container = _containers[j];
            
            var _dist_sq = point_distance_sq(_x, _y, _container.x, _container.y);
            
            if (_dist_sq <= _range_sq)
            {
                var _tile = tile_get(_container.tile_x, _container.tile_y, _container.tile_z);
                
                if (_tile != undefined)
                {
                    var _inv = _tile.get_inventory();
                    
                    if (_inv != undefined)
                    {
                        array_push(_results, _inv);
                    }
                }
            }
        }
    }
    
    return _results;
}
