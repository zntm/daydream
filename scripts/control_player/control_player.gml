/// @desc Player control using new physics system
/// @param {Real} _dt Delta time

function control_player()
{
    // Debug entry
    if (global.network_role == RELAY_ROLE.HOST && !is_local) 
    {
        // PRINT($"[NET-PHYS] control_player running for proxy {uuid}, hp={hp}");
    }

    if (hp <= 0) 
    {
        if (global.network_role == RELAY_ROLE.HOST && !is_local) PRINT($"[NET-PHYS] Player {uuid} is DEAD, skipping");
        
        exit;
    }
    

    
    var _x_prev = x;
    var _y_prev = y;
    
    // INPUT
    if (is_local)
    {
        input_state.poll_player();
        selected_hotbar = global.inventory_selected_hotbar;
    }
    
    // Apply aim
    if (input_state.move_x != 0 || input_state.move_y != 0)
    {
        input_state.aim_x = input_state.move_x;
        input_state.aim_y = input_state.move_y;
        input_state.aim_angle = point_direction(0, 0, input_state.aim_x, input_state.aim_y);
    }

    if ((is_local) && (global.network_role == RELAY_ROLE.CLIENT))
    {
        relay_send_player_input({
            tick: current_time,
            move_x: input_state.move_x,
            move_y: input_state.move_y,
            aim_x: input_state.aim_x,
            aim_y: input_state.aim_y,
            jump_held: input_state.jump_held,
            jump_pressed: input_state.jump_pressed,
            attack_held: input_state.attack_held,
            attack_pressed: input_state.attack_pressed,
            use_held: input_state.use_held,
            use_pressed: input_state.use_pressed,
            sprint_held: input_state.sprint_held,
            sprint_pressed: input_state.sprint_pressed,
            selected_hotbar: selected_hotbar
        });
    }
    // Note: Physics should ALWAYS run even with no input (gravity, friction, etc.)
    
    // STAMINA & COMBO
    if (is_local)
    {
        // Stamina
        var _wall_blocked = (input_state.move_x < 0 && physics_body.collision.wall_left)
                          || (input_state.move_x > 0 && physics_body.collision.wall_right);
        var _is_sprinting = input_state.sprint_held && (input_state.move_x != 0) && !_wall_blocked;
        
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
    
    // DOUBLE INPUT
    if !(obj_Game_Control.is_opened & WORLD_OPENED_BOOL.MENU)
    {
        var _inv_target = global.inventory;
        var _hotbar_index = global.inventory_selected_hotbar;
        
        if (global.network_role == RELAY_ROLE.HOST && !is_local)
        {
            var _peer = obj_Game_Control.relay_manager._find_peer_by_instance(id);
            if (_peer != undefined)
            {
                _inv_target = _peer.inventory;
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
                        for (var j = _on_event_length - 1; j >= 0; --j)
                        {
                            function_execute(_on_event[j], x, y, CHUNK_DEPTH_DEFAULT, sign(image_xscale), sign(image_yscale), id, _item);
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
                        for (var j = _on_event_length - 1; j >= 0; --j)
                        {
                            function_execute(_on_event[j], x, y, CHUNK_DEPTH_DEFAULT, sign(image_xscale), sign(image_yscale), id, _item);
                        }
                    }
                }
                
                if (input_state.move_left_double_pressed) || (input_state.move_right_double_pressed) || (input_state.move_up_double_pressed) || (input_state.move_down_double_pressed)
                {
                    var _on_event = _data.get_on_item_double_move();
                    var _on_event_length = _data.get_on_item_double_move_length();
                    
                    if (_on_event != undefined)
                    {
                        for (var j = _on_event_length - 1; j >= 0; --j)
                        {
                            function_execute(_on_event[j], x, y, CHUNK_DEPTH_DEFAULT, sign(image_xscale), sign(image_yscale), id, _item);
                        }
                    }
                }
            }
        }
        
        // ARMOR ON_DOUBLE_HORIZONTAL_MOVE
        if (input_state.move_left_double_pressed || input_state.move_right_double_pressed)
        {
            // Determine dash direction from input
            var _dash_dir = input_state.move_left_double_pressed ? -1 : 1;
            
            // Check equipped armor and accessories for on_double_horizontal_move
            var _armor_slots = array_concat([_inv_target.armor_helmet[0], _inv_target.armor_breastplate[0], _inv_target.armor_leggings[0]], _inv_target.accessory);
            
            for (var k = array_length(_armor_slots) - 1; k >= 0; --k)
            {
                var _armor_item = _armor_slots[k];
                if (_armor_item == INVENTORY_EMPTY) continue;
                
                var _armor_id = _armor_item.get_id();
                var _armor_data = global.item_data[$ _armor_id];
                if (_armor_data == undefined) continue;
                
                var _item_armor = _armor_data.get_item_armor();
                if (_item_armor == undefined) continue;
                
                var _on_double_horizontal_move = _item_armor.get_on_double_horizontal_move();
                if (_on_double_horizontal_move != undefined)
                {
                    PRINT($"[Control] Armor Dash Triggered: {_on_double_horizontal_move.id}");
                    function_execute(_on_double_horizontal_move, x, y, CHUNK_DEPTH_DEFAULT, _dash_dir, sign(image_yscale), id, _armor_item);
                }
            }
        }
        
        // ARMOR ON_DOUBLE_VERTICAL_MOVE
        if (input_state.move_up_double_pressed || input_state.move_down_double_pressed)
        {
            // Determine vertical dash direction from input
            var _dash_dir_v = input_state.move_up_double_pressed ? -1 : 1;
            
            // Check equipped armor and accessories for on_double_vertical_move
            var _armor_slots = array_concat([_inv_target.armor_helmet[0], _inv_target.armor_breastplate[0], _inv_target.armor_leggings[0]], _inv_target.accessory);
            
            for (var k = array_length(_armor_slots) - 1; k >= 0; --k)
            {
                var _armor_item = _armor_slots[k];
                if (_armor_item == INVENTORY_EMPTY) continue;
                
                var _armor_id = _armor_item.get_id();
                var _armor_data = global.item_data[$ _armor_id];
                if (_armor_data == undefined) continue;
                
                var _item_armor = _armor_data.get_item_armor();
                if (_item_armor == undefined) continue;
                
                var _on_double_vertical_move = _item_armor.get_on_double_vertical_move();
                if (_on_double_vertical_move != undefined)
                {
                    // Pass vertical direction in yscale (?) or a specific parameter?
                    // For now, passing 0 as xscale and direction as yscale to indicate vertical movement
                    function_execute(_on_double_vertical_move, x, y, CHUNK_DEPTH_DEFAULT, sign(image_xscale), _dash_dir_v, id, _armor_item);
                }
            }
        }
    }
    
    // DAMAGE CHECK
    if (timer_immunity <= 0)
    {
        var _inst = instance_place(x, y, obj_Creature);
        
        if (instance_exists(_inst))
        {
            var _data = global.creature_data[$ _inst._id];
            
            if (_data.get_hostility_type() == CREATURE_HOSTILITY_TYPE.HOSTILE)
            {
                var _died = control_entity_damage(id, _inst, _data.get_contact_damage());
                
                obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOL.HP;
                
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
    
    // AUDIO
    audio_listener_position(x, y, 0);
    
    // PHYSICS
    physics_body.sync_from_instance(id);
    global.spatial_grid.update(physics_body);
    entity_update_collision(physics_body);
    
    // Choose physics mode based on debug settings (Apply ONLY to local player)
    if (IS_DEVELOPER_MODE && is_local)
    {
        var _enable_physics = global.dbg_settings[$ "enable_physics"];
        var _noclip         = global.dbg_settings[$ "noclip"] ?? false;
        
        if (_noclip)
        {
            /* Noclip: Move directly and skip physics step */
            var _fly_speed = global.dbg_settings[$ "fly_speed"] ?? 8.65;
            var _dt_scaled = (1 / GAME_TICK) * (global.dbg_settings[$ "time_speed"] ?? 1.0);
            
            physics_body.pos_x += input_state.move_x * _fly_speed * GAME_TICK * _dt_scaled;
            physics_body.pos_y += input_state.move_y * _fly_speed * GAME_TICK * _dt_scaled;
            
            physics_body.vel_x = 0;
            physics_body.vel_y = 0;
            
            /* Update scale for visuals */
            if (input_state.move_x != 0)
            {
                image_xscale = abs(image_xscale) * sign(input_state.move_x);
            }
        }
        else if (!_enable_physics)
        {
            /* Creative flight mode (no gravity) */
            physics_body.attribute[$ "___can_fly"]   = true;
            physics_body.attribute[$ "___fly_speed"] = global.dbg_settings[$ "fly_speed"] ?? 8.65;
            physics_body.mode                        = MOVEMENT_MODE.FLY;
        }
        else
        {
            /* Revert fly properties if physics enabled back */
            if (physics_body.attribute != undefined)
            {
                if (struct_exists(physics_body.attribute, "___can_fly"))
                {
                    struct_remove(physics_body.attribute, "___can_fly");
                }
                
                if (struct_exists(physics_body.attribute, "___fly_speed"))
                {
                    struct_remove(physics_body.attribute, "___fly_speed");
                }
            }
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
    if (global.network_role == RELAY_ROLE.HOST && !is_local && input_state.move_x != 0)
    {
        PRINT($"[NET-PHYS] Player {uuid} post-step: VelX={physics_body.vel_x}, NewPosX={x}, Grounded={physics_body.collision.ground}");
    }
    
    // COMBAT & SKILLS
    var _item = _inv_target.base[_hotbar_index];
    var _skill = undefined;
    var _id = "";
    var _data = undefined;
    
    if (_item != INVENTORY_EMPTY)
    {
        _id = _item.get_id();
        _data = global.item_data[$ _id];
        _skill = _data.get_item_skill();
    }
    
    // Update Charge Logic (Local Player Only)
    if (is_local && _skill != undefined && _skill.type == "charge")
    {
        if (input_state.attack_held && !(obj_Game_Control.is_opened & WORLD_OPENED_BOOL.MENU))
        {
            charge_time += 1 / GAME_TICK;
            
            if (_data.get_hold_type() == ITEM_HOLD_TYPE.LAUNCHER)
            {
                charge_threshold = _skill.threshold;
            }
            
            // Visual feedback for charging
            var _t = clamp(charge_time / _skill.threshold, 0, 1);
            if (chance(0.3 * _t))
            {
                spawn_particle(x + random_range(-8, 8), y - 10 + random_range(-8, 8), "phantasia:entity/glow");
            }
            if (_t >= 1 && chance(0.5))
            {
                spawn_particle(x + random_range(-12, 12), y - 20 + random_range(-12, 12), "phantasia:entity/glow_ready");
            }
            
            // Ensure tool visual exists while charging
            if (!instance_exists(inst_item))
            {
                inst_item = instance_create_layer(x, y, "Instances", obj_Tool);
                inst_item._id = _id;
                inst_item.sprite_index = global.sprite_asset[$ _data.get_sprite()].get_sprite();
                inst_item.image_index = _data.get_inventory_index();
                inst_item.image_speed = 0;
                inst_item.inst_owner = id;
                inst_item.hold_type = _data.get_hold_type();
            }
            
            // Set attack timer to keep tool alive
            timer_attack = 0.1; 
        }
        else if (charge_time > 0)
        {
            // Release Charge (Early release supported for Launchers)
            var _threshold = _skill.threshold;
            var _is_launcher = (_data.get_hold_type() == ITEM_HOLD_TYPE.LAUNCHER);
            var _can_trigger = (charge_time >= _threshold) || (_is_launcher && charge_time > 0);
            
            if (_can_trigger)
            {
                var _stamina_cost = _skill.stamina_cost;
                if (stamina >= _stamina_cost)
                {
                    stamina -= _stamina_cost;
                    stamina_regen_timer = 2.0;
                    
                    // Trigger Skill effects
                    if (charge_time >= _threshold)
                    {
                        global.camera_shake = 5;
                        sfx_environmental_play("phantasia:sfx/event/lightning", 0.7, x, y, obj_Player); 
                    }
                    
                    var _on_trigger = _skill.on_trigger ?? _data.get_on_item_double_attack();
                    var _on_trigger_length = _skill.on_trigger_length ?? _data.get_on_item_double_attack_length();
                    
                    if (_on_trigger != undefined)
                    {
                        for (var j = _on_trigger_length - 1; j >= 0; --j)
                        {
                            function_execute(_on_trigger[j], x, y, CHUNK_DEPTH_DEFAULT, sign(image_xscale), sign(image_yscale), id, _item);
                        }
                    }
                    
                    // Launcher Shoot logic with power scaling
                    if (_is_launcher)
                    {
                        var _angle = input_state.aim_angle;
                        var _changed_slots = (global.network_role == RELAY_ROLE.HOST && !is_local) ? [] : undefined;
                        var _power = clamp(charge_time / _threshold, 0.1, 1.0);
                        
                        if (control_entity_shoot(id, _id, x, y - 20, _angle, _inv_target, _changed_slots, _power))
                        {
                            timer_attack = _data.get_item_cooldown();
                            
                            if (_changed_slots != undefined && array_length(_changed_slots) > 0)
                            {
                                var _peer = obj_Game_Control.relay_manager._find_peer_by_instance(id);
                                if (_peer != undefined)
                                {
                                    for (var i = 0; i < array_length(_changed_slots); ++i)
                                    {
                                        var _slot = _changed_slots[i];
                                        relay_send_inventory_update(_peer.peer_id, "base", _slot, _inv_target.base[_slot]);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            charge_time = 0;
        }
    }
    
    // Fallback charging for non-skill launchers or early release support
    if (is_local && _skill == undefined && _data != undefined && _data.get_hold_type() == ITEM_HOLD_TYPE.LAUNCHER)
    {
        if (input_state.attack_held && !(obj_Game_Control.is_opened & WORLD_OPENED_BOOL.MENU))
        {
            charge_time += 1 / GAME_TICK;
            charge_threshold = 0.5; // Default threshold
            
        }
        else if (charge_time > 0)
        {
            // Release logic for non-skill launchers
            var _angle = input_state.aim_angle;
            var _changed_slots = undefined;
            var _power = clamp(charge_time / 0.5, 0.1, 1.0);
            
            if (control_entity_shoot(id, _id, x, y - 20, _angle, _inv_target, _changed_slots, _power))
            {
                timer_attack = _data.get_item_cooldown();
            }
            charge_time = 0;
        }
    }

    var _can_swing = (timer_attack <= 0) && (input_state.attack_held);
    // For charge skills, only allow the initial swing or very slow repeat (optional, let's just do initial)
    if (_skill != undefined && _skill.type == "charge" && charge_time > 0.1) _can_swing = false;
    // For launchers, don't allow regular swinging if we are charging
    if (_data != undefined && _data.get_hold_type() == ITEM_HOLD_TYPE.LAUNCHER && charge_time > 0) _can_swing = false;

    if !(obj_Game_Control.is_opened & WORLD_OPENED_BOOL.MENU) && _can_swing
    {
        // Regular swings are now free, but delay regen
        if (is_local)
        {
            stamina_regen_timer = 1.0; 
        }
    
        sfx_diegetic_play(audio_emitter, x, y, "phantasia:sfx/item/swing", global.settings.audio_sfx);
        
        statistics_increment("items_used", 1);
        
        timer_attack = 0.3;
        
        if (_item != INVENTORY_EMPTY)
        {
            statistics_increment($"items_used_{_id}", 1);
            
            if (!instance_exists(inst_item))
            {
                inst_item = instance_create_layer(x, y, "Instances", obj_Tool);
                inst_item._id = _id;
                inst_item.sprite_index = global.sprite_asset[$ _data.get_sprite()].get_sprite();
                inst_item.image_index = _data.get_inventory_index();
                inst_item.image_speed = 0;
                inst_item.inst_owner = id;
                
                inst_item.hold_type = _data.get_hold_type();
                
                if (inst_item.hold_type == ITEM_HOLD_TYPE.WHIP)
                {
                    inst_item.whip_segments = _data.get_hold_whip_segments();
                }
            }
            
            // Shooting logic
            if (inst_item.hold_type != ITEM_HOLD_TYPE.LAUNCHER)
            {
                var _angle = input_state.aim_angle;
                
                var _changed_slots = (global.network_role == RELAY_ROLE.HOST && !is_local) ? [] : undefined;
                
                if (control_entity_shoot(id, _id, x, y - 20, _angle, _inv_target, _changed_slots))
                {
                    // Shot something...
                    timer_attack = _data.get_item_cooldown();
                    
                    if (_changed_slots != undefined && array_length(_changed_slots) > 0)
                    {
                        var _peer = obj_Game_Control.relay_manager._find_peer_by_instance(id);
                        if (_peer != undefined)
                        {
                            for (var i = 0; i < array_length(_changed_slots); ++i)
                            {
                                var _slot = _changed_slots[i];
                                relay_send_inventory_update(_peer.peer_id, "base", _slot, _inv_target.base[_slot]);
                            }
                        }
                    }
                }
            }
            
            var _on_attack = _data.get_on_attack();
            
            if (_on_attack != undefined)
            {
                var _tx = round(x / TILE_SIZE);
                var _ty = round(y / TILE_SIZE);
                
                var _on_attack_length = _data.get_on_attack_length();
                
                for (var j = _on_attack_length - 1; j >= 0; --j)
                {
                    function_execute(_on_attack[j], _tx, _ty, CHUNK_DEPTH_DEFAULT, sign(image_xscale), sign(image_yscale), id, _item);
                }
            }
            
            // Combo Skill logic
            if (is_local && _skill != undefined && _skill.type == "combo")
            {
                // Visual feedback for "charging up" combo
                var _threshold = _skill.threshold;
                if (combo_count > 0 && combo_count < _threshold)
                {
                    if (chance(0.2 * (combo_count / _threshold)))
                    {
                        spawn_particle(x + random_range(-8, 8), y - 12 + random_range(-8, 8), "phantasia:entity/glow");
                    }
                }
                else if (combo_count >= _threshold)
                {
                    if (chance(0.5))
                    {
                        spawn_particle(x + random_range(-12, 12), y - 20 + random_range(-12, 12), "phantasia:entity/glow_ready");
                    }
                }
                
                // Trigger Combo Skill
                if (combo_count >= _threshold)
                {
                    var _stamina_cost = _skill.stamina_cost;
                    if (stamina >= _stamina_cost)
                    {
                        stamina -= _stamina_cost;
                        stamina_regen_timer = 2.0; 
                        
                        combo_count = 0;
                        
                        // Visual feedback for finisher
                        global.camera_shake = 5;
                        sfx_environmental_play("phantasia:sfx/event/lightning", 0.7, x, y, obj_Player); 
                        
                        // MULTISHOT SPECIAL (Projectiles)
                        if (control_entity_shoot(id, _id, x, y - 20, _angle - 15, _inv_target, _changed_slots)) {}
                        if (control_entity_shoot(id, _id, x, y - 20, _angle + 15, _inv_target, _changed_slots)) {}
                        
                        var _on_trigger = _skill.on_trigger ?? _data.get_on_item_double_attack();
                        var _on_trigger_length = _skill.on_trigger_length ?? _data.get_on_item_double_attack_length();
                        
                        if (_on_trigger != undefined)
                        {
                            for (var j = _on_trigger_length - 1; j >= 0; --j)
                            {
                                function_execute(_on_trigger[j], x, y, CHUNK_DEPTH_DEFAULT, sign(image_xscale), sign(image_yscale), id, _item);
                            }
                        }
                    }
                }
            }
        }
    }
    
    // CONSUMABLES (Eating)
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
                        
                        var _changed_slots = (global.network_role == RELAY_ROLE.HOST && !is_local) ? [] : undefined;
                        inventory_item_decrement("base", _hotbar_index, _inv_target, _changed_slots);
                        
                        if (_changed_slots != undefined && array_length(_changed_slots) > 0)
                        {
                            var _peer = obj_Game_Control.relay_manager._find_peer_by_instance(id);
                            if (_peer != undefined)
                            {
                                for (var i = 0; i < array_length(_changed_slots); ++i)
                                {
                                    var _slot = _changed_slots[i];
                                    relay_send_inventory_update(_peer.peer_id, "base", _slot, _inv_target.base[_slot]);
                                }
                            }
                        }
                        
                        if (is_local) obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOL.INVENTORY_HOTBAR | SURFACE_REFRESH_BOOL.HP;
                        
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
        var _id = inst_item._id;
        var _data = global.item_data[$ _id];
        var _hold_type = _data.get_hold_type();
        
        // Default Swing Logic (Refactored into case)
        if (_hold_type == ITEM_HOLD_TYPE.SWING)
        {
            var _t = power((0.3 - timer_attack) / 0.3, 1 / 4);
            var _angle = (45 * cos(_t * pi)) + 15;
            
            with (inst_item)
            {
                var _sprite_width = sprite_get_width(sprite_index);
                var _sprite_height = sprite_get_height(sprite_index);
                
                image_yscale = _direction;
                
                x = other.x + (lengthdir_x(_sprite_width, _angle) * _direction);
                y = other.y - 20 + (lengthdir_y(_sprite_height, _angle));
                
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
        else if (_hold_type == ITEM_HOLD_TYPE.LAUNCHER)
        {
             var _aim_angle = input_state.aim_angle;
             var _recoil = 0;
             
             // Charge pull-back animation (while holding)
             if (charge_time > 0 && charge_threshold > 0)
             {
                 var _t_charge = clamp(charge_time / charge_threshold, 0, 1);
                 _recoil = _t_charge * 6; // Pull back up to 6 pixels while charging
             }
             // Fire recoil animation (after releasing)
             else if (timer_attack > 0.2) // Just fired (0.3 to 0.2)
             {
                 var _t_recoil = (timer_attack - 0.2) / 0.1; // 0 to 1
                 _recoil = sin(_t_recoil * pi) * 4; // Kick back 4 pixels
             }
             
             with (inst_item)
             {
                 var _dist = 12 - _recoil;
                 
                 x = other.x + lengthdir_x(_dist, _aim_angle);
                 y = other.y - 20 + lengthdir_y(_dist, _aim_angle);
                 
                 image_angle = _aim_angle;
                 image_yscale = 1; 
                 if (_aim_angle > 90 && _aim_angle < 270) image_yscale = -1;
             }
        }
        else if (_hold_type == ITEM_HOLD_TYPE.SPEAR)
        {
             var _aim_angle = input_state.aim_angle;
             var _t = 0;
             
             if (timer_attack > 0)
             {
                 // Poke out and in
                 // 0.3 total time. 
                 // 0.3 -> 0.15: Extend
                 // 0.15 -> 0.0: Retract
                 
                 if (timer_attack > 0.15)
                 {
                     _t = (0.3 - timer_attack) / 0.15; // 0 to 1
                 }
                 else
                 {
                     _t = timer_attack / 0.15; // 1 to 0
                 }
             }
             
             var _dist = 8 + (_t * 24); // 8 base, +24 extend
             
             with (inst_item)
             {
                 x = other.x + lengthdir_x(_dist, _aim_angle);
                 y = other.y - 24 + lengthdir_y(_dist, _aim_angle);
                 image_angle = _aim_angle; 
                 if (_aim_angle > 90 && _aim_angle < 270) image_yscale = -1; 
             }
        }
        else if (_hold_type == ITEM_HOLD_TYPE.WHIP)
        {
             // Whip logic is mostly in Draw event, but we position the handle here
             var _aim_angle = input_state.aim_angle;
             
             with (inst_item)
             {
                 var _dist = 8;
                 x = other.x + lengthdir_x(_dist, _aim_angle);
                 y = other.y - 24 + lengthdir_y(_dist, _aim_angle);
                 image_angle = _aim_angle;
                 if (_aim_angle > 90 && _aim_angle < 270) image_yscale = -1; 
             }
        }
    }
    
    // FALL DAMAGE
    /*
    if (y > y_last)
    {
        if (physics_body.collision.ground)
        {
            var _difference = max(0, y - y_last - (TILE_SIZE * 8));
            var _value = floor(power(floor(_difference / TILE_SIZE) * 0.62, 1.25));
            
            if (_value > 0 && !attribute.has_boolean(ATTRIBUTE_BOOL.IS_FALL_DAMAGE_RESISTANT))
            {
                obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOL.HP;
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
    
    // POST-PHYSICS
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
    if (attribute.has_boolean(ATTRIBUTE_BOOL.HAS_REGENERATION))
    {
        _is_regenerated = control_entity_regeneration(1 / GAME_TICK);
    }
    
    control_entity_effect();
    
    if (_is_regenerated)
    {
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOL.HP;
    }
    
    // Chunk visibility - ONLY for local player to prevent remote players from hijacking view center
    if (is_local && (physics_body.vel_x != 0 || physics_body.vel_y != 0))
    {
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOL.LIGHTING;
        
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

    player_update_breath();
    control_entity_suffocation(id);
}

/// @desc Reset player charge state and UI.
function player_reset_charge()
{
    charge_time = 0;
}

/// @desc Update player breathing and drowning while underwater.
function player_update_breath()
{
    var _eye_y = y - ((attribute.get_collision_box_height() - attribute.get_eye_level()) * entity_yscale);
    var _tile_x = floor(x / TILE_SIZE);
    var _tile_y = floor(_eye_y / TILE_SIZE);
    var _tile = tile_get(_tile_x, _tile_y, CHUNK_DEPTH_LIQUID);
    var _underwater = false;

    if (_tile != TILE_EMPTY)
    {
        var _data = global.item_data[$ _tile.get_id()];
        _underwater = (_data != undefined) && _data.is_liquid();
    }

    if (_underwater)
    {
        breath = max(0, breath - (1 / GAME_TICK));

        if (breath <= 0)
        {
            timer_drown += 1 / GAME_TICK;

            if (timer_drown >= 1.0)
            {
                timer_drown -= 1.0;
                control_entity_damage(id, noone, 2, 0, 0, 1);

                if (is_local)
                {
                    obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOL.HP;
                }
            }
        }
        else
        {
            timer_drown = 0;
        }
    }
    else
    {
        breath = min(breath_max, breath + (breath_recovery_rate / GAME_TICK));
        timer_drown = 0;
    }
}
