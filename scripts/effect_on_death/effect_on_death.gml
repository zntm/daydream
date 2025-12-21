/// @function effect_on_death(_x, _y, _id)
/// @desc Process on_death effects using the new EffectData and ItemFunction system
/// @param {Real} _x - Entity X position
/// @param {Real} _y - Entity Y position
/// @param {Id.Instance} _id - Entity instance ID
function effect_on_death(_x, _y, _id)
{
    var _effect_data = global.effect_data;
    
    var _effect_names  = global.effect_data_names;
    var _effect_length = array_length(_effect_names);
    
    for (var i = 0; i < _effect_length; ++i)
    {
        var _name = _effect_names[i];
        var _effect = effects[$ _name];
        
        if (_effect == undefined) continue;
        
        var _data = _effect_data[$ _name];
        
        if (_data.get_type() == EFFECT_TYPE.ON_DEATH)
        {
            var _on_death = _data.get_on_death();
            
            if (_on_death != undefined)
            {
                var _fn = global.item_function[$ _on_death.id];
                
                if (_fn != undefined)
                {
                    _fn(1, _x, _y, CHUNK_DEPTH_DEFAULT, 1, 1, _on_death[$ "parameter"] ?? {});
                }
            }
        }
        
        delete effects[$ _name];
        
        effects[$ _name] = undefined;
    }
}