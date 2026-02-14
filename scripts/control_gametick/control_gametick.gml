function control_gametick(_delta_time)
{
    var _item_data = global.item_data;
    
    var _dt = GAME_TICK * _delta_time;
    
    global.tick_accumulator += _dt;
    
    var _time_length = global.world_data[$ global.world_save_data.dimension].get_time_length();
    
    var _camera_x = global.camera_x_real;
    var _camera_y = global.camera_y_real;
    
    var _camera_width  = global.camera_width;
    var _camera_height = global.camera_height;
    
    while (global.tick_accumulator >= 1)
    {
        with (obj_Player)
        {
            if (timer_respawn > 0)
            {
                timer_respawn -= 1 / GAME_TICK;
                
                if (timer_respawn <= 0)
                {
                    x = spawn_x;
                    y = spawn_y;
                    y_last = y;
                    
                    if (physics_body != undefined)
                    {
                        physics_body.vel_x = 0;
                        physics_body.vel_y = 0;
                        physics_body.pos_x = x;
                        physics_body.pos_y = y;
                    }
                    
                    hp = hp_max;
                }
            }
            
            if (is_local)
            {
                _camera_x = x - (_camera_width  / 2);
                _camera_y = y - (_camera_height / 2);
                
                control_camera_pos(_camera_x, _camera_y, true);
            }
            
            if (is_local && !(obj_Game_Control.is_opened & (IS_OPENED_BOOLEAN.MENU | IS_OPENED_BOOLEAN.CHAT | IS_OPENED_BOOLEAN.INVENTORY)))
            {
                var _tile_x = round(mouse_x / TILE_SIZE);
                var _tile_y = round(mouse_y / TILE_SIZE);
                var _mouse_distance = rectangle_distance(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom);
                
                if (cooldown_build <= 0) && (_mouse_distance < ATTRIBUTE_DEFAULT_BUILD_REACH) && (mouse_check_button(mb_right))
                {
                    player_build(1 / GAME_TICK, _tile_x, _tile_y);
                }
                else
                {
                    cooldown_build = max(0, cooldown_build - (1 / GAME_TICK));
                }
                
                if (cooldown_harvest <= 0) && (_mouse_distance < ATTRIBUTE_DEFAULT_HARVEST_REACH) && (mouse_check_button(mb_left))
                {
                    player_harvest(1 / GAME_TICK, _tile_x, _tile_y);
                }
                else
                {
                    timer_sfx_harvest = max(0, timer_sfx_harvest - (1 / GAME_TICK));
                    cooldown_harvest = max(0, cooldown_harvest - (1 / GAME_TICK));
                }
                
                // Decay harvest progress
                var _keys = struct_get_names(harvest_progress);
                for (var _key_index = 0; _key_index < array_length(_keys); _key_index++)
                {
                    var _key = _keys[_key_index];
                    if (_key != harvest_last_key)
                    {
                        harvest_progress[$ _key] = max(0, harvest_progress[$ _key] - (1 / GAME_TICK)); // Undoes 1 hardness per second
                        if (harvest_progress[$ _key] <= 0) variable_struct_remove(harvest_progress, _key);
                    }
                }
                harvest_last_key = undefined;
            }
        }
        
        for (var i = 0; i < chunk_in_view_length; ++i)
        {
            var _chunk = chunk_in_view[i];
            
            if (_chunk == undefined) || !(_chunk.boolean & CHUNK_BOOLEAN.GENERATED) continue;
            
            var _chunk_xstart = _chunk.chunk_xstart;
            var _chunk_ystart = _chunk.chunk_ystart;
            
            var _chunk_data = _chunk.chunk;
            var _chunk_count = _chunk.chunk_count;
            var _chunk_display = _chunk.chunk_display;
            
            repeat (16)
            {
                var _x2 = irandom(CHUNK_SIZE - 1);
                var _y2 = irandom(CHUNK_SIZE - 1);
                
                var _z = irandom(CHUNK_DEPTH - 1);
                var _bitmask = 1 << _z;
                
                if !(_chunk_display & _bitmask) || (_chunk_count[_z] <= 0) continue;
                
                var _tile = _chunk_data[tile_index_xyz(_x2, _y2, _z)];
                
                if (_tile == TILE_EMPTY) continue;
                
                var _data = _item_data[$ _tile.get_id()];
                
                var _on_random_tick = _data.get_on_random_tick();
                var _on_random_tick_length = _data.get_on_random_tick_length();
                
                for (var j = 0; j < _on_random_tick_length; ++j)
                {
                    function_execute(_on_random_tick[j], (_chunk_xstart + _x2) * TILE_SIZE, (_chunk_ystart + _y2) * TILE_SIZE, _z, 1, 1);
                }
            }
        }
        
        // Process delayed function executions
        tick_delay_process();
        
        // === SERVER-ONLY LOGIC ===
        // These only run on Server (or Singleplayer/NONE)
        var _is_server = (global.network_role == NETWORK_ROLE.SERVER) || (global.network_role == NETWORK_ROLE.NONE);
        
        if (_is_server)
        {
            control_creature_spawn();
        }
        
        with (obj_Player)
        {
            control_player();
        }
        
        with (obj_Client)
        {
            control_client();
        }
        
        // Restore cooldown update loop
        var _item_cooldown_names  = struct_get_names(item_cooldown);
        var _item_cooldown_length = array_length(_item_cooldown_names);
        
        for (var j = 0; j < _item_cooldown_length; ++j)
        {
            var _name = _item_cooldown_names[j];
            
            item_cooldown[$ _name] = max(0, item_cooldown[$ _name] - (1 / GAME_TICK));
        }
        
        if (_is_server)
        {
            with (obj_Projectile)
            {
                control_projectile();
            }
        }
        
        control_chunk_fade();
        
        // Update pooled particles (physics for colliding particles)
        global.particle_pool.update_physics();
        
        if (_is_server)
        {
            with (obj_Creature)
            {
                control_creature();
            }
            
            control_quadtree_update();
            control_resolve_collisions();
            
            with (obj_Item_Drop)
            {
                control_item_drop();
            }
            
            with (obj_Falling_Tile)
            {
                control_falling_tile();
            }
        }
        
        global.world_save_data.time += 1 / GAME_TICK;
        
        if (global.world_save_data.time >= _time_length)
        {
            global.world_save_data.time %= _time_length;
            
            ++global.world_save_data.day;
        }
        
        // --- NETWORK SYNC ---
        // Server: Broadcast entity states to all clients
        if (global.network_role == NETWORK_ROLE.SERVER)
        {
            network_broadcast_entities();
        }
        // Client: Send local player input to server
        else if (global.network_role == NETWORK_ROLE.CLIENT)
        {
            network_send_input();
        }
        
        global.tick_accumulator -= 1;
    }
}