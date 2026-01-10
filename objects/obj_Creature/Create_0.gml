// Initialize defaults to prevent crashes if created outside spawn system (e.g. from save load)
_id = "unknown";
variant = 0;

// Init entity basics (will likely be overridden by init_entity later)
hp = 10;
hp_max = 10;
timer_immunity = 0;
inst_predator = noone;

// AI State
ai_state = CREATURE_AI_STATE.IDLE;
ai_decision_timer = 0;
ai_state_timer = 0;
ai_target_direction = 0;

// Stuck Detection
ai_stuck_timer = 0;
ai_stuck_x = x;
ai_stuck_y = y;
ai_is_stuck = false;

// Combat / Hunting
attack_cooldown = 0;
ai_prey_target = noone;
inst_predator = noone;

// Caching
ai_cached_on_ground = false;

// Logic variables
interp_start_x = x;
interp_start_y = y;
interp_target_x = x;
interp_target_y = y;
interp_timer = 0;
interp_duration = 0.05;

// Required by some scripts even before init_entity
entity_xscale = 1;
entity_yscale = 1;
physics_body = undefined; // Will be set by init_entity
