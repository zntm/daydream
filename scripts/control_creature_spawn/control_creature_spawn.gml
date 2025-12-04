// Constants for spawn system
#macro SPAWN_MIN_DISTANCE (TILE_SIZE * 3)      // Minimum distance between same-type creatures
#macro SPAWN_DENSITY_GRID_SIZE 16               // Grid cell size for density tracking (in tiles)
#macro SPAWN_MAX_PER_GRID 3                     // Maximum creatures per grid cell

function control_creature_spawn(_dt)
{
    // Initialize spawn density grid if not exists
    if (!variable_global_exists("spawn_density_grid"))
    {
        global.spawn_density_grid = {};
        global.spawn_last_cleanup_time = 0;
    }
    
    // Optimized spawn function with density checking
    static __spawn = function(_world_time, _tile_x, _tile_y, _biome_data, _creature_data)
    {
        var _x = (_tile_x * TILE_SIZE);
        var _y = (_tile_y * TILE_SIZE) - (TILE_SIZE / 2);
        
        // Check spawn density for this grid cell
        var _grid_x = floor(_tile_x / SPAWN_DENSITY_GRID_SIZE);
        var _grid_y = floor(_tile_y / SPAWN_DENSITY_GRID_SIZE);
        var _grid_key = $"{_grid_x}_{_grid_y}";
        
        var _cell_count = global.spawn_density_grid[$ _grid_key] ?? 0;
        
        if (_cell_count >= SPAWN_MAX_PER_GRID)
        {
            return false; // Too many creatures in this area
        }
        
        var _biome = _biome_data[$ bg_get_biome(_tile_x, _tile_y)];
        
        var _spawn = _biome.get_creature();
        var _spawn_length = _biome.get_creature_length();
        
        // Pre-filter valid spawn candidates
        var _valid_spawns = [];
        
        for (var i = 0; i < _spawn_length; ++i)
        {
            var _creature = _spawn[i];
            
            if (!chance(_creature.chance)) continue;
            
            var _time = _creature.time;
            
            if (_time != undefined) && ((_world_time < _time.min) || (_world_time >= _time.max)) continue;
            
            array_push(_valid_spawns, _creature);
        }
        
        var _valid_count = array_length(_valid_spawns);
        
        if (_valid_count == 0) return false;
        
        // Randomize spawn selection instead of sequential
        var _indices = [];
        for (var i = 0; i < _valid_count; ++i)
        {
            _indices[i] = i;
        }
        
        // Shuffle indices for random selection
        for (var i = _valid_count - 1; i > 0; --i)
        {
            var j = irandom(i);
            var _temp = _indices[i];
            _indices[i] = _indices[j];
            _indices[j] = _temp;
        }
        
        // Try each candidate in random order
        for (var idx = 0; idx < _valid_count; ++idx)
        {
            var _creature = _valid_spawns[_indices[idx]];
            var _id = _creature.id;
            var _attribute = _creature_data[$ _id].get_attribute();
            
            // Check spawn validity
            var _can_spawn = false;
            
            with (obj_Game_Control_Spawn_Check)
            {
                attribute = _attribute;
                
                image_xscale = _attribute.get_collision_box_width()  / 8;
                image_yscale = _attribute.get_collision_box_height() / 8;
                
                _can_spawn = !tile_meeting(_x, _y);
            }
            
            if (!_can_spawn) || (tile_get(_tile_x, _tile_y - 1, CHUNK_DEPTH_WALL) != TILE_EMPTY) continue;
            
            // Check tile requirements
            var _tile = _creature.tile;
            
            if (_tile != undefined)
            {
                var _tile2 = tile_get(_tile_x, _tile_y, CHUNK_DEPTH_DEFAULT);
                
                if (_tile2 == TILE_EMPTY) || (!array_contains(_tile, _tile2.get_id())) continue;
            }
            
            // Check for nearby creatures of same type (avoid spawning too close)
            var _too_close = false;
            
            with (obj_Creature)
            {
                if (_id == id._id && point_distance(x, y, _x, _y) < SPAWN_MIN_DISTANCE)
                {
                    _too_close = true;
                    break;
                }
            }
            
            if (_too_close) continue;
            
            // All checks passed - spawn the creature(s)
            var _variant = _creature.variant;
            
            repeat (smart_value(_creature.amount))
            {
                spawn_creature(_x, _y, _id, _variant);
            }
            
            // Update density grid
            global.spawn_density_grid[$ _grid_key] = _cell_count + 1;
            
            return true;
        }
        
        return false;
    }
    
    static __spawn_horizontal = function(_world_time, _tile_y, _tile_xstart, _tile_xend, _biome_data, _creature_data)
    {
        // Randomize X order for better distribution
        var _tiles = [];
        for (var _tile_x = _tile_xstart; _tile_x <= _tile_xend; ++_tile_x)
        {
            array_push(_tiles, _tile_x);
        }
        
        // Shuffle for random spawn positions
        var _count = array_length(_tiles);
        for (var i = _count - 1; i > 0; --i)
        {
            var j = irandom(i);
            var _temp = _tiles[i];
            _tiles[i] = _tiles[j];
            _tiles[j] = _temp;
        }
        
        // Try spawning at random positions
        for (var i = 0; i < _count; ++i)
        {
            if (control_creature_spawn.__spawn(_world_time, _tiles[i], _tile_y, _biome_data, _creature_data))
            {
                return true;
            }
        }
        
        return false;
    }
    
    static __spawn_vertical = function(_world_time, _tile_x, _tile_ystart, _tile_yend, _biome_data, _creature_data)
    {
        // Randomize Y order for better distribution
        var _tiles = [];
        for (var _tile_y = _tile_ystart; _tile_y <= _tile_yend; ++_tile_y)
        {
            array_push(_tiles, _tile_y);
        }
        
        // Shuffle for random spawn positions
        var _count = array_length(_tiles);
        for (var i = _count - 1; i > 0; --i)
        {
            var j = irandom(i);
            var _temp = _tiles[i];
            _tiles[i] = _tiles[j];
            _tiles[j] = _temp;
        }
        
        // Try spawning at random positions
        for (var i = 0; i < _count; ++i)
        {
            if (control_creature_spawn.__spawn(_world_time, _tile_x, _tiles[i], _biome_data, _creature_data))
            {
                return true;
            }
        }
        
        return false;
    }
    
    timer_creature_spawn += _dt / GAME_TICK;
    
    var _world_save_data = global.world_save_data;
    
    var _spawn_interval = global.world_data[$ _world_save_data.dimension].get_spawn_interval();
    
    if (timer_creature_spawn < _spawn_interval) exit;
    
    randomize();
    
    // Cache frequently accessed data
    var _biome_data = global.biome_data;
    var _creature_data = global.creature_data;
    
    timer_creature_spawn -= _spawn_interval;
    
    var _world_time = _world_save_data.time;
    
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    var _camera_width  = global.camera_width;
    var _camera_height = global.camera_height;
    
    var _tile_xstart = round(_camera_x / TILE_SIZE) - 4;
    var _tile_xend   = round((_camera_x + _camera_width) / TILE_SIZE) + 4;
    
    var _tile_ystart = round(_camera_y / TILE_SIZE) - 4;
    var _tile_yend   = round((_camera_y + _camera_height) / TILE_SIZE) + 4;
    
    // Periodically clean up density grid (remove entries for destroyed creatures)
    global.spawn_last_cleanup_time += _dt / GAME_TICK;
    
    if (global.spawn_last_cleanup_time >= 5.0) // Cleanup every 5 seconds
    {
        global.spawn_last_cleanup_time = 0;
        
        // Rebuild density grid by counting actual creatures
        global.spawn_density_grid = {};
        
        with (obj_Creature)
        {
            var _grid_x = floor(x / (TILE_SIZE * SPAWN_DENSITY_GRID_SIZE));
            var _grid_y = floor(y / (TILE_SIZE * SPAWN_DENSITY_GRID_SIZE));
            var _grid_key = $"{_grid_x}_{_grid_y}";
            
            global.spawn_density_grid[$ _grid_key] = (global.spawn_density_grid[$ _grid_key] ?? 0) + 1;
        }
    }
    
    // Try spawning in perimeter - random order for better distribution
    var _spawn_attempts = [
        { type: "horizontal", y: round(_camera_y / TILE_SIZE) - 2 },
        { type: "vertical", x: round(_camera_x / TILE_SIZE) - 2 },
        { type: "horizontal", y: round((_camera_y + _camera_height) / TILE_SIZE) + 2 },
        { type: "vertical", x: round((_camera_x + _camera_width) / TILE_SIZE) + 2 },
    ];
    
    // Shuffle spawn attempts
    for (var i = 3; i > 0; --i)
    {
        var j = irandom(i);
        var _temp = _spawn_attempts[i];
        _spawn_attempts[i] = _spawn_attempts[j];
        _spawn_attempts[j] = _temp;
    }
    
    // Try each spawn location
    for (var i = 0; i < 4; ++i)
    {
        var _attempt = _spawn_attempts[i];
        var _spawned = false;
        
        if (_attempt.type == "horizontal")
        {
            _spawned = __spawn_horizontal(_world_time, _attempt.y, _tile_xstart, _tile_xend, _biome_data, _creature_data);
        }
        else
        {
            _spawned = __spawn_vertical(_world_time, _attempt.x, _tile_ystart, _tile_yend, _biome_data, _creature_data);
        }
        
        if (_spawned) break; // Only spawn one creature per interval
    }
}