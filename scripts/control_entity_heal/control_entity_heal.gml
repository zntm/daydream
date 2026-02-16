/// @function control_entity_heal(_target, _amount, _source)
/// @desc Unified heal handler for all entities. Triggers on_heal effects.
/// @param {Id.Instance} _target The entity being healed.
/// @param {Real} _amount Amount of HP to heal.
/// @param {Id.Instance} _source The source of the healing (optional).
/// @return {Real} Returns the actual amount healed.
function control_entity_heal(_target, _amount, _source = undefined)
{
    if (_amount <= 0) return 0;
    
    var _hp_before = _target.hp;
    var _hp_max = _target.hp_max;
    
    // Skip if already at max health
    if (_hp_before >= _hp_max) return 0;
    
    var _effect_data = global.effect_data;
    
    // Apply heal
    var _new_hp = min(_hp_max, _hp_before + _amount);
    _target.hp = _new_hp;
    
    var _actual_heal = _new_hp - _hp_before;
    
    // Trigger on_heal effects
    var _effects = _target.effects;
    var _names = struct_get_names(_effects);
    
    
    for (var i = array_length(_names) - 1; i >= 0; --i)
    {
        var _name = _names[i];
        var _data = _effect_data[$ _name];
        
        if (_data == undefined) continue;
        
        var _on_heal = _data.get_on_heal();
        
        if (_on_heal != undefined)
        {
            var _params = variable_clone(_on_heal[$ "parameters"] ?? {});
            
            _params[$ "heal_amount"] = _actual_heal;
            _params[$ "source"] = _source;
            _params[$ "target"] = _target;
            
            function_execute({ id: _on_heal.id, parameters: _params }, _target.x, _target.y, CHUNK_DEPTH_DEFAULT, 1, 1, _target);
        }
    }
    
    // Spawn healing particles
    repeat (irandom_range(2, 4))
    {
        spawn_particle(
            random_range(_target.bbox_left, _target.bbox_right),
            random_range(_target.bbox_top, _target.bbox_bottom),
            "phantasia:entity/heal"
        );
    }
    
    return _actual_heal;
}
