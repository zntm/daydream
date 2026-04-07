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
    
    PRINT($"[effect_set] Attempting to apply {_type} to {_object}");
    
    var _data = _effect_data[$ _type];
    
    if (_data == undefined) 
    {
        PRINT($"[effect_set] ERROR: Effect data for {_type} is UNDEFINED. Available keys: {struct_get_names(_effect_data)}");
        exit;
    }
    
    var _effect_immune = _object.effect_immune;
    
    if (_effect_immune != undefined) && (array_contains(_effect_immune, _type)) exit;

    control_entity_add_effect(_object, _type, _time * GAME_TICK, _level, id, _particle);
}
