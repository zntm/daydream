function control_creature_spawn(_dt)
{
    static __spawn = function(_world_time, _tile_x, _tile_y, _biome_data, _creature_data)
    {
        var _x = (_tile_x * TILE_SIZE);
        var _y = (_tile_y * TILE_SIZE) - (TILE_SIZE / 2);
        
        var _biome = _biome_data[$ bg_get_biome(_tile_x, _tile_y)];
        
        var _spawn = _biome.get_creature();
        var _spawn_length = _biome.get_creature_length();
        
        for (var i = 0; i < _spawn_length; ++i)
        {
            var _creature = _spawn[i];
            
            var _id = _creature.id;
            
            if (!chance(_creature.chance)) continue;
            
            var _time = _creature.time;
            
            if (_time != undefined) && ((_world_time < _time.min) || (_world_time >= _time.max)) continue;
            
            var _attribute = _creature_data[$ _id].get_attribute();
            
            var _can_spawn = false;
            
            with (obj_Game_Control_Spawn_Check)
            {
                attribute = _attribute;
                
                image_xscale = _attribute.get_collision_box_width()  / 8;
                image_yscale = _attribute.get_collision_box_height() / 8;
                
                _can_spawn = !tile_meeting(_x, _y);
            }
            
            if (!_can_spawn) continue;
            
            var _tile = _creature.tile;
            
            if (_tile != undefined)
            {
                var _tile2 = tile_get(_tile_x, _tile_y, CHUNK_DEPTH_DEFAULT);
                
                if (_tile2 == TILE_EMPTY) || (!array_contains(_tile, _tile2.get_id())) continue;
            }
            
            var _variant = _creature.variant;
            
            repeat (smart_value(_creature.amount))
            {
                spawn_creature(_x, _y, _id, _variant);
            }
            
            return true;
        }
        
        return false;
    }
    
    static __spawn_horizontal = function(_world_time, _tile_y, _tile_xstart, _tile_xend, _biome_data, _creature_data)
    {
        for (var _tile_x = _tile_xstart; _tile_x <= _tile_xend; ++_tile_x)
        {
            control_creature_spawn.__spawn(_world_time, _tile_x, _tile_y, _biome_data, _creature_data);
        }
    }
    
    static __spawn_vertical = function(_world_time, _tile_x, _tile_ystart, _tile_yend, _biome_data, _creature_data)
    {
        for (var _tile_y = _tile_ystart; _tile_y <= _tile_yend; ++_tile_y)
        {
            control_creature_spawn.__spawn(_world_time, _tile_x, _tile_y, _biome_data, _creature_data);
        }
    }
    
    timer_creature_spawn += _dt / GAME_TICK;
    
    var _world_save_data = global.world_save_data;
    
    var _spawn_interval = global.world_data[$ _world_save_data.dimension].get_spawn_interval();
    
    if (timer_creature_spawn < _spawn_interval) exit;
    
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
    
    for (var i = 2; i < 6; ++i)
    {
        var _tile_x1 = round(_camera_x / TILE_SIZE) - i;
        var _tile_y1 = round(_camera_y / TILE_SIZE) - i;
        
        var _tile_x2 = round((_camera_x + _camera_width)  / TILE_SIZE) + i;
        var _tile_y2 = round((_camera_y + _camera_height) / TILE_SIZE) + i;
        
        var _spawned = false;
        
        _spawned = __spawn_horizontal(_world_time, _tile_y1, _tile_xstart, _tile_xend, _biome_data, _creature_data);
        
        if (_spawned) break;
        
        _spawned = __spawn_vertical(_world_time, _tile_x1, _tile_ystart, _tile_yend, _biome_data, _creature_data);
        
        if (_spawned) break;
        
        _spawned = __spawn_horizontal(_world_time, _tile_y2, _tile_xstart, _tile_xend, _biome_data, _creature_data);
        
        if (_spawned) break;
        
        _spawned = __spawn_vertical(_world_time, _tile_x2, _tile_ystart, _tile_yend, _biome_data, _creature_data);
        
        if (_spawned) break;
    }
}