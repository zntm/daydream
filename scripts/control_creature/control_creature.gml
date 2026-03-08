/// @desc Creature control using new physics system
/// @param {Real} _dt Delta time

// AI States
enum CREATURE_AI_STATE {
    IDLE,
    WANDER,
    CHASE,
    FLEE,
    ATTACK,
    STUNNED
}

// AI Constants
#macro AI_DECISION_INTERVAL 0.15
#macro AI_HOSTILE_RANGE (TILE_SIZE * 16)
#macro AI_FLEE_RANGE (TILE_SIZE * 12)
#macro AI_WANDER_DURATION 2.0
#macro AI_IDLE_DURATION 1.5
#macro AI_ATTACK_COOLDOWN 1.0
#macro AI_LOW_HEALTH_THRESHOLD 0.3
#macro AI_ATTACK_RANGE (TILE_SIZE * 1.5)
#macro AI_HUNT_RANGE (TILE_SIZE * 8)
#macro AI_STUCK_CHECK_INTERVAL 0.5
#macro AI_STUCK_THRESHOLD 4.0

function control_creature()
{
    // REMOTE CREATURES ON CLIENT (INTERPOLATION)
    if (global.network_role == RELAY_ROLE.CLIENT)
    {
        if (variable_instance_exists(self, "interp_start_x"))
        {
            interp_timer += 1 / GAME_TICK;
            var _t = clamp(interp_timer / interp_duration, 0, 1);
            
            x = lerp(interp_start_x, interp_target_x, _t);
            y = lerp(interp_start_y, interp_target_y, _t);
            
            // Facing direction
            if (interp_target_x != interp_start_x)
            {
                image_xscale = abs(image_xscale) * sign(interp_target_x - interp_start_x);
            }
        }
        exit; // Skip AI/Physics on client
    }
    
    var _data = global.creature_data[$ _id];
    var _dt_normalized = 1 / GAME_TICK;
    
    // TIMERS
    ai_decision_timer -= _dt_normalized;
    ai_state_timer -= _dt_normalized;
    ai_stuck_timer -= _dt_normalized;
    if (attack_cooldown > 0) attack_cooldown -= _dt_normalized;
    
    // DAMAGE CHECK
    if (timer_immunity <= 0)
    {
        var _inst = instance_place(x, y, obj_Tool);
        
        if (instance_exists(_inst))
        {
            var _base_damage = global.item_data[$ _inst._id].get_item_damage();
            var _died = control_entity_damage(id, _inst.inst_owner, _base_damage, 0.1);
            
            if (_died) exit;
            
            inst_predator = _inst.inst_owner;
            
            // Knockback using physics body
            var _kb_dir = sign(x - _inst.x);
            if (_kb_dir == 0) _kb_dir = choose(-1, 1);
            physics_body.vel_x = _kb_dir * 4;
            physics_body.vel_y = -3;
            
            // Flee or attack based on hostility
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
    
    // SENSORS
    physics_body.sync_from_instance(id);
    global.spatial_grid.update(physics_body);
    entity_update_collision(physics_body);
    
    var _target = instance_nearest(x, y, obj_Player);
    var _distance_to_target = instance_exists(_target) ? point_distance(x, y, _target.x, _target.y) : infinity;
    var _hostility_type = _data.get_hostility_type();
    
    // AI DECISION
    if (ai_state == CREATURE_AI_STATE.STUNNED)
    {
        if (ai_state_timer <= 0)
        {
            ai_state = CREATURE_AI_STATE.IDLE;
            ai_state_timer = AI_IDLE_DURATION;
        }
    }
    
    if (ai_state != CREATURE_AI_STATE.STUNNED) && (ai_decision_timer <= 0)
    {
        ai_decision_timer = AI_DECISION_INTERVAL;
        creature_evaluate_state(_hostility_type, _target, _distance_to_target, _data);
    }
    
    // PREY SCANNING
    if (ai_state != CREATURE_AI_STATE.STUNNED) && (ai_state != CREATURE_AI_STATE.FLEE && ai_decision_timer == AI_DECISION_INTERVAL)
    {
        creature_scan_for_prey(_data, _dt_normalized);
    }
    else if (ai_state != CREATURE_AI_STATE.FLEE && instance_exists(ai_prey_target))
    {
        if (point_distance(x, y, ai_prey_target.x, ai_prey_target.y) < AI_HUNT_RANGE)
        {
            creature_engage_prey(ai_prey_target, _data, _dt_normalized);
        }
        else
        {
            ai_prey_target = noone;
        }
    }
    
    // GENERATE AI INPUT
    var _move_x = 0;
    var _move_y = 0;
    var _wants_jump = false;
    
    // Stuck detection
    if (ai_target_direction != 0 && ai_stuck_timer <= 0)
    {
        ai_stuck_timer = AI_STUCK_CHECK_INTERVAL;
        var _dist_moved = point_distance(x, y, ai_stuck_x, ai_stuck_y);
        
        if (_dist_moved < AI_STUCK_THRESHOLD)
        {
            ai_is_stuck = true;
            if (physics_body.collision.ground)
            {
                _wants_jump = true;
            }
            else
            {
                ai_target_direction *= -1;
            }
        }
        else
        {
            ai_is_stuck = false;
        }
        
        ai_stuck_x = x;
        ai_stuck_y = y;
    }
    
    // Movement direction
    if (ai_state != CREATURE_AI_STATE.STUNNED)
    {
        if (ai_target_direction != 0)
        {
            _move_x = ai_target_direction;
            image_xscale = abs(image_xscale) * ai_target_direction;
            
            // Pathfinding - jump over obstacles
            if (!_wants_jump && physics_body.collision.ground)
            {
                creature_pathfinding(_target, _move_x, _wants_jump);
            }
        }
        
        // Set AI input
        input_state.from_ai(_move_x, _move_y, _wants_jump, false);
    }
    else
    {
        input_state.clear();
    }
    
    // PHYSICS
    // Set movement mode based on creature type
    var _movement_type = _data.get_movement_type();
    if (_movement_type == CREATURE_MOVEMENT_TYPE.FLY)
    {
        physics_body.mode = MOVEMENT_MODE.FLY;
    }
    else if (_movement_type == CREATURE_MOVEMENT_TYPE.SWIM || physics_body.collision.in_liquid)
    {
        physics_body.mode = MOVEMENT_MODE.SWIM;
    }
    else
    {
        physics_body.mode = MOVEMENT_MODE.GROUND;
    }
    
    physics_step(physics_body, input_state);
    physics_body.sync_to_instance(id);
    
    // FALL DAMAGE
    creature_handle_fall_damage();
    
    // POST-PHYSICS
    control_entity_sfx();
    control_entity_suffocation(id);
    
    if (attribute.has_boolean(ATTRIBUTE_BOOL.HAS_REGENERATION))
    {
        control_entity_regeneration(_dt_normalized);
    }
    
    control_entity_effect();
}

// AI HELPER FUNCTIONS

function creature_evaluate_state(_hostility_type, _target, _distance_to_target, _data)
{
    if (_hostility_type == CREATURE_HOSTILITY_TYPE.HOSTILE)
    {
        var _health_ratio = hp / hp_max;
        
        if (_distance_to_target <= AI_HOSTILE_RANGE)
        {
            if (_health_ratio < AI_LOW_HEALTH_THRESHOLD)
            {
                ai_state = CREATURE_AI_STATE.FLEE;
                ai_state_timer = 2.0;
                ai_target_direction = sign(x - _target.x);
            }
            else
            {
                ai_state = CREATURE_AI_STATE.CHASE;
                
                // Predictive tracking
                var _lead = 0;
                if (instance_exists(_target) && abs(_target.physics_body.vel_x) > 1)
                {
                    _lead = sign(_target.physics_body.vel_x) * 32;
                }
                
                ai_target_direction = sign((_target.x + _lead) - x);
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
    var _nearest_prey = noone;
    var _nearest_prey_dist = AI_HUNT_RANGE;
    
    var _range = AI_HUNT_RANGE;
    var _nearby = global.creature_quadtree.query_rect(x - _range, y - _range, x + _range, y + _range);
    var _length = array_length(_nearby);
    
    for (var i = 0; i < _length; ++i)
    {
        var _inst = _nearby[i];
        if (_inst == id) continue;
        
        var _prey_data = global.creature_data[$ _inst._id];
        var _predators = _prey_data.get_predators();
        
        if (array_contains(_predators, _my_id))
        {
            var _dist = point_distance(_inst.x, _inst.y, x, y);
            if (_dist < _nearest_prey_dist)
            {
                _nearest_prey = _inst;
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
                _target.physics_body.vel_x = _kb_dir * 3;
                _target.physics_body.vel_y = -2;
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

function creature_pathfinding(_target, _move_x, _wants_jump)
{
    var _collision_width = attribute.get_collision_box_width();
    var _xto = x + (_move_x * _collision_width);
    
    // Wall jump / step up
    if (physics_body.collision.wall_left && _move_x < 0 || physics_body.collision.wall_right && _move_x > 0)
    {
        var _fall_dist = entity_ai_fall_detection(_xto, y - (TILE_SIZE * 2), -attribute.get_collision_box_height(), 2);
        if (_fall_dist >= 2)
        {
            _wants_jump = true;
        }
    }
    // Chase jump (target above)
    else if (ai_state == CREATURE_AI_STATE.CHASE && instance_exists(_target) && _target.y < y - TILE_SIZE)
    {
        if (abs(_target.x - x) < TILE_SIZE * 4)
        {
            _wants_jump = true;
        }
    }
    // Cliff detection (wandering)
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

function creature_handle_fall_damage()
{
    if (y > y_last)
    {
        if (physics_body.collision.ground)
        {
            var _difference = max(0, y - y_last - (TILE_SIZE * 8));
            var _value = floor(power(floor(_difference / TILE_SIZE) * 0.62, 1.25));
            
            if (_value > 0 && !attribute.has_boolean(ATTRIBUTE_BOOL.IS_FALL_DAMAGE_RESISTANT))
            {
                hp -= _value;
                y_last = y;
                
                repeat (irandom_range(2, 6))
                {
                    spawn_particle(random_range(bbox_left, bbox_right), random_range(bbox_top, bbox_bottom), "phantasia:entity/damage");
                }
                
                spawn_floating_text(x, y, _value, 0, -3.9);
                
                if (hp <= 0)
                {
                    if (object_index == obj_Player)
                    {
                        timer_respawn = 3;
                    }
                    else
                    {
                        global.spatial_grid.remove(physics_body);
                        instance_destroy();
                    }
                    exit;
                }
            }
        }
    }
    else
    {
        y_last = y;
    }
}