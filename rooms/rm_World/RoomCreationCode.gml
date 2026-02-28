// Initialize player spawn position after all instances are created
if (obj_Game_Control.spawn_needs_init)
{
    var _current_world = global.current_world;
    var _world_data = global.world_data[$ _current_world.dimension];
    
    var _seed = _current_world.seed;
    var _base_tile_x = 0;
    with (obj_Player) { if (is_local) _base_tile_x = round(x / TILE_SIZE); }
    
    // Find a valid spawn position by trying horizontal offsets: 0, -4, 4, -8, 8, -12, 12, etc.
    var _spawn_found = false;
    var _max_attempts = 50; // Maximum offset of ±200 tiles
    
    for (var i = 0; i < _max_attempts && !_spawn_found; ++i)
    {
        // Calculate offset: 0, -4, 4, -8, 8, -12, 12, ...
        var _offset = (floor((i + 1) / 2) * 4) * ((i % 2 == 0) ? -1 : 1);
        if (i == 0) _offset = 0;
        
        var _player_tile_x = _base_tile_x + _offset;
        var _surface_height = worldgen_get_surface_height(_player_tile_x, _seed);
        var _cave_start     = worldgen_get_cave_start(_player_tile_x, _seed);
        
        // Verify spawn position using functional WorldGen
        // Check solidity: Y (floor) is solid, Y-1 (feet) is air, Y-2 (head) is air
        var _is_solid_floor = !worldgen_get_cave(_player_tile_x, _surface_height, _surface_height, _cave_start, _seed);
        
        if (_is_solid_floor)
        {
            // Valid spawn position found
            with (obj_Player)
            {
                if (is_local)
                {
                    x = _player_tile_x * TILE_SIZE;
                    y = ((_surface_height - 1) * TILE_SIZE) + (TILE_SIZE / 2); // Feet position
                }
            }
            _spawn_found = true;
        }
    }
    
    // Fallback: if no valid position found, use original position at surface height
    if (!_spawn_found)
    {
        var _surface_height = worldgen_get_surface_height(_base_tile_x, _seed);
        with (obj_Player)
        {
            if (is_local)
            {
                y = ((_surface_height - 1) * TILE_SIZE) + (TILE_SIZE / 2);
            }
        }
    }
    
    with (obj_Player)
    {
        if (is_local)
        {
            spawn_x = x;
            spawn_y = y;
            y_last = y;
        }
    }
    
    if (!directory_exists($"{PROGRAM_DIRECTORY_WORLDS}/{_current_world.uuid}"))
    {
        global.current_world.time = _world_data.get_time_start();
        
        global.current_world.weather.wind  = 0;
        global.current_world.weather.storm = 0;
    }
    else
    {
        with (obj_Player)
        {
            if (is_local) file_load_world_spawn(global.current_world, id, global.current_player.uuid);
        }
    }
    
    with (obj_Player)
    {
        if (is_local) control_camera_pos(x - (global.camera_width / 2), y - (global.camera_height / 2), true);
    }
    
    // Refresh lighting surface with correct position
    obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOL.LIGHTING;
    
    // Update sky and light colours based on initialized time
    var _lp = noone;
    with (obj_Player) { if (is_local) { _lp = id; break; } }
    
    if (_lp != noone)
    {
        with (obj_Game_Control_Background)
        {
            var _in_biome = bg_get_biome(round(_lp.x / TILE_SIZE), clamp(round(_lp.y / TILE_SIZE), 0, _world_data.get_world_height() - 1));
            var _in_biome_data = global.biome_data[$ _in_biome];
            
            in_biome = _in_biome;
            in_biome_transition = _in_biome;
            
            bg_sky_colour(_in_biome_data, _in_biome_data);
        }
    }
    
    obj_Game_Control.spawn_needs_init = false;
}

control_instance_unpause();