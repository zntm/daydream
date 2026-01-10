/// @desc Player control using new physics system
/// @param {Real} _dt Delta time

function control_player()
{
    if (hp <= 0) exit;
    
    // --- REMOTE PLAYERS ON CLIENT (INTERPOLATION) ---
    if (!is_local && global.network_role == NETWORK_ROLE.CLIENT)
    {
        interp_timer += 1 / GAME_TICK;
        var _t = clamp(interp_timer / interp_duration, 0, 1);
        
        x = lerp(interp_start_x, interp_target_x, _t);
        y = lerp(interp_start_y, interp_target_y, _t);
        
        // Simple facing direction
        if (interp_target_x != interp_start_x)
        {
            image_xscale = abs(image_xscale) * sign(interp_target_x - interp_start_x);
        }
        
        // Update physics body pos just for rendering/synchronization if needed
        if (variable_instance_exists(self, "physics_body"))
        {
            physics_body.pos_x = x;
            physics_body.pos_y = y;
        }
        
        // Update animation state here based on movement
        if (variable_instance_exists(self, "network_input") && network_input != undefined)
        {
            input_state.attack_held = network_input.attack;
            input_state.use_held = network_input.use;
            
            // Trigger swing animation if attacking
            if (input_state.attack_held && timer_attack <= 0)
            {
                timer_attack = 0.3; // Match duration in logic
                
                // For remote players, we might need a placeholder or sync the selected item
                // For now, let's assume they are using a generic tool visual or nothing if we don't sync hotbar index yet
                // Actually, let's try to show their tool if we can.
            }
        }
        
        // Handle timer and inst_item creation for remote players visually
        if (timer_attack > 0)
        {
            timer_attack = max(0, timer_attack - (1 / GAME_TICK));
            
            // Create visual tool if it doesn't exist
            if (!instance_exists(inst_item))
            {
                inst_item = instance_create_layer(x, y, "Instances", obj_Tool);
                inst_item.image_speed = 0;
                inst_item.inst_owner = id;
                // Use synced item ID for visual
                if (variable_instance_exists(self, "extra_id") && extra_id != "")
                {
                    var _data = global.item_data[$ extra_id];
                    if (_data != undefined)
                    {
                        var _sprite_asset = global.sprite_asset[$ _data.get_sprite()];
                        if (_sprite_asset != undefined) inst_item.sprite_index = _sprite_asset.get_sprite();
                    }
                }
                else
                {
                    inst_item.sprite_index = spr_Inventory_Slot; // Placeholder
                }
            }
            
            // Weapon swing animation (Visual only)
            var _direction = sign(image_xscale);
            var _t = power((0.3 - timer_attack) / 0.3, 1 / 4);
            var _angle = (45 * cos(_t * pi)) + 15;
            
            with (inst_item)
            {
                image_yscale = _direction;
                x = other.x + (lengthdir_x(16, _angle) * _direction);
                y = other.y - 24 + (lengthdir_y(16, _angle));
                if (_direction > 0) image_angle = _angle - 45;
                else image_angle = 180 - _angle + 45;
            }
        }
        else if (instance_exists(inst_item))
        {
            instance_destroy(inst_item);
        }
        
        exit; // Skip physics simulation for remote players on client
    }
    
    var _x_prev = x;
    var _y_prev = y;
    
    // --- INPUT ---
    // For remote players (Server-side), use network input
    if (is_local)
    {
        input_state.poll_player();
    }
    else if (global.network_role == NETWORK_ROLE.SERVER && network_input != undefined)
    {
        // Apply network input for remote players
        input_state.move_x = network_input.move_x;
        input_state.move_y = network_input.move_y;
        input_state.move_left = (network_input.move_x < 0);
        input_state.move_right = (network_input.move_x > 0);
        input_state.move_up = (network_input.move_y < 0);
        input_state.move_down = (network_input.move_y > 0);
        input_state.jump = network_input.jump;
        input_state.attack_held = network_input.attack;
        input_state.use_held = network_input.use;
    }
    else
    {
        // No input available for remote player on server? Skip
        if (global.network_role == NETWORK_ROLE.SERVER) exit;
        
        // If we are singleplayer (NONE), fall through to normal logic (should happen via is_local=true usually)
    }
    
    // --- DOUBLE INPUT ---
    if !(obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.MENU)
    {
        var _inv_target = global.inventory;
        var _hotbar_idx = global.inventory_selected_hotbar;
        
        if (global.network_role == NETWORK_ROLE.SERVER && !is_local)
        {
            var _client = global.network_clients[? socket_id];
            if (!is_undefined(_client))
            {
                _inv_target = _client.inventory;
                _hotbar_idx = selected_hotbar;
            }
        }
        
        var _item = _inv_target.base[_hotbar_idx];
        
        if (_item != INVENTORY_EMPTY)
        {
            var _data = global.item_data[$ _item.get_id()];
            
            if (_data != undefined)
            {
                // Double Attack
                if (input_state.attack_double_pressed)
                {
                    var _on_event = _data.get_on_item_double_attack();
                    var _on_event_length = _data.get_on_item_double_attack_length();
                    
                    if (_on_event != undefined)
                    {
                        for (var j = 0; j < _on_event_length; ++j)
                        {
                            function_execute(_on_event[j], round(x / TILE_SIZE), round(y / TILE_SIZE), CHUNK_DEPTH_DEFAULT, sign(image_xscale), sign(image_yscale), id, _item);
                        }
                    }
                }
                
                // Double Use
                if (input_state.use_double_pressed)
                {
                    var _on_event = _data.get_on_item_double_use();
                    var _on_event_length = _data.get_on_item_double_use_length();
                    
                    if (_on_event != undefined)
                    {
                        for (var j = 0; j < _on_event_length; ++j)
                        {
                            function_execute(_on_event[j], round(x / TILE_SIZE), round(y / TILE_SIZE), CHUNK_DEPTH_DEFAULT, sign(image_xscale), sign(image_yscale), id, _item);
                        }
                    }
                }
                
                if (input_state.move_left_double_pressed) || (input_state.move_right_double_pressed) || (input_state.move_up_double_pressed) || (input_state.move_down_double_pressed)
                {
                    var _on_event = _data.get_on_item_double_move();
                    var _on_event_length = _data.get_on_item_double_move_length();
                    
                    if (_on_event != undefined)
                    {
                        for (var j = 0; j < _on_event_length; ++j)
                        {
                            function_execute(_on_event[j], round(x / TILE_SIZE), round(y / TILE_SIZE), CHUNK_DEPTH_DEFAULT, sign(image_xscale), sign(image_yscale), id, _item);
                        }
                    }
                }
            }
        }
    }
    
    // --- DAMAGE CHECK ---
    if (timer_immunity <= 0)
    {
        var _inst = instance_place(x, y, obj_Creature);
        
        if (instance_exists(_inst))
        {
            var _data = global.creature_data[$ _inst._id];
            
            if (_data.get_hostility_type() == CREATURE_HOSTILITY_TYPE.HOSTILE)
            {
                var _died = control_entity_damage(id, _inst, _data.get_contact_damage());
                
                obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.HP;
                
                if (_died) exit;
                
                // Knockback using new physics
                var _kb_dir = sign(x - _inst.x);
                if (_kb_dir == 0) _kb_dir = 1;
                physics_body.vel_x = _kb_dir * 4;
                physics_body.vel_y = -3;
            }
        }
    }
    
    if (timer_immunity > 0)
    {
        timer_immunity = max(0, timer_immunity - (1 / GAME_TICK));
    }
    
    // --- AUDIO ---
    audio_listener_position(x, y, 0);
    
    // --- PHYSICS ---
    physics_body.sync_from_instance(id);
    global.spatial_grid.update(physics_body);
    entity_update_collision(physics_body);
    
    // Choose physics mode based on debug settings
    if (IS_DEVELOPER_MODE)
    {
        var _enable_physics = global.dbg_settings[$ "enable_physics"];
        var _noclip = global.dbg_settings[$ "noclip"] ?? false;
        
        if (_noclip)
        {
             // Noclip: Move directly and skip physics step
             var _fly_speed = global.dbg_settings[$ "fly_speed"] ?? 8.65;
             var _vx = (input_state.move_right - input_state.move_left) * _fly_speed;
             var _vy = (input_state.move_down - input_state.move_up) * _fly_speed;
             
             x += _vx * _dt;
             y += _vy * _dt;
             
             physics_body.vel_x = 0;
             physics_body.vel_y = 0;
             physics_body.sync_to_instance(id);
             
             // Update camera/visibility and exit
             control_camera_pos(x - (global.camera_width / 2), y - (global.camera_height / 2), false);
             // (Copying chunk update logic if needed, or ensuring it runs next frame)
             // For simplicity, we just return. The camera/chunk logic is at end of script, so we should jump there.
             // Actually, let's just use the existing logic flow but bypass physics_step.
        }
        else if (!_enable_physics)
        {
            // Creative flight mode (no gravity, but collisions enabled usually? Or fly mode handles it?)
            // physics_mode_fly handles input movement.
            physics_body.mode = MOVEMENT_MODE.FLY;
        }
    }
    
    if (IS_DEVELOPER_MODE && (global.dbg_settings[$ "noclip"] ?? false))
    {
        // Skip physics step for noclip
    }
    else
    {
        physics_step(physics_body, input_state);
    }
    physics_body.sync_to_instance(id);
    
    // --- COMBAT ---
    if !(obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.MENU) && (timer_attack <= 0) && (input_state.attack_held)
    {
        sfx_diegetic_play(audio_emitter, x, y, "phantasia:sfx/item/swing", global.settings.audio_sfx);
        
        statistics_increment("items_used", 1);
        
        timer_attack = 0.3;
        
        var _item = _inv_target.base[_hotbar_idx];
        
        if (_item != INVENTORY_EMPTY)
        {
            var _id = _item.get_id();
            var _data = global.item_data[$ _id];

            statistics_increment($"items_used_{_id}", 1);
            
            if (!instance_exists(inst_item))
            {
                inst_item = instance_create_layer(x, y, "Instances", obj_Tool);
                inst_item._id = _id;
                inst_item.sprite_index = global.sprite_asset[$ _data.get_sprite()].get_sprite();
                inst_item.image_index = _data.get_inventory_index();
                inst_item.image_speed = 0;
                inst_item.inst_owner = id;
            }
            
            // Shooting logic
            var _angle = input_state.aim_angle;
            if (control_entity_shoot(id, _id, x, y - 24, _angle))
            {
                // Shot something
            }
            
            var _on_attack = _data.get_on_attack();
            var _on_attack_length = _data.get_on_attack_length();
            
            for (var j = 0; j < _on_attack_length; ++j)
            {
                function_execute(_on_attack[j], round(x / TILE_SIZE), round(y / TILE_SIZE), CHUNK_DEPTH_DEFAULT, sign(image_xscale), sign(image_yscale), id, _item);
            }
        }
    }
    
    // Attack timer and weapon swing animation
    if (timer_attack > 0)
    {
        timer_attack = max(0, timer_attack - (1 / GAME_TICK));
    }
    
    if (timer_attack <= 0)
    {
        // Face movement direction
        if (input_state.move_x != 0)
        {
            image_xscale = abs(image_xscale) * sign(input_state.move_x);
        }
        
        if (instance_exists(inst_item))
        {
            instance_destroy(inst_item);
        }
    }
    else if (instance_exists(inst_item))
    {
        // Weapon swing animation
        var _direction = sign(image_xscale);
        var _t = power((0.3 - timer_attack) / 0.3, 1 / 4);
        var _angle = (45 * cos(_t * pi)) + 15;
        
        with (inst_item)
        {
            var _id = self._id;
            var _sprite_width = sprite_get_width(sprite_index);
            var _sprite_height = sprite_get_height(sprite_index);
            
            image_yscale = _direction;
            
            x = other.x + (lengthdir_x(_sprite_width, _angle) * _direction);
            y = other.y - 24 + (lengthdir_y(_sprite_height, _angle));
            
            if (_direction > 0)
            {
                image_angle = _angle - ((global.item_data[$ _id].has_type(ITEM_TYPE_BIT.TOOL)) ? 45 : 90);
            }
            else
            {
                image_angle = 180 - _angle + ((global.item_data[$ _id].has_type(ITEM_TYPE_BIT.TOOL)) ? 45 : 90);
            }
        }
    }
    
    // --- FALL DAMAGE ---
    /*
    if (y > y_last)
    {
        if (physics_body.collision.ground)
        {
            var _difference = max(0, y - y_last - (TILE_SIZE * 8));
            var _value = floor(power(floor(_difference / TILE_SIZE) * 0.62, 1.25));
            
            if (_value > 0 && !attribute.has_boolean(ATTRIBUTE_BOOLEAN.IS_FALL_DAMAGE_RESISTANT))
            {
                obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.HP;
                hp -= _value;
                y_last = y;
                
                repeat (irandom_range(2, 6))
                {
                    spawn_particle(random_range(bbox_left, bbox_right), random_range(bbox_top, bbox_bottom), "phantasia:entity/damage");
                }
                
                spawn_floating_text(x, y, _value, 0, -3.9);
                
                if (hp <= 0)
                {
                    obj_Game_Control.timer_respawn = 3;
                    exit;
                }
            }
        }
    }
    else
    {
        y_last = y;
    }
    */
    creature_handle_fall_damage();
    
    // --- POST-PHYSICS ---
    control_entity_sfx();
    
    // Camera
    control_camera_pos(x - (global.camera_width / 2), y - (global.camera_height / 2), false);
    
    // Regeneration
    var _is_regenerated = false;
    if (attribute.has_boolean(ATTRIBUTE_BOOLEAN.HAS_REGENERATION))
    {
        _is_regenerated = control_entity_regeneration(1 / GAME_TICK);
    }
    
    control_entity_effect();
    
    if (_is_regenerated)
    {
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.HP;
    }
    
    // Chunk visibility
    if (physics_body.vel_x != 0 || physics_body.vel_y != 0)
    {
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.LIGHTING;
        
        var _camera_x = global.camera_x;
        var _camera_y = global.camera_y;
        var _camera_width = global.camera_width;
        var _camera_height = global.camera_height;
        
        var _xstart = round((_camera_x + (_camera_width / 2)) / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION;
        var _ystart = round((_camera_y + (_camera_height / 2)) / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION;
        
        if (_xstart != obj_Game_Control.chunk_in_view_x || _ystart != obj_Game_Control.chunk_in_view_y)
        {
            obj_Game_Control.chunk_in_view_x = _xstart;
            obj_Game_Control.chunk_in_view_y = _ystart;
            control_update_chunk_in_view();
        }
    }
    
    // Distance Statistics
    var _dist = point_distance(_x_prev, _y_prev, x, y);
    if (_dist > 0)
    {
        statistics_increment("distance_travelled", _dist);
        
        switch (physics_body.mode)
        {
            case MOVEMENT_MODE.GROUND: statistics_increment("distance_walked", _dist); break;
            case MOVEMENT_MODE.FLY:    statistics_increment("distance_flown", _dist); break;
            case MOVEMENT_MODE.SWIM:   statistics_increment("distance_swum", _dist); break;
            case MOVEMENT_MODE.CLIMB:  statistics_increment("distance_climbed", _dist); break;
        }
    }

    control_entity_suffocation(id);
}