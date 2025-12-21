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
#macro AI_ATTACK_RANGE (TILE_SIZE * 1.5)  // Melee attack range
#macro AI_HUNT_RANGE (TILE_SIZE * 8)      // Range to detect prey
#macro AI_STUCK_CHECK_INTERVAL 0.5        // How often to check if stuck
#macro AI_STUCK_THRESHOLD 4.0             // Pixel movement threshold to consider moving

function control_creature(_dt)
{
    var _data = global.creature_data[$ _id];
    var _dt_normalized = _dt / GAME_TICK;
    
    // --- TIMERS ---
    ai_decision_timer -= _dt_normalized;
    ai_state_timer -= _dt_normalized;
    ai_stuck_timer -= _dt_normalized;
    
    if (attack_cooldown > 0) attack_cooldown -= _dt_normalized;
    
    // --- DAMAGE & IMMUNITY ---
    if (timer_immunity <= 0)
    {
        var _inst = instance_place(x, y, obj_Tool);
        
        if (instance_exists(_inst))
        {
            var _base_damage = global.item_data[$ _inst._id].get_item_damage();
            
            var _died = control_entity_damage(id, _inst.inst_owner, _base_damage, 0.1);
            
            if (_died) exit;
            
            inst_predator = _inst.inst_owner;
            control_entity_knockback(id, _inst);
            
            // Flee or Attack based on hostility
            if (_data.get_hostility_type() == CREATURE_HOSTILITY_TYPE.PASSIVE)
            {
                ai_state = CREATURE_AI_STATE.FLEE;
                ai_state_timer = 2.0;
            }
        }
    }
    else
    {
        timer_immunity = max(0, timer_immunity - _dt_normalized);
        if (timer_immunity <= 0) inst_predator = noone;
    }
    
    // --- SENSORS ---
    ai_cached_on_ground = tile_meeting(x, y + 1);
    var _target = instance_nearest(x, y, obj_Player);
    var _distance_to_target = point_distance(x, y, _target.x, _target.y);
    var _hostility_type = _data.get_hostility_type();
    
    // --- STATE MACHINE DECISIONS ---
    if (ai_decision_timer <= 0)
    {
        ai_decision_timer = AI_DECISION_INTERVAL;
        
        creature_evaluate_state(_hostility_type, _target, _distance_to_target, _data);
    }
    
    // --- PREY SCANNING (Optimized) ---
    // Only scan periodically or if not fleeing
    if (ai_state != CREATURE_AI_STATE.FLEE && (ai_decision_timer == AI_DECISION_INTERVAL)) // Sync with decision timer
    {
        creature_scan_for_prey(_data, _dt_normalized);
    }
    else if (ai_state != CREATURE_AI_STATE.FLEE && instance_exists(ai_prey_target))
    {
        // Continue tracking existing prey
        if (point_distance(x, y, ai_prey_target.x, ai_prey_target.y) < AI_HUNT_RANGE)
        {
             creature_engage_prey(ai_prey_target, _data, _dt_normalized);
        }
        else
        {
            ai_prey_target = noone; // Lost prey
        }
    }

    // --- MOVEMENT EXECUTION ---
    input_left = false;
    input_right = false;
    
    // Stuck Check
    if (ai_target_direction != 0 && ai_stuck_timer <= 0)
    {
        ai_stuck_timer = AI_STUCK_CHECK_INTERVAL;
        var _dist_moved = point_distance(x, y, ai_stuck_x, ai_stuck_y);
        
        if (_dist_moved < AI_STUCK_THRESHOLD)
        {
            ai_is_stuck = true;
            // Try to jump or reverse
            if (ai_cached_on_ground) 
            {
                input_jump = true;
                input_jump_pressed = true;
            }
            else
            {
               ai_target_direction *= -1; // Wall bounce
            }
        }
        else
        {
            ai_is_stuck = false;
        }
        
        ai_stuck_x = x;
        ai_stuck_y = y;
    }
    
    if (ai_target_direction != 0)
    {
        if (ai_target_direction > 0) input_right = true;
        else input_left = true;
        
        image_xscale = abs(image_xscale) * ai_target_direction;
        
        // Smart Jumping & Cliff Avoidance
        creature_pathfinding(_target);
    }
    
    // --- PHYSICS & SUFFOCATION ---
    control_physics_input(_dt, id, ((timer_panic > 0) ? 1.5 : 1));
    control_physics(_dt, id);
    
    control_entity_suffocation(id); // New suffocation check
    
    // Old fall damage logic (preserved but could be modularized)
    creature_handle_fall_damage();
    
    control_entity_sfx(_dt);
    control_physics_input_after(_dt, id);
    
    if (attribute.has_boolean(ATTRIBUTE_BOOLEAN.HAS_REGENERATION))
    {
        control_entity_regeneration(_dt_normalized);
    }
    
    control_entity_effect();
    
    // Reset jump input
    if (input_jump && chance(0.4 * _dt))
    {
        input_jump = false;
        input_jump_pressed = false;
    }
}

// --- HELPER FUNCTIONS ---

function creature_evaluate_state(_hostility_type, _target, _distance_to_target, _data)
{
    if (_hostility_type == CREATURE_HOSTILITY_TYPE.HOSTILE)
    {
        var _health_ratio = hp / hp_max;
        
        // Hostile Logic
        if (_distance_to_target <= AI_HOSTILE_RANGE)
        {
            // Line of Sight Check
            var _has_los = !collision_line(x, y - 8, _target.x, _target.y - 8, obj_Tile, false, true); // Simplified LoS
             // Ideally use a fast raycast if available, or just proceed if simple
            
            if (_health_ratio < AI_LOW_HEALTH_THRESHOLD)
            {
                ai_state = CREATURE_AI_STATE.FLEE;
                ai_state_timer = 2.0;
                ai_target_direction = sign(x - _target.x);
            }
            else if (_has_los)
            {
                ai_state = CREATURE_AI_STATE.CHASE;
                
                // Predictive Tracking
                var _lead = 0;
                if (abs(_target.xvelocity) > 1) _lead = sign(_target.xvelocity) * 32; // Lead the target
                
                ai_target_direction = sign((_target.x + _lead) - x);
            }
            else if (ai_state == CREATURE_AI_STATE.CHASE)
            {
                 // Keep chasing last known pos or wander
            }
        }
        else
        {
           creature_handle_idle_wander();
        }
    }
    else // PASSIVE
    {
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
            ai_state = CREATURE_AI_STATE.IDLE;
            ai_state_timer = AI_IDLE_DURATION;
        }
        else
        {
            creature_handle_idle_wander();
        }
    }
}

function creature_handle_idle_wander()
{
    if (ai_state == CREATURE_AI_STATE.CHASE)
    {
        ai_state = CREATURE_AI_STATE.IDLE;
        ai_state_timer = AI_IDLE_DURATION;
    }
    else if (ai_state_timer <= 0)
    {
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

function creature_scan_for_prey(_data, _dt_normalized)
{
    var _my_id = _id;
    
    // Quick optimization: only scan if we have predators defined
    // This assumes _data is available. 
    // Ideally we cache this "is_predator" bool.
    
    var _nearest_prey = noone;
    var _nearest_prey_dist = AI_HUNT_RANGE;
    
    // Loop through potential prey
    // Optimization: Check fewer entities or use spatial hash? 
    // For now, sticking to instance loop but ensuring we break early if good target found
    // Or just finding nearest 'obj_Creature' that satisfies condition.
    
    with (obj_Creature)
    {
        if (id == other.id) continue;
        
        // This check is the bottleneck if many creatures.
        var _prey_data = global.creature_data[$ _id];
         var _predators = _prey_data.get_predators(); // This seems efficient enough
        
        if (array_contains(_predators, _my_id))
        {
            var _dist = point_distance(other.x, other.y, x, y);
            if (_dist < _nearest_prey_dist)
            {
                _nearest_prey = id;
                _nearest_prey_dist = _dist;
            }
        }
    }
    
    if (_nearest_prey != noone)
    {
        ai_prey_target = _nearest_prey;
    }
}

function creature_engage_prey(_target, _data, _dt_normalized)
{
    var _dist = point_distance(x, y, _target.x, _target.y);
    var _contact_damage = _data.get_contact_damage();
    
    if (_dist <= AI_ATTACK_RANGE)
    {
        if (attack_cooldown <= 0 && _target.timer_immunity <= 0)
        {
            control_entity_damage(_target, id, _contact_damage);
             
             if (instance_exists(_target))
             {
                var _kb_dir = sign(_target.x - x);
                if (_kb_dir == 0) _kb_dir = choose(-1, 1);
                _target.xvelocity = _kb_dir * 3;
                _target.yvelocity = -2;
                _target.timer_immunity = 0.5;
                attack_cooldown = AI_ATTACK_COOLDOWN;
                _target.inst_predator = id;
             }
        }
    }
    else
    {
        ai_state = CREATURE_AI_STATE.CHASE;
        ai_target_direction = sign(_target.x - x);
    }
}

function creature_pathfinding(_target)
{
    if (!input_jump && ai_cached_on_ground)
    {
        var _xto = x + (ai_target_direction * ai_cached_collision_width);
        
        // 1. Wall Jump / Step Up
        if (tile_meeting(_xto, y - 1))
        {
            var _fall_dist = entity_ai_fall_detection(_xto, y - (TILE_SIZE * 2), -ai_cached_collision_height, 2);
            if (_fall_dist >= 2)
            {
                input_jump = true;
                input_jump_pressed = true;
            }
        }
        // 2. Chase Jump (Target is above)
        else if (ai_state == CREATURE_AI_STATE.CHASE && instance_exists(_target) && _target.y < y - TILE_SIZE)
        {
             // Check if jump takes us meaningfully somewhere
             // Or just jump periodically when near walls?
             // Existing logic was simplified. Let's keep it.
             // If obstacle ahead or we need to go up?
             
             // Simple "try to jump" if target is high up and somewhat close X
             if (abs(_target.x - x) < TILE_SIZE * 4)
             {
                 input_jump = true;
                 input_jump_pressed = true;
             }
        }
        // 3. Cliff Detection (Avoid falling)
        else if (ai_state == CREATURE_AI_STATE.WANDER)
        {
            var _fall_dist = entity_ai_fall_detection(_xto, y + TILE_SIZE, TILE_SIZE, 4);
            if (_fall_dist >= 4)
            {
                ai_target_direction *= -1;
                ai_state_timer = AI_WANDER_DURATION;
            }
        }
    }
}

function creature_handle_fall_damage()
{
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
}