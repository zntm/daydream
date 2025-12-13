function spawn_creature(_x, _y, _id, _variant)
{
    randomize();
    
    var _data = global.creature_data[$ _id];
    
    var _hp = _data.get_hp();
    
    var _inst = instance_create_layer(_x, _y, "Instances", obj_Creature);
    
    with (_inst)
    {
        id._id = _id;
        
        if (_variant != undefined)
        {
            variant = smart_value(_variant);
        }
        
        init_entity(_hp, _hp, _data.get_attribute());
        
        var _interval = _data.get_sfx_interval();
        
        if (_interval != undefined)
        {
            timer_sfx_idle = smart_value(_interval);
        }
        
        inst_predator = noone;
        timer_panic = 0;
        
        // Humanoid-specific initialization
        timer_attack = 0;
        attack_cooldown = 0;
        ai_prey_target = noone;
        
        ai_state = CREATURE_AI_STATE.IDLE;
        ai_decision_timer = 0;
        ai_state_timer = 0;
        ai_target_direction = 0;
        ai_cached_on_ground = false;
        ai_cached_collision_width = attribute.get_collision_box_width();
        ai_cached_collision_height = attribute.get_collision_box_height();
        
        // Predator hunting initialization
        attack_cooldown = 0;
        ai_prey_target = noone;
        
        // Stuck detection
        ai_stuck_timer = 0;
        ai_stuck_x = x;
        ai_stuck_y = y;
        ai_is_stuck = false;
    }
    
    // Emit entity spawned event
    event_emit(GAME_EVENT.ENTITY_SPAWNED, {
        instance: _inst,
        type: "creature",
        id: _id,
        variant: _variant
    });
    
    return _inst;
}