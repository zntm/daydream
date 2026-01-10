/// @description Unified damage handler for all entities
/// @param {Id.Instance} _victim The entity taking damage
/// @param {Id.Instance} _attacker The entity dealing damage
/// @param {Real} _base_damage Base damage amount
/// @param {Real} _variance Damage variance (0.0 to 1.0, default 0.0 for no variance)
/// @param {Real} _crit_chance Critical hit chance (0.0 to 1.0, default 0.05)
/// @param {Real} _crit_multiplier Critical hit damage multiplier (default 1.25)
/// @return {Bool} Returns true if the victim died, false otherwise
function control_entity_damage(_victim, _attacker, _base_damage, _variance = 0.0, _crit_chance = 0.05, _crit_multiplier = 1.25)
{
    // Apply damage variance if specified
    var _damage = _base_damage;
    
    // Apply difficulty multiplier if victim is player
    if (_victim.object_index == obj_Player || object_is_ancestor(_victim.object_index, obj_Player))
    {
        var _difficulty = global.world_save_data[$ "difficulty"] ?? 1.0;
        _damage *= _difficulty;
    }
    
    if (_variance > 0)
    {
        _damage = round(_damage * random_range(1.0 - _variance, 1.0 + _variance));
    }
    
    // Check for critical hit
    var _is_critical = chance(_crit_chance);
    
    if (_is_critical)
    {
        _damage = round(_damage * _crit_multiplier);
        
        // Spawn critical hit particles
        repeat (irandom_range(3, 8))
        {
            spawn_particle(
                random_range(_victim.bbox_left, _victim.bbox_right),
                random_range(_victim.bbox_top, _victim.bbox_bottom),
                "phantasia:entity/damage_critical"
            );
        }
    }
    else
    {
        // Spawn normal damage particles
        repeat (irandom_range(3, 8))
        {
            spawn_particle(
                random_range(_victim.bbox_left, _victim.bbox_right),
                random_range(_victim.bbox_top, _victim.bbox_bottom),
                "phantasia:entity/damage"
            );
        }
    }
    
    // Apply damage
    _victim.hp -= _damage;
    
    // Trigger on_damage effects
    var _effects = _victim.effects;
    var _effect_names = struct_get_names(_effects);
    var _effect_names_length = array_length(_effect_names);
    var _effect_data = global.effect_data;
    var _item_function = global.item_function;
    
    for (var i = 0; i < _effect_names_length; ++i)
    {
        var _name = _effect_names[i];
        var _data = _effect_data[$ _name];
        
        if (_data == undefined) continue;
        
        var _on_damage = _data.get_on_damage();
        
        if (_on_damage != undefined)
        {
            var _fn = _item_function[$ _on_damage.id];
            
            if (_fn != undefined)
            {
                var _params = _on_damage[$ "parameters"] ?? {};
                _params[$ "damage_amount"] = _damage;
                _params[$ "attacker"] = _attacker;
                _params[$ "victim"] = _victim;
                _params[$ "is_critical"] = _is_critical;
                
                _fn(1, _victim.x, _victim.y, CHUNK_DEPTH_DEFAULT, 1, 1, _params);
            }
        }
    }
    
    // Emit damage event
    event_emit(new EventDataEntityDamage(_victim, _damage, _attacker, _is_critical));
    
    // Spawn floating damage text
    spawn_floating_text(_victim.x, _victim.y, _damage, 0, -3.9);
    
    // Check if victim died
    if (_victim.hp <= 0)
    {
        // Emit death event
        event_emit(new EventDataEntityDie(_victim, _attacker));
        
        // Special handling for player death
        if (_victim.object_index == obj_Player)
        {
            _victim.timer_respawn = 3;
        }
        else
        {
            if (struct_exists(_victim, "physics_body")) global.spatial_grid.remove(_victim.physics_body);
            instance_destroy(_victim);
        }
        
        return true; // Entity died
    }
    
    // Set immunity timer
    _victim.timer_immunity = 1;
    
    return false; // Entity survived
}