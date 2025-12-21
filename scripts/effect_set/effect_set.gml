/// @function effect_set(_type, _time, _level, _object, _particle)
/// @desc Apply an effect to an entity using the new EffectData system
/// @param {String} _type - Effect ID (e.g., "phantasia:poison")
/// @param {Real} _time - Duration in seconds
/// @param {Real} _level - Effect level/potency (default 1)
/// @param {Id.Instance} _object - Target entity (default id)
/// @param {Bool} _particle - Whether to show particles (default true)
function effect_set(_type, _time, _level = 1, _object = id, _particle = true)
{
    var _effect_data = global.effect_data;
    
    show_debug_message($"[effect_set] Attempting to apply {_type} to {_object}");
    
    var _data = _effect_data[$ _type];
    
    if (_data == undefined) 
    {
        show_debug_message($"[effect_set] ERROR: Effect data for {_type} is UNDEFINED. Available keys: {variable_struct_get_names(_effect_data)}");
        exit;
    }
    
    var _effect_immune = _object.effect_immune;
    
    if (_effect_immune != undefined) && (array_contains(_effect_immune, _type)) exit;
    
    with (_object)
    {
        effects[$ _type] = {
            timer: _time * GAME_TICK,
            level: _level,
            particle: _particle
        }
        
        if (object_index == obj_Creature)
        {
            get_buffs(global.creature_data[$ creature_id].attributes);
        }
        else if (object_index == obj_Player)
        {
            get_buffs(global.attribute_player);
        }
    }
    
    // Execute on_effect ItemFunction if defined
    var _on_effect = _data.get_on_effect();
    
    if (_on_effect != undefined)
    {
        var _fn = global.item_function[$ _on_effect.id];
        
        if (_fn != undefined)
        {
            _fn(1, _object.x, _object.y, CHUNK_DEPTH_DEFAULT, 1, 1, _on_effect[$ "parameter"] ?? {});
        }
    }
}