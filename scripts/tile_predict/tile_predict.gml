function tile_predict(_x, _y, _z)
{
    var _current_world = global.current_world;
    var _world_seed = _current_world.seed;
    var _world_data = global.world_data[$ _current_world.dimension];
    var _item_data = global.item_data;
    var _global_biome_data = global.biome_data;
    
    // PASS 1: Structures (Highest Priority)
    var _inst = global.structure_pool.query_position(_x, _y);
    
    if (_inst != noone)
    {
        // Ensure structure data is generated
        if (_inst.data == undefined)
        {
            structure_generate(_inst, _world_seed, _item_data, global.structure_data, global.natural_structure_data);
        }
        
        var _width  = _inst.width;
        var _height = _inst.height;
        var _rectangle = _width * _height;
        
        var _sx = _x - _inst.x;
        var _sy = _y - _inst.y;
        
        if (_sx >= 0 && _sx < _width && _sy >= 0 && _sy < _height)
        {
            var _tile = _inst.data[_sx + (_sy * _width) + (_z * _rectangle)];
            if (_tile != TILE_STRUCTURE_VOID) return _tile;
        }
    }
    
    // Shared generation parameters
    var _surface_height = worldgen_get_surface_height(_x, _world_seed, _world_data);
    var _sky_threshold = _world_data.get_sky_biome_threshold();
    var _sky_enabled = _world_data.is_sky_biome_enabled();
    
    // --- SKY BIOME ---
    if (_y <= _sky_threshold && _sky_enabled)
    {
        if (worldgen_get_sky_island(_x, _y, _world_seed, _world_data))
        {
            var _sky_biome_id = _world_data.get_sky_biome_id();
            var _sky_biome_data = _global_biome_data[$ _sky_biome_id];
            
            if (_sky_biome_data != undefined)
            {
                if (_z == CHUNK_DEPTH_DEFAULT)
                {
                    var _is_above = worldgen_get_sky_island(_x, _y - 1, _world_seed, _world_data);
                    var _is_below = worldgen_get_sky_island(_x, _y + 1, _world_seed, _world_data);
                    
                    var _tile_seed = abs(_x * 73856093) ^ abs(_y * 19349663) ^ _world_seed;
                    var _tile_id = (!_is_above ? _sky_biome_data.get_tile_top_layer_base(_tile_seed) : 
                                   (!_is_below ? _sky_biome_data.get_tile_bottom_layer_base(_tile_seed) : 
                                   _sky_biome_data.get_tile_middle_layer_base(_tile_seed)));
                    
                    if (_tile_id != TILE_EMPTY)
                    {
                        var _d = _item_data[$ _tile_id];
                        if (_d != undefined) return new Tile(_tile_id)
                            .set_index(smart_value(_d.get_placement_index()))
                            .set_index_offset(smart_value(_d.get_placement_index_offset()));
                    }
                }
                
                if (_z == CHUNK_DEPTH_WALL)
                {
                    var _tile_seed = abs(_x * 73856093) ^ abs(_y * 19349663) ^ _world_seed;
                    var _tile_wall = _sky_biome_data.get_tile_middle_layer_wall(_tile_seed);
                    if (_tile_wall != TILE_EMPTY) return new Tile(_tile_wall);
                }
                
                return TILE_EMPTY;
            }
        }
    }
    
    // HOIST: Biome Parameters
    // Calculate Slope for Biome Selection (0 = flat, 1 = steep)
    var _h_left = worldgen_get_surface_height(_x - 1, _world_seed, _world_data);
    var _h_right = worldgen_get_surface_height(_x + 1, _world_seed, _world_data);
    var _slope = max(abs(_surface_height - _h_left), abs(_h_right - _surface_height));
    
    var _surface_biome = worldgen_get_biome_surface(_x, _surface_height, _surface_height, _world_seed, _world_data, _slope);
    var _surface_biome_data = _global_biome_data[$ worldgen_resolve_id(_surface_biome)];
    
    // --- OCEAN WATER ---
    if (_z == CHUNK_DEPTH_LIQUID)
    {
        if (_y < _surface_height) && (_y >= _world_data.get_surface_start()) && (_surface_biome_data != undefined) && (_surface_biome_data.is_ocean())
        {
            return new Tile("phantasia:water").set_component("level", 8);
        }
    }
    
    // --- CAVES AND SOLID TERRAIN ---
    if (_y >= _surface_height - 1)
    {
        var _cave_biome = worldgen_get_biome_cave(_x, _y, _surface_height, _world_seed, _world_data);
        var _cave_start = worldgen_get_cave_start(_x, _world_seed, _world_data);
        var _is_cave = worldgen_get_cave(_x, _y, _surface_height, _cave_start, _world_seed, _world_data);
        
        if (_z == CHUNK_DEPTH_DEFAULT && !_is_cave && _y >= _surface_height)
        {
            var _cave_above = worldgen_get_cave(_x, _y - 1, _surface_height, _cave_start, _world_seed, _world_data);
            var _tile_base = worldgen_get_tile_base(_x, _y, _surface_biome, _cave_biome, _surface_height, _cave_above, _world_seed, _world_data, _global_biome_data);
            if (_tile_base != TILE_EMPTY)
            {
                var _d = _item_data[$ _tile_base];
                if (_d != undefined) return new Tile(_tile_base)
                    .set_index(smart_value(_d.get_placement_index()))
                    .set_index_offset(smart_value(_d.get_placement_index_offset()));
            }
        }
        
        if (_z == CHUNK_DEPTH_WALL && _y >= _surface_height)
        {
            var _tile_wall = worldgen_get_tile_wall(_x, _y, _surface_biome, _cave_biome, _surface_height, _world_seed, _world_data, _global_biome_data);
            if (_tile_wall != TILE_EMPTY)
            {
                var _d = _item_data[$ _tile_wall];
                if (_d != undefined) return new Tile(_tile_wall)
                    .set_index(smart_value(_d.get_placement_index()))
                    .set_index_offset(smart_value(_d.get_placement_index_offset()));
            }
        }
        
        // --- AQUIFERS ---
        if (_z == CHUNK_DEPTH_LIQUID && _is_cave)
        {
            var _aquifer = worldgen_get_aquifer(_x, _y, _surface_height, _world_seed, _world_data);
            if (_aquifer != undefined)
            {
                return new Tile(_aquifer.type).set_component("level", _aquifer.fill_level);
            }
            else if (_world_data.get_world_height() - _y <= 32 && _world_data.get_world_height() - _y > 3)
            {
                return new Tile("phantasia:lava").set_component("level", 8);
            }
        }
    }
    
    // --- FOLIAGE ---
    var _xorshift_val = xorshift(_world_seed ^ (_x * (_y + _surface_height)));
    var _foliage_layer = ((_xorshift_val & 1) ? CHUNK_DEPTH_FOLIAGE_FRONT : CHUNK_DEPTH_FOLIAGE_BACK);
    
    if (_z == _foliage_layer && _y >= _surface_height - 1)
    {
        var _cave_start = worldgen_get_cave_start(_x, _world_seed, _world_data);
        var _is_cave = worldgen_get_cave(_x, _y, _surface_height, _cave_start, _world_seed, _world_data);
        var _is_cave_below = worldgen_get_cave(_x, _y + 1, _surface_height, _cave_start, _world_seed, _world_data);
        
        var _is_floor = _is_cave && !_is_cave_below;
        if (_is_floor)
        {
            var _cave_biome_foliage = worldgen_get_biome_cave(_x, _y, _surface_height, _world_seed, _world_data);
            var _tile_next = worldgen_get_tile_base(_x, _y + 1, _surface_biome, _cave_biome_foliage, _surface_height, true, _world_seed, _world_data, _global_biome_data);
            var _foliage_id = worldgen_get_tile_foliage(_x, _y, _surface_biome, _cave_biome_foliage, _tile_next, _surface_height, _world_seed, _global_biome_data);
            
            if (_foliage_id != TILE_EMPTY)
            {
                var _d = _item_data[$ _foliage_id];
                if (_d != undefined)
                {
                    var _flip = ((_d.can_flip_on_x()) && (xorshift(_world_seed + _x - _y) & 1)) ? -1 : 1;
                    return new Tile(_foliage_id)
                        .set_xscale(_flip)
                        .set_index(smart_value(_d.get_placement_index()))
                        .set_index_offset(smart_value(_d.get_placement_index_offset()));
                }
            }
        }
    }
    
    return TILE_EMPTY;
}
