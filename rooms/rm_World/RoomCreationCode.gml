// Initialize player spawn position after all instances are created
if (obj_Game_Control.spawn_needs_init)
{
    var _world_save_data = global.world_save_data;
    var _world_data = global.world_data[$ _world_save_data.dimension];
    
    var _seed = _world_save_data.seed;
    var _base_tile_x = round(obj_Player.x / TILE_SIZE);
    
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
        var _cave_start = worldgen_get_cave_start(_player_tile_x, _seed);
        
        // Check if the position at surface height (one tile above surface) is inside a cave
        var _spawn_tile_y = _surface_height - 1;
        var _is_in_cave = worldgen_get_cave(_player_tile_x, _spawn_tile_y + 1, _surface_height, _cave_start, _seed);
        
        if (!_is_in_cave)
        {
            // Valid spawn position found
            obj_Player.x = _player_tile_x * TILE_SIZE;
            obj_Player.y = (_spawn_tile_y * TILE_SIZE) + (TILE_SIZE / 2);
            _spawn_found = true;
        }
    }
    
    // Fallback: if no valid position found, use original position at surface height
    if (!_spawn_found)
    {
        var _surface_height = worldgen_get_surface_height(_base_tile_x, _seed);
        obj_Player.y = ((_surface_height - 1) * TILE_SIZE) + (TILE_SIZE / 2);
    }
    
    obj_Player.spawn_x = obj_Player.x;
    obj_Player.spawn_y = obj_Player.y;
    
    if (!directory_exists($"{PROGRAM_DIRECTORY_WORLDS}/{_world_save_data.uuid}"))
    {
        global.world_save_data.time = _world_data.get_time_start();
        
        global.world_save_data.weather_wind  = 0;
        global.world_save_data.weather_storm = 0;
    }
    else
    {
        file_load_world_spawn(global.world_save_data, obj_Player, global.player_save_data.uuid);
    }
    
    control_camera_pos(obj_Player.x - (global.camera_width / 2), obj_Player.y - (global.camera_height / 2), true);
    
    obj_Player.y_last = obj_Player.y;
    
    // Refresh lighting surface with correct position
    obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
    
    // Update sky and light colours based on initialized time
    with (obj_Game_Control_Background)
    {
        var _in_biome = bg_get_biome(round(obj_Player.x / TILE_SIZE), clamp(round(obj_Player.y / TILE_SIZE), 0, _world_data.get_world_height() - 1));
        var _in_biome_data = global.biome_data[$ _in_biome];
        
        in_biome = _in_biome;
        in_biome_transition = _in_biome;
        
        bg_sky_colour(_in_biome_data, _in_biome_data);
    }
    
    obj_Game_Control.spawn_needs_init = false;
}

control_instance_unpause();