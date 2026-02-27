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
        
        if (_c == undefined) || !(_c.boolean & CHUNK_BOOLEAN.GENERATED) continue;
        
        var _containers = _c.chunk_containers;
        var _container_count = array_length(_containers);
        
        for (var j = 0; j < _container_count; ++j)
        {
            var _coords = _containers[j];
            var _cx = (_coords & CHUNK_SIZE_MASK) * TILE_SIZE + _c.x;
            var _cy = ((_coords >> CHUNK_SIZE_BIT) & CHUNK_SIZE_MASK) * TILE_SIZE + _c.y;
            
            var _dist_sq = point_distance_sq(_x, _y, _cx, _cy);
            
            if (_dist_sq <= _range_sq)
            {
                var _cz = (_coords >> (CHUNK_SIZE_BIT * 2));
                var _tile = tile_get(_x_to_tile(_cx), _y_to_tile(_cy), _cz);
                
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
