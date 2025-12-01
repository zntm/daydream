// Initialize player spawn position after all instances are created
if (obj_Game_Control.spawn_needs_init)
{
    var _world_save_data = global.world_save_data;
    var _world_data = global.world_data[$ _world_save_data.dimension];
    
    var _seed = _world_save_data.seed;
    var _player_tile_x = round(obj_Player.x / TILE_SIZE);
    var _surface_height = worldgen_get_surface_height(_player_tile_x, _seed);
    
    obj_Player.y = ((_surface_height - 1) * TILE_SIZE) + (TILE_SIZE / 2);
    
    var _cave_start = worldgen_get_cave_start(_player_tile_x, _seed);
    
    while (worldgen_get_cave(_player_tile_x, round(obj_Player.y / TILE_SIZE) + 1, _surface_height, _cave_start, _seed))
    {
        obj_Player.y += TILE_SIZE;
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
    
    control_camera_pos(obj_Player.x , obj_Player.y, true);
    
    obj_Player.ylast = obj_Player.y;
    
    // Refresh lighting surface with correct position
    obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
    
    // Update sky and light colors based on initialized time
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