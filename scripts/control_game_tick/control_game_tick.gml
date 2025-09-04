function control_game_tick(_delta_time)
{
    var _item_data = global.item_data;
    var _item_function = global.item_function;
    
    var _dt = GAME_TICK * _delta_time;
    
    global.tick_accumulator += _dt;
    
    var _time_length = global.world_data[$ global.world_save_data.dimension].get_time_length();
    
    var _camera_x = global.camera_x_real;
    var _camera_y = global.camera_y_real;
    
    var _camera_width  = global.camera_width;
    var _camera_height = global.camera_height;
    
    while (global.tick_accumulator >= 1)
    {
        var _tick = min(1, global.tick_accumulator);
        
        if (timer_respawn > 0)
        {
            timer_respawn -= _tick / GAME_TICK;
            
            if (timer_respawn <= 0)
            {
                obj_Player.x = obj_Player.spawn_x;
                obj_Player.y = obj_Player.spawn_y;
                
                obj_Player.xvelocity = 0;
                obj_Player.yvelocity = 0;
                
                obj_Player.hp = obj_Player.hp_max;
                
                _camera_x = obj_Player.x - (_camera_width  / 2);
                _camera_y = obj_Player.y - (_camera_height / 2);
                
                control_camera_pos(_camera_x, _camera_y, true);
            }
        }
        
        for (var i = 0; i < chunk_in_view_length; ++i)
        {
            var _inst = chunk_in_view[i];
            
            if (!instance_exists(_inst)) || !(_inst.boolean & CHUNK_BOOLEAN.GENERATED) continue;
            
            var _chunk_xstart = _inst.chunk_xstart;
            var _chunk_ystart = _inst.chunk_ystart;
            
            var _chunk = _inst.chunk;
            var _chunk_count = _inst.chunk_count;
            var _chunk_display = _inst.chunk_display;
            
            repeat (4)
            {
                var _x2 = irandom(CHUNK_SIZE - 1);
                var _y2 = irandom(CHUNK_SIZE - 1);
                
                var _z = irandom(CHUNK_DEPTH - 1);
                var _bitmask = 1 << _z;
                
                if !(_chunk_display & _bitmask) || (_chunk_count[_z] <= 0) continue;
                
                var _tile = _chunk[tile_index_xyz(_x2, _y2, _z)];
                
                if (_tile == TILE_EMPTY) continue;
                
                var _data = _item_data[$ _tile.get_id()];
                
                var _on_random_tick = _data.get_on_random_tick();
                var _on_random_tick_length = _data.get_on_random_tick_length();
                
                for (var j = 0; j < _on_random_tick_length; ++j)
                {
                    function_execute(_on_random_tick[j], (_chunk_xstart + _x2) * TILE_SIZE, (_chunk_ystart + _y2) * TILE_SIZE, _z, 1, 1, _tick);
                }
            }
        }
        
        control_creature_spawn(_tick);
        
        with (obj_Player)
        {
            control_player(_tick);
        }
        
        if (mouse_check_button(mb_right))
        {
            var _inventory_selected_hotbar = global.inventory_selected_hotbar;
            var _item_holding = global.inventory.base[_inventory_selected_hotbar];
            
            if (_item_holding != INVENTORY_EMPTY)
            {
                var _data = _item_data[$ _item_holding.get_id()];
                var _hp = _data.get_item_consumable_hp();
                
                if (obj_Player.hp < obj_Player.hp_max) && (_hp != undefined)
                {
                    var _cooldown_id = _data.get_item_consumable_cooldown_id();
                    
                    if (_cooldown_id != undefined)
                    {
                        obj_Player.hp = min(obj_Player.hp_max, obj_Player.hp + _hp);
                        obj_Player.saturation += _data.get_item_consumable_saturation();
                        
                        item_cooldown[$ _cooldown_id] = _data.get_item_consumable_cooldown_second();
                        
                        inventory_delete("base", _inventory_selected_hotbar);
                        
                        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR | SURFACE_REFRESH_BOOLEAN.HP;
                        
                        var _sfx = _data.get_item_consumable_sfx_id();
                        
                        if (_sfx != undefined)
                        {
                            sfx_diegetic_play(obj_Player.audio_emitter, obj_Player.x, obj_Player.y, _sfx);
                        }
                    }
                }
            }
        }
        
        var _item_cooldown_names  = struct_get_names(item_cooldown);
        var _item_cooldown_length = array_length(_item_cooldown_names);
        
        for (var j = 0; j < _item_cooldown_length; ++j)
        {
            var _name = _item_cooldown_names[j];
            
            item_cooldown[$ _name] = max(0, item_cooldown[$ _name] - (_tick / GAME_TICK));
        }
        
        with (obj_Projectile)
        {
            control_projectile(_tick);
        }
        
        with (obj_Particle)
        {
            control_particle(_tick);
        }
        
        with (obj_Creature)
        {
            control_creature(_tick);
        }
        
        with (obj_Item_Drop)
        {
            control_item_drop(_tick);
        }
        
        global.world_save_data.time += _tick / GAME_TICK;
        
        if (global.world_save_data.time >= _time_length)
        {
            global.world_save_data.time %= _time_length;
            
            ++global.world_save_data.day;
        }
        
        global.tick_accumulator -= 1;
    }
}