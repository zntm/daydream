function tile_update_liquid(_x, _y, _z)
{
    var _inst = chunk_map_get_by_tile(_x, _y);
    
    if (!instance_exists(_inst)) exit;
    
    // Check if we have liquid at this position
    var _index = tile_index_xyz(_x, _y, _z);
    var _tile = _inst.chunk[_index];
    
    // If empty or not liquid, check surroundings to see if liquid should flow INTO this tile
    if (_tile == TILE_EMPTY)
    {
        // Check ABOVE
        var _inst_above = chunk_map_get_by_tile(_x, _y - 1);
        if (instance_exists(_inst_above))
        {
            var _index_above = tile_index_xyz(_x, _y - 1, _z);
            var _tile_above = _inst_above.chunk[_index_above];
            
            if (_tile_above != TILE_EMPTY)
            {
                var _data_above = global.item_data[$ _tile_above.get_id()];
                if (_data_above.is_liquid())
                {
                    // Liquid falls down - new tile with max level
                    tile_place(_x, _y, _z, new Tile(_tile_above.get_id()).set_component("level", 8));
                    tile_update(_x, _y, _z);
                    return;
                }
            }
        }
        
        // Check SIDES (slow spread)
        var _spread = false;
        var _liquid_id = undefined;
        var _max_level = 0;
        
        var _check_side = function(_xs, _ys, _zs)
        {
            var _is = chunk_map_get_by_tile(_xs, _ys);
            if (!instance_exists(_is)) return undefined;
            
            var _idx = tile_index_xyz(_xs, _ys, _zs);
            var _t = _is.chunk[_idx];
            
            if (_t == TILE_EMPTY) return undefined;
             
            var _d = global.item_data[$ _t.get_id()];
            if (!_d.is_liquid()) return undefined;
            
            return {
                id: _t.get_id(),
                level: _t.get_component("level") ?? 8
            };
        }
        
        // Left
        var _l = _check_side(_x - 1, _y, _z);
        if (_l != undefined && _l.level > 1) { _spread = true; _liquid_id = _l.id; _max_level = max(_max_level, _l.level); }
        
        // Right
        var _r = _check_side(_x + 1, _y, _z);
        if (_r != undefined && _r.level > 1) { _spread = true; _liquid_id = _r.id; _max_level = max(_max_level, _r.level); }
        
        if (_spread)
        {
            // Place liquid with decremented level
            tile_place(_x, _y, _z, new Tile(_liquid_id).set_component("level", _max_level - 1));
            
            tile_update(_x, _y, _z);
        }
        
        return;
    }
    
    var _data = global.item_data[$ _tile.get_id()];
    
    if (_data == undefined) || (!_data.is_liquid()) return;
    
    // If IS liquid, try to flow DOWN or SIDES
    
    // Flow DOWN
    var _inst_below = chunk_map_get_by_tile(_x, _y + 1);
    if (instance_exists(_inst_below))
    {
        var _index_below = tile_index_xyz(_x, _y + 1, _z);
        var _tile_below = _inst_below.chunk[_index_below];
        
        if (_tile_below == TILE_EMPTY)
        {
            // Flow down creates full source block (or inherits? standard MC is full source)
            // Let's stick to full source for falling water for now, or match parent? 
            // Standard is falling water is a "falling" block, but here we just place liquid.
            // Let's reset level to 8 for falling water to ensure it goes all the way down.
            tile_place(_x, _y + 1, _z, new Tile(_tile.get_id()).set_component("level", 8));
            
            tile_update(_x, _y + 1, _z);
        }
    }
    
    // Flow SIDES if supported below
    // (Simple logic: if grounded, spread)
    var _grounded = false;
    if (instance_exists(_inst_below))
    {
        var _index_below = tile_index_xyz(_x, _y + 1, _z);
        var _tile_below = _inst_below.chunk[_index_below];
        if (_tile_below != TILE_EMPTY)
        {
            var _data_below = global.item_data[$ _tile_below.get_id()];
            if (_data_below.has_type(ITEM_TYPE_BIT.SOLID))
            {
                _grounded = true;
            }
            else if (_data_below.is_liquid())
            {
                // If liquid below is full, we are "grounded" on it? No.
                // If liquid below is not full, it should be executing its own flow.
            }
        }
    }
    
    if (_grounded)
    {
        var _level = _tile.get_component("level") ?? 8;
        
        if (_level > 1)
        {
            // Try Left
            var _inst_left = chunk_map_get_by_tile(_x - 1, _y);
            if (instance_exists(_inst_left))
            {
                var _index_left = tile_index_xyz(_x - 1, _y, _z);
                if (_inst_left.chunk[_index_left] == TILE_EMPTY)
                {
                    tile_update_liquid(_x - 1, _y, _z); // Trigger check on empty neighbor
                }
            }
            
            // Try Right
            var _inst_right = chunk_map_get_by_tile(_x + 1, _y);
            if (instance_exists(_inst_right))
            {
                var _index_right = tile_index_xyz(_x + 1, _y, _z);
                if (_inst_right.chunk[_index_right] == TILE_EMPTY)
                {
                    tile_update_liquid(_x + 1, _y, _z); // Trigger check on empty neighbor
                }
            }
        }
    }
}
