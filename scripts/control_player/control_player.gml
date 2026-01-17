/// @desc Player control using new physics system
/// @param {Real} _dt Delta time

function control_player()
{
    // Debug entry
    if (global.network_role == NETWORK_ROLE.SERVER && !is_local) 
    {
        // show_debug_message($"[NET-PHYS] control_player running for proxy {uuid}, hp={hp}");
    }

    if (hp <= 0) 
    {
        if (global.network_role == NETWORK_ROLE.SERVER && !is_local) show_debug_message($"[NET-PHYS] Player {uuid} is DEAD, skipping");
        exit;
    }
    

    
    var _x_prev = x;
    var _y_prev = y;
    
    // --- INPUT ---
    if (is_local)
    {
        input_state.poll_player();
    }
    
    // Apply aim
    if (input_state.move_x != 0 || input_state.move_y != 0)
    {
        input_state.aim_x = input_state.move_x;
        input_state.aim_y = input_state.move_y;
        input_state.aim_angle = point_direction(0, 0, input_state.aim_x, input_state.aim_y);
    }
    // Note: Physics should ALWAYS run even with no input (gravity, friction, etc.)
    
    // --- STAMINA & COMBO ---
    if (is_local)
    {
        // Stamina
        var _is_sprinting = input_state.sprint_held && (input_state.move_x != 0);
        
        if (_is_sprinting)
        {
            if (stamina > 0)
            {
                stamina = max(0, stamina - (25 / GAME_TICK)); // Drain ~25 per second
                stamina_regen_timer = 1.0; // 1s cooldown before regen
            }
            else
            {
                // Exhausted
                input_state.sprint_held = false;
            }
        }
        else
        {
            if (stamina_regen_timer > 0)
            {
                stamina_regen_timer -= 1 / GAME_TICK;
            }
            else if (stamina < stamina_max)
            {
                stamina = min(stamina_max, stamina + (15 / GAME_TICK)); // Regen ~15 per second
            }
        }
        
        // Combo Timer
        if (timer_combo > 0)
        {
            timer_combo -= 1 / GAME_TICK;
            
            if (timer_combo <= 0)
            {
                combo_count = 0;
            }
        }
    }
    
    // --- DOUBLE INPUT ---
    if !(obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.MENU)
    {
        var _inv_target = global.inventory;
        var _hotbar_index = global.inventory_selected_hotbar;
        
        if (global.network_role == NETWORK_ROLE.SERVER && !is_local)
        {
            var _client = global.network_clients[? socket_id];
            if (!is_undefined(_client))
            {
                _inv_target = _client.inventory;
                _hotbar_index = selected_hotbar;
            }
        }
        
        var _item = _inv_target.base[clamp(_hotbar_index, 0, array_length(_inv_target.base) - 1)];
        
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
    
    // Choose physics mode based on debug settings (Apply ONLY to local player)
    if (IS_DEVELOPER_MODE && is_local)
    {
        var _enable_physics = global.dbg_settings[$ "enable_physics"];
        var _noclip = global.dbg_settings[$ "noclip"] ?? false;
        
        if (_noclip)
        {
             // Noclip: Move directly and skip physics step
             var _fly_speed = global.dbg_settings[$ "fly_speed"] ?? 8.65;
             var _dt_scaled = (1 / GAME_TICK) * (global.dbg_settings[$ "time_speed"] ?? 1.0);
             
             x += input_state.move_x * _fly_speed * GAME_TICK * _dt_scaled;
             y += input_state.move_y * _fly_speed * GAME_TICK * _dt_scaled;
             
             physics_body.vel_x = 0;
             physics_body.vel_y = 0;
             physics_body.sync_to_instance(id);
             
             // Update camera/visibility
             control_camera_pos(x - (global.camera_width / 2), y - (global.camera_height / 2), false);
             
             // Update scale for visuals
             if (input_state.move_x != 0) image_xscale = abs(image_xscale) * sign(input_state.move_x);
        }
        else if (!_enable_physics)
        {
            // Creative flight mode (no gravity)
            physics_body.mode = MOVEMENT_MODE.FLY;
        }
    }
    
    if (IS_DEVELOPER_MODE && is_local && (global.dbg_settings[$ "noclip"] ?? false))
    {
        // Skip physics step for noclip
    }
    else
    {
        physics_step(physics_body, input_state);
    }
    physics_body.sync_to_instance(id);
    
    // Post-step debug
    if (global.network_role == NETWORK_ROLE.SERVER && !is_local && input_state.move_x != 0)
    {
        show_debug_message($"[NET-PHYS] Player {uuid} post-step: VelX={physics_body.vel_x}, NewPosX={x}, Grounded={physics_body.collision.ground}");
    }
    
    // --- COMBAT ---
    if !(obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.MENU) && (timer_attack <= 0) && (input_state.attack_held)
    {
        // Stamina Cost
        if (is_local)
        {
            var _stamina_cost = 10;
            if (stamina < _stamina_cost) exit;
            
            stamina -= _stamina_cost;
            stamina_regen_timer = 2.0; // Delay regen after attack
        }
    
        sfx_diegetic_play(audio_emitter, x, y, "phantasia:sfx/item/swing", global.settings.audio_sfx);
        
        statistics_increment("items_used", 1);
        
        timer_attack = 0.3;
        
        var _item = _inv_target.base[_hotbar_index];
        
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
            
            var _changed_slots = (global.network_role == NETWORK_ROLE.SERVER && !is_local) ? [] : undefined;
            
            if (control_entity_shoot(id, _id, x, y - 24, _angle, _inv_target, _changed_slots))
            {
                // Shot something
                if (_changed_slots != undefined && array_length(_changed_slots) > 0)
                {
                    var _client = global.network_clients[? socket_id];
                    if (!is_undefined(_client))
                    {
                        _network_broadcast_inventory_update(_client, "base", _changed_slots);
                    }
                }
            }
            
            // Regular Attack Events
            var _on_attack = _data.get_on_attack();
            var _on_attack_length = _data.get_on_attack_length();
            
            for (var j = 0; j < _on_attack_length; ++j)
            {
                function_execute(_on_attack[j], round(x / TILE_SIZE), round(y / TILE_SIZE), CHUNK_DEPTH_DEFAULT, sign(image_xscale), sign(image_yscale), id, _item);
            }
            
            // Combo Finisher
            if (is_local && combo_count >= 3)
            {
                combo_count = 0;
                
                // Visual feedback for finisher
                global.camera_shake = 5;
                sfx_play("phantasia:sfx/event/lightning", 0.5); // Placeholder SFX
                
                // MULTISHOT SPECIAL (Projectiles)
                // Try to shoot extra projectiles if the weapon shoots
                if (control_entity_shoot(id, _id, x, y - 24, _angle - 15, _inv_target, _changed_slots))
                {
                    // Success left
                }
                if (control_entity_shoot(id, _id, x, y - 24, _angle + 15, _inv_target, _changed_slots))
                {
                    // Success right
                }
                
                // Trigger Double Attack Events as "Special" (Melee/General)
                var _on_special = _data.get_on_item_double_attack();
                var _on_special_length = _data.get_on_item_double_attack_length();
                
                if (_on_special != undefined)
                {
                    for (var j = 0; j < _on_special_length; ++j)
                    {
                        function_execute(_on_special[j], round(x / TILE_SIZE), round(y / TILE_SIZE), CHUNK_DEPTH_DEFAULT, sign(image_xscale), sign(image_yscale), id, _item);
                    }
                }
            }
        }
    }
    
    // --- CONSUMABLES (Eating) ---
    if (input_state.use_held)
    {
        var _item = _inv_target.base[_hotbar_index];
        
        if (_item != INVENTORY_EMPTY)
        {
            var _data = global.item_data[$ _item.get_id()];
            var _item_consumable = _data.get_item_consumable();
            
            if (_item_consumable != undefined)
            {
                var _hp = _item_consumable.get_hp();
                
                if (_hp != undefined && hp < hp_max)
                {
                    var _cooldown = _item_consumable.get_cooldown();
                    var _cooldown_id = (_cooldown != undefined) ? _cooldown.get_id() : undefined;
                    
                    var _can_eat = true;
                    if (_cooldown_id != undefined && variable_instance_exists(obj_Game_Control, "item_cooldown"))
                    {
                        if ((obj_Game_Control.item_cooldown[$ _cooldown_id] ?? 0) > 0) _can_eat = false;
                    }
                    
                    if (_can_eat)
                    {
                        control_entity_heal(id, _hp, id);
                        saturation += _item_consumable.get_saturation();
                        
                        if (_cooldown != undefined)
                        {
                             obj_Game_Control.item_cooldown[$ _cooldown_id] = _cooldown.get_seconds();
                        }
                        
                        var _changed_slots = (global.network_role == NETWORK_ROLE.SERVER && !is_local) ? [] : undefined;
                        inventory_item_decrement("base", _hotbar_index, _inv_target, _changed_slots);
                        
                        if (_changed_slots != undefined && array_length(_changed_slots) > 0)
                        {
                            var _client = global.network_clients[? socket_id];
                            if (!is_undefined(_client)) _network_broadcast_inventory_update(_client, "base", _changed_slots);
                        }
                        
                        if (is_local) obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR | SURFACE_REFRESH_BOOLEAN.HP;
                        
                        var _sfx = _item_consumable.get_sfx();
                        if (_sfx != undefined) sfx_diegetic_play(audio_emitter, x, y, _sfx.get_id(), _sfx.get_gain(), global.settings.audio_sfx);
                    }
                }
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
    if (is_local)
    {
        var _shake_x = 0;
        var _shake_y = 0;
        
        if (global.camera_shake > 0)
        {
            _shake_x = random_range(-global.camera_shake, global.camera_shake);
            _shake_y = random_range(-global.camera_shake, global.camera_shake);
            
            global.camera_shake *= 0.85; // Decay
            if (global.camera_shake < 0.1) global.camera_shake = 0;
        }
        
        control_camera_pos(x - (global.camera_width / 2) + _shake_x, y - (global.camera_height / 2) + _shake_y, false);
    }
    
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
    
    // Chunk visibility - ONLY for local player to prevent remote players from hijacking view center
    if (is_local && (physics_body.vel_x != 0 || physics_body.vel_y != 0))
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