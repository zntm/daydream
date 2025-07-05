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
        var _y = (round(_camera_y / TILE_SIZE) * TILE_SIZE) - (TILE_SIZE / 2) - (TILE_SIZE * irandom_range(-2, -8));
        
        var _biome = global.biome_data[$ bg_get_biome(round(_x / TILE_SIZE), round(_y / TILE_SIZE))];
        
        if (_biome.get_creature_spawn_length() > 0)
        {
            var _interval = _biome.get_creature_spawn_interval();
            
            if (timer_creature_spawn >= _interval)
            {
                timer_creature_spawn -= _interval;
                
                var _creature = array_choose(_biome.get_creature_spawn());
                
                var _id = _creature.id;
                
                if (chance(_creature.chance))
                {
                    var _creature_data = global.creature_data[$ _id];
                    
                    var _attribute = _creature_data.get_attribute();
                    var _can_spawn = false;
                    
                    with (obj_Game_Control_Spawn_Check)
                    {
                        attribute = _attribute;
                        
                        image_xscale = _attribute.get_collision_box_width()  / 8;
                        image_yscale = _attribute.get_collision_box_height() / 8;
                        
                        _can_spawn = !tile_meeting(_x, _y);
                    }
                    
                    if (_can_spawn)
                    {
                        spawn_creature(_x, _y, _id);
                    }
                }
            }
        }
        
        exit;
    }
    
    // Left
    if (_direction == 1)
    {
        var _x = _camera_x - (TILE_SIZE * 4);
        var _y = (irandom_range(round(_camera_y / TILE_SIZE), round((_camera_y + _camera_height) / TILE_SIZE)) * TILE_SIZE);
        
        var _biome = global.biome_data[$ bg_get_biome(round(_x / TILE_SIZE), round(_y / TILE_SIZE))];
        
        if (_biome.get_creature_spawn_length() > 0)
        {
            var _interval = _biome.get_creature_spawn_interval();
            
            if (timer_creature_spawn >= _interval)
            {
                timer_creature_spawn -= _interval;
                
                var _creature = array_choose(_biome.get_creature_spawn());
                
                var _id = _creature.id;
                
                if (chance(_creature.chance))
                {
                    var _creature_data = global.creature_data[$ _id];
                    
                    var _attribute = _creature_data.get_attribute();
                    var _can_spawn = false;
                    
                    with (obj_Game_Control_Spawn_Check)
                    {
                        attribute = _attribute;
                        
                        image_xscale = _attribute.get_collision_box_width()  / 8;
                        image_yscale = _attribute.get_collision_box_height() / 8;
                        
                        _can_spawn = !tile_meeting(_x, _y);
                    }
                    
                    if (_can_spawn)
                    {
                        spawn_creature(_x, _y, _id);
                    }
                }
            }
        }
        
        exit;
    }
    
    // Down
    if (_direction == 2)
    {
        var _x = random_range(_camera_x - (TILE_SIZE * 4), _camera_x + _camera_width + (TILE_SIZE * 4));
        var _y = (round((_camera_y + _camera_height) / TILE_SIZE) * TILE_SIZE) - (TILE_SIZE / 2) + (TILE_SIZE * irandom_range(-2, -8));
        
        var _biome = global.biome_data[$ bg_get_biome(round(_x / TILE_SIZE), round(_y / TILE_SIZE))];
        
        if (_biome.get_creature_spawn_length() > 0)
        {
            var _interval = _biome.get_creature_spawn_interval();
            
            if (timer_creature_spawn >= _interval)
            {
                timer_creature_spawn -= _interval;
                
                var _creature = array_choose(_biome.get_creature_spawn());
                
                var _id = _creature.id;
                
                if (chance(_creature.chance))
                {
                    var _creature_data = global.creature_data[$ _id];
                    
                    var _attribute = _creature_data.get_attribute();
                    var _can_spawn = false;
                    
                    with (obj_Game_Control_Spawn_Check)
                    {
                        attribute = _attribute;
                        
                        image_xscale = _attribute.get_collision_box_width()  / 8;
                        image_yscale = _attribute.get_collision_box_height() / 8;
                        
                        _can_spawn = !tile_meeting(_x, _y);
                    }
                    
                    if (_can_spawn)
                    {
                        spawn_creature(_x, _y, _id);
                    }
                }
            }
        }
        
        exit;
    }
    
    // Right
    if (_direction == 3)
    {
        var _x = _camera_x + _camera_width + (TILE_SIZE * 4);
        var _y = (irandom_range(round(_camera_y / TILE_SIZE), round((_camera_y + _camera_height) / TILE_SIZE)) * TILE_SIZE);
        
        var _biome = global.biome_data[$ bg_get_biome(round(_x / TILE_SIZE), round(_y / TILE_SIZE))];
        
        if (_biome.get_creature_spawn_length() > 0)
        {
            var _interval = _biome.get_creature_spawn_interval();
            
            if (timer_creature_spawn >= _interval)
            {
                timer_creature_spawn -= _interval;
                
                var _creature = array_choose(_biome.get_creature_spawn());
                
                var _id = _creature.id;
                
                if (chance(_creature.chance))
                {
                    var _creature_data = global.creature_data[$ _id];
                    
                    var _attribute = _creature_data.get_attribute();
                    var _can_spawn = false;
                    
                    with (obj_Game_Control_Spawn_Check)
                    {
                        attribute = _attribute;
                        
                        image_xscale = _attribute.get_collision_box_width()  / 8;
                        image_yscale = _attribute.get_collision_box_height() / 8;
                        
                        _can_spawn = !tile_meeting(_x, _y);
                    }
                    
                    if (_can_spawn)
                    {
                        spawn_creature(_x, _y, _id);
                    }
                }
            }
        }
        
        exit;
    }
}