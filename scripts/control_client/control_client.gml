/// @desc Control logic for obj_Client (Remote Players)
/// @param {Real} _dt Delta time

function control_client()
{
    if (hp <= 0) 
    {
        if (global.network_role == NETWORK_ROLE.SERVER) show_debug_message($"[NET-PHYS] Client {uuid} is DEAD, skipping");
        exit;
    }
    
    // --- CLIENT SIDE: REMOTES (INTERPOLATION) ---
    if (global.network_role == NETWORK_ROLE.CLIENT)
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
        
        // Update input state for animation
        if (variable_instance_exists(self, "network_input") && network_input != undefined)
        {
            input_state.attack_held = network_input.attack_held;
            input_state.use_held = network_input.use_held;
            
            // Trigger swing animation if attacking
            if (input_state.attack_held && timer_attack <= 0)
            {
                timer_attack = 0.3; 
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
        
        // Audio Listener: NOT for remote players
        // Camera: NOT for remote players
        
        exit; // End client logic
    }
    
    // --- SERVER SIDE: PHYSICS ---
    if (global.network_role == NETWORK_ROLE.SERVER)
    {
        var _x_prev = x;
        var _y_prev = y;
        
        // Ensure valid physics mode (default to GROUND if None/Undefined)
        if (physics_body.mode == MOVEMENT_MODE.NONE || physics_body.mode == undefined)
        {
            physics_body.mode = MOVEMENT_MODE.GROUND;
        }
        
        // Input from Network
        if (network_input != undefined)
        {
            // Debug Input
            if (network_input.move_x != 0 || network_input.move_y != 0) 
            {
                // show_debug_message($"[NET-PHYS] Client {uuid} Input: X={network_input.move_x}, Y={network_input.move_y}");
            }
            
            input_state.move_x = network_input.move_x;
            input_state.move_y = network_input.move_y;
            input_state.jump_held      = network_input.jump_held;
            input_state.jump_pressed   = network_input.jump_pressed;
            input_state.attack_held    = network_input.attack_held;
            input_state.attack_pressed = network_input.attack_pressed;
            input_state.use_held       = network_input.use_held;
            input_state.use_pressed    = network_input.use_pressed;
            
            // Aim direction
            if (input_state.move_x != 0 || input_state.move_y != 0)
            {
                input_state.aim_x = input_state.move_x;
                input_state.aim_y = input_state.move_y;
                input_state.aim_angle = point_direction(0, 0, input_state.aim_x, input_state.aim_y);
            }
        }
        else
        {
             // Clear inputs if no network input processing (safety)
             input_state.move_x = 0;
             input_state.move_y = 0;
        }
        
        // Combat / Damage / Interaction Logic
        // (Simplified for now - can copy full logic if needed, but primary goal is movement first)
        
        // Physics
        physics_body.sync_from_instance(id);
        global.spatial_grid.update(physics_body);
        entity_update_collision(physics_body);
        
        physics_step(physics_body, input_state);
        
        physics_body.sync_to_instance(id);
        
        // Action Timers
        if (timer_attack > 0) timer_attack = max(0, timer_attack - (1 / GAME_TICK));
        if (timer_immunity > 0) timer_immunity = max(0, timer_immunity - (1 / GAME_TICK));
        
        // Logic for attack/use interaction could be added here similar to control_player
        
         // Face movement direction
        if (input_state.move_x != 0)
        {
            image_xscale = abs(image_xscale) * sign(input_state.move_x);
        }
        
        // Suffocation check
        control_entity_suffocation(id);
    }
}
