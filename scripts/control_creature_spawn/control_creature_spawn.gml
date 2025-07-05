function control_creature_spawn(_dt)
{
    timer_creature_spawn += _dt / GAME_TICK;
    
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    var _camera_width  = global.camera_width;
    var _camera_height = global.camera_height;
    
    var _direction = irandom(3);
    
    // Up
    if (_direction == 0)
    {
        var _x = random_range(_camera_x - (TILE_SIZE * 4), _camera_x + _camera_width + (TILE_SIZE * 4));
        var _y = (round(_camera_y / TILE_SIZE) * TILE_SIZE) - (TILE_SIZE / 2) - (TILE_SIZE * 4);
        
        var _biome = global.biome_data[$ bg_get_biome(round(_x / TILE_SIZE), round(_y / TILE_SIZE))];
        
        if (_biome.get_creature_spawn_length() > 0)
        {
            var _interval = _biome.get_creature_spawn_interval();
            
            if (timer_creature_spawn >= _interval)
            {
                timer_creature_spawn -= _interval;
                
                var _creature = array_choose(_biome.get_creature_spawn());
                var _creature_data = global.creature_data[$ _creature.id];
                
                if (chance(_creature.chance))
                {
                    var _can_spawn = false;
                    
                    with (obj_Game_Control_Spawn_Check)
                    {
                        _can_spawn = !tile_meeting(_x, _y);
                    }
                    
                    if (_can_spawn)
                    {
                        
                    }
                }
            }
        }
        
        exit;
    }
    
    // Left
    if (_direction == 1)
    {
        exit;
    }
    
    // Down
    if (_direction == 2)
    {
        exit;
    }
    
    // Right
    if (_direction == 3)
    {
        exit;
    }
}