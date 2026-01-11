/// @function control_entity_add_effect(_target, _effect_id, _duration, _level, _source)
/// @desc Adds an effect to an entity. Triggers on_effect if the effect is new.
/// @param {Id.Instance} _target - The entity to receive the effect
/// @param {String} _effect_id - The ID of the effect to add (e.g. "phantasia:poison")
/// @param {Real} _duration - Duration in ticks
/// @param {Real} _level - Effect level (default 1)
/// @param {Id.Instance} _source - Source of the effect (optional)
function control_entity_add_effect(_target, _effect_id, _duration, _level = 1, _source = undefined)
{
    // Validate target
    if (!instance_exists(_target)) exit;
    if (!variable_instance_exists(_target, "effects")) exit;
    
    var _has_effect = struct_exists(_target.effects, _effect_id);
    var _effect_inst = _target.effects[$ _effect_id];
    var _effect_data = global.effect_data[$ _effect_id];
    
    if (_effect_data == undefined)
    {
        show_debug_message($"[Effect] Error: Unknown effect '{_effect_id}'");
        exit;
    }
    
    if (_has_effect)
    {
        // Update existing effect
        // Keep highest level, refresh duration if new one is longer or same level
        if (_level > _effect_inst.level)
        {
            _effect_inst.level = _level;
            _effect_inst.timer = _duration;
        }
        else if (_level == _effect_inst.level)
        {
            _effect_inst.timer = max(_effect_inst.timer, _duration);
        }
    }
    else
    {
        // Add new effect
        _target.effects[$ _effect_id] = {
            timer: _duration,
            level: _level,
            source: _source
        }
        
        // Trigger on_effect
        var _on_effect = _effect_data.get_on_effect();
        
        if (_on_effect != undefined)
        {
            var _params = variable_clone(_on_effect[$ "parameters"] ?? {});
            _params[$ "target"] = _target;
            _params[$ "source"] = _source;
            _params[$ "effect_name"] = _effect_id;
            _params[$ "level"] = _level;
            
            function_execute({ id: _on_effect.id, parameters: _params }, _target.x, _target.y, CHUNK_DEPTH_DEFAULT, 1, 1, _target);
        }
        
        // Initial particles?
        if (_effect_data.get_particle() != undefined)
        {
             // Maybe spawn one immediately?
        }
    }
    
    // Refresh attributes immediately
    if (_target.object_index == obj_Creature)
    {
        with (_target) get_buffs(global.creature_data[$ creature_id].attributes);
    }
    else if (_target.object_index == obj_Player)
    {
        with (_target) get_buffs(global.attribute_player);
    }
}
