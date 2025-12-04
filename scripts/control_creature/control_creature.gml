// AI States for creature behavior
enum CREATURE_AI_STATE {
    IDLE,
    WANDER,
    CHASE,
    FLEE,
    ATTACK
}

// Constants for AI behavior
#macro AI_DECISION_INTERVAL 0.15        // How often to make AI decisions (in seconds)
#macro AI_HOSTILE_RANGE (TILE_SIZE * 16)  // Detection range for hostile creatures
#macro AI_FLEE_RANGE (TILE_SIZE * 12)     // Range at which passive creatures flee
#macro AI_WANDER_DURATION 2.0             // How long to wander in one direction
#macro AI_IDLE_DURATION 1.5               // How long to stay idle
#macro AI_ATTACK_COOLDOWN 1.0             // Cooldown between attacks
#macro AI_LOW_HEALTH_THRESHOLD 0.3        // Health % to trigger retreat behavior

function control_creature(_dt)
{
    var _data = global.creature_data[$ _id];
    
    // Initialize AI state on first run
    if (!variable_instance_exists(id, "ai_state"))
    {
        ai_state = CREATURE_AI_STATE.IDLE;
        ai_decision_timer = 0;
        ai_state_timer = 0;
        ai_target_direction = 0;
        ai_cached_on_ground = false;
        ai_cached_collision_width = attribute.get_collision_box_width();
        ai_cached_collision_height = attribute.get_collision_box_height();
    }
    
    // Update timers
    var _dt_normalized = _dt / GAME_TICK;
    ai_decision_timer -= _dt_normalized;
    ai_state_timer -= _dt_normalized;
    
    // Handle damage and immunity
    if (timer_immunity <= 0)
    {
        var _inst = instance_place(x, y, obj_Tool);
        
        if (instance_exists(_inst))
        {
            var _base_damage = global.item_data[$ _inst._id].get_item_damage();
            
            // Use unified damage handler with 0.1 variance (matches the 0.9-1.1 range)
            var _died = control_entity_damage(id, _inst.inst_owner, _base_damage, 0.1);
            
            if (_died)
            {
                exit;
            }
            
            inst_predator = _inst.inst_owner;
            
            // Use unified knockback handler
            control_entity_knockback(id, _inst);
            
            // Transition to flee state if passive, or attack state if hostile
            if (_data.get_hostility_type() == CREATURE_HOSTILITY_TYPE.PASSIVE)
            {
                ai_state = CREATURE_AI_STATE.FLEE;
                ai_state_timer = 2.0;
            }
        }
    }
    
    if (timer_immunity > 0)
    {
        timer_immunity = max(0, timer_immunity - _dt_normalized);
        
        if (timer_immunity <= 0)
        {
            inst_predator = noone;
        }
    }
    
    // Cache ground state
    ai_cached_on_ground = tile_meeting(x, y + 1);
    
    // Find nearest target
    var _target = instance_nearest(x, y, obj_Player);
    var _distance_to_target = point_distance(x, y, _target.x, _target.y);
    var _hostility_type = _data.get_hostility_type();
    
    // AI Decision Making - only update at intervals for performance
    if (ai_decision_timer <= 0)
    {
        ai_decision_timer = AI_DECISION_INTERVAL;
        
        // State transitions based on hostility type
        if (_hostility_type == CREATURE_HOSTILITY_TYPE.HOSTILE)
        {
            var _health_ratio = hp / hp_max;
            
            // Check if we should chase the player
            if (_distance_to_target <= AI_HOSTILE_RANGE)
            {
                if (_health_ratio < AI_LOW_HEALTH_THRESHOLD)
                {
                    // Low health - flee
                    ai_state = CREATURE_AI_STATE.FLEE;
                    ai_state_timer = 2.0;
                    ai_target_direction = sign(x - _target.x);
                }
                else
                {
                    // Chase the player
                    ai_state = CREATURE_AI_STATE.CHASE;
                    ai_target_direction = sign(_target.x - x);
                }
            }
            else
            {
                // Too far from player - wander or idle
                if (ai_state == CREATURE_AI_STATE.CHASE)
                {
                    // Lost sight of player, go idle
                    ai_state = CREATURE_AI_STATE.IDLE;
                    ai_state_timer = AI_IDLE_DURATION;
                }
                else if (ai_state_timer <= 0)
                {
                    // Switch between idle and wander
                    if (ai_state == CREATURE_AI_STATE.IDLE)
                    {
                        ai_state = CREATURE_AI_STATE.WANDER;
                        ai_state_timer = AI_WANDER_DURATION;
                        ai_target_direction = choose(-1, 1);
                    }
                    else
                    {
                        ai_state = CREATURE_AI_STATE.IDLE;
                        ai_state_timer = AI_IDLE_DURATION;
                        ai_target_direction = 0;
                    }
                }
            }
        }
        else // PASSIVE
        {
            // Check if we should flee from player or predator
            if (timer_immunity > 0 && instance_exists(inst_predator))
            {
                ai_state = CREATURE_AI_STATE.FLEE;
                ai_target_direction = sign(x - inst_predator.x);
            }
            else if (_distance_to_target <= AI_FLEE_RANGE)
            {
                ai_state = CREATURE_AI_STATE.FLEE;
                ai_target_direction = sign(x - _target.x);
                ai_state_timer = 1.5;
            }
            else if (ai_state == CREATURE_AI_STATE.FLEE && ai_state_timer <= 0)
            {
                // Done fleeing, go idle
                ai_state = CREATURE_AI_STATE.IDLE;
                ai_state_timer = AI_IDLE_DURATION;
            }
            else if (ai_state_timer <= 0)
            {
                // Switch between idle and wander
                if (ai_state == CREATURE_AI_STATE.IDLE)
                {
                    ai_state = CREATURE_AI_STATE.WANDER;
                    ai_state_timer = AI_WANDER_DURATION;
                    ai_target_direction = choose(-1, 1);
                }
                else
                {
                    ai_state = CREATURE_AI_STATE.IDLE;
                    ai_state_timer = AI_IDLE_DURATION;
                    ai_target_direction = 0;
                }
            }
        }
    }
    
    // Apply movement based on current state
    input_left = false;
    input_right = false;
    
    if (ai_target_direction != 0)
    {
        if (ai_target_direction > 0)
        {
            input_right = true;
        }
        else
        {
            input_left = true;
        }
        
        image_xscale = abs(image_xscale) * ai_target_direction;
        
        // Smart jumping - check if we need to jump over obstacles
        if (!input_jump && ai_cached_on_ground)
        {
            var _xto = x + (ai_target_direction * ai_cached_collision_width);
            
            // Check if there's a wall ahead and ground to land on
            if (tile_meeting(_xto, y - 1))
            {
                var _fall_dist = entity_ai_fall_detection(_xto, y - (TILE_SIZE * 2), -ai_cached_collision_height, 2);
                
                if (_fall_dist >= 2)
                {
                    input_jump = true;
                    input_jump_pressed = true;
                }
            }
            // For chase state, also jump if target is above us
            else if (ai_state == CREATURE_AI_STATE.CHASE && _target.y < y)
            {
                var _fall_dist = entity_ai_fall_detection(_xto, y - (TILE_SIZE * 2), -ai_cached_collision_height, 2);
                
                if (_fall_dist >= 2)
                {
                    input_jump = true;
                    input_jump_pressed = true;
                }
            }
            // Edge detection - avoid walking off cliffs when wandering
            else if (ai_state == CREATURE_AI_STATE.WANDER)
            {
                var _fall_dist = entity_ai_fall_detection(_xto, y + TILE_SIZE, TILE_SIZE, 4);
                
                // If there's a big drop ahead, turn around
                if (_fall_dist >= 4)
                {
                    ai_target_direction *= -1;
                    ai_state_timer = AI_WANDER_DURATION; // Reset wander timer
                }
            }
        }
    }
    
    // Physics
    control_physics_input(_dt, id, ((timer_panic > 0) ? 1.5 : 1));
    control_physics(_dt, id);
    
    // Fall damage
    if (y > ylast)
    {
        if (!ai_cached_on_ground && tile_meeting(x, y + 1))
        {
            var _difference = max(0, y - ylast - (TILE_SIZE * 4));
            var _value = floor(power(floor(_difference / TILE_SIZE) * 0.62, 1.25));
            
            if (_value > 0)
            {
                hp -= _value;
                ylast = y;
                
                repeat (irandom_range(2, 6))
                {
                    spawn_particle(random_range(bbox_left, bbox_right), random_range(bbox_top, bbox_bottom), "phantasia:entity/damage");
                }
                
                spawn_floating_text(x, y, _value, 0, -3.9);
                
                if (hp <= 0)
                {
                    instance_destroy();
                    exit;
                }
            }
        }
    }
    else
    {
        ylast = y;
    }
    
    control_entity_sfx(_dt);
    control_physics_input_after(_dt, id);
    
    if (attribute.has_boolean(ATTRIBUTE_BOOLEAN.HAS_REGENERATION))
    {
        control_entity_regeneration(_dt_normalized);
    }
    
    // Reset jump input after a delay
    if (input_jump && chance(0.4 * _dt))
    {
        input_jump = false;
        input_jump_pressed = false;
    }
}