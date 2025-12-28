enum EFFECT_TYPE {
    CONSTANT,
    ON_DEATH,
    ON_HIT,
    TIMED
}

global.effect_type = {
    "constant": EFFECT_TYPE.CONSTANT,
    "on_death": EFFECT_TYPE.ON_DEATH,
    "on_hit":   EFFECT_TYPE.ON_HIT,
    "timed":    EFFECT_TYPE.TIMED
}

/// @function EffectData(_namespace, _id)
/// @desc Modern effect data class for the unified effect system
/// @param {String} _namespace - Effect namespace (e.g., "phantasia")
/// @param {String} _id - Effect identifier
function EffectData(_namespace, _id) constructor
{
    static __effect_type = global.effect_type;
    static __item_function = global.item_function;
    
    ___namespace = _namespace;
    ___id = _id;
    ___icon = undefined;
    ___type = EFFECT_TYPE.CONSTANT;
    ___attribute = undefined;
    
    static set_icon = function(_icon)
    {
        if (_icon != undefined)
        {
            ___icon = _icon;
        }
        
        return self;
    }
    
    static get_icon = function()
    {
        return ___icon;
    }
    ___base_value = 0;
    ___is_negative = false;
    ___modifiers = undefined;
    ___modifiers_length = 0;
    ___min_value = undefined;
    ___max_value = undefined;
    ___particle = undefined;
    ___on_effect = undefined;
    ___on_death = undefined;
    
    static get_namespace = function()
    {
        return ___namespace;
    }
    
    static get_id = function()
    {
        return ___id;
    }
    
    static get_full_id = function()
    {
        return $"{___namespace}:{___id}";
    }
    
    static set_type = function(_type)
    {
        if (_type != undefined)
        {
            ___type = is_string(_type) ? __effect_type[$ _type] : _type;
        }
        
        return self;
    }
    
    static get_type = function()
    {
        return ___type;
    }
    
    static set_attribute = function(_attribute)
    {
        if (_attribute != undefined)
        {
            ___attribute = _attribute;
        }
        
        return self;
    }
    
    static get_attribute = function()
    {
        return ___attribute;
    }
    
    static set_base_value = function(_value)
    {
        if (_value != undefined)
        {
            ___base_value = _value;
        }
        
        return self;
    }
    
    static get_base_value = function()
    {
        return ___base_value;
    }
    
    static set_is_negative = function(_is_negative)
    {
        if (_is_negative != undefined)
        {
            ___is_negative = _is_negative;
        }
        
        return self;
    }
    
    static is_negative = function()
    {
        return ___is_negative;
    }
    
    static set_modifiers = function(_modifiers)
    {
        if (_modifiers != undefined)
        {
            ___modifiers_length = array_length(_modifiers);
            ___modifiers = array_create(___modifiers_length);
            
            for (var i = 0; i < ___modifiers_length; ++i)
            {
                var _mod = _modifiers[i];
                ___modifiers[i] = new EffectModifier(_mod.value, _mod.operation);
            }
        }
        
        return self;
    }
    
    static get_modifiers = function()
    {
        return ___modifiers;
    }
    
    static get_modifiers_length = function()
    {
        return ___modifiers_length;
    }
    
    static set_min_value = function(_min)
    {
        if (_min != undefined)
        {
            ___min_value = _min;
        }
        
        return self;
    }
    
    static get_min_value = function()
    {
        return ___min_value;
    }
    
    static set_max_value = function(_max)
    {
        if (_max != undefined)
        {
            ___max_value = _max;
        }
        
        return self;
    }
    
    static get_max_value = function()
    {
        return ___max_value;
    }
    
    static set_particle = function(_particle)
    {
        if (_particle != undefined)
        {
            ___particle = {
                id: _particle.id,
                chance: _particle.chance ?? 0.1,
                colour: _particle[$ "colour"]
            }
        }
        
        return self;
    }
    
    static get_particle = function()
    {
        return ___particle;
    }
    
    static set_on_effect = function(_on_effect)
    {
        if (_on_effect != undefined)
        {
            ___on_effect = _on_effect;
        }
        
        return self;
    }
    
    static get_on_effect = function()
    {
        return ___on_effect;
    }
    
    static set_on_death = function(_on_death)
    {
        if (_on_death != undefined)
        {
            ___on_death = _on_death;
        }
        
        return self;
    }
    
    static get_on_death = function()
    {
        return ___on_death;
    }
    
    /// @function calculate_value(_level)
    /// @desc Calculate the effect value for a given level
    /// @param {Real} _level - The effect level
    /// @returns {Real} The calculated effect value
    static calculate_value = function(_level)
    {
        var _result = ___base_value;
        
        if (___modifiers != undefined)
        {
            for (var i = 0; i < ___modifiers_length; ++i)
            {
                _result = ___modifiers[i].calculate(_result, _level);
            }
        }
        
        if (___min_value != undefined)
        {
            _result = max(_result, ___min_value);
        }
        
        if (___max_value != undefined)
        {
            _result = min(_result, ___max_value);
        }
        
        return _result;
    }
}
