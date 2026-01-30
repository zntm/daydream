/// @function ItemArmor(_type, _defense)
/// @desc Armor data with unified modifier system
/// @param {String} _type - Armor type (helmet, breastplate, leggings, accessory)
/// @param {Real} _defense - Defense value
function ItemArmor(_type, _defense) constructor
{
    static __type = global.item_armor_type;
    
    ___type = __type[$ _type];
    ___defense = _defense;
    ___modifiers = undefined;
    ___modifiers_length = 0;
    
    static get_type = function()
    {
        return ___type;
    }
    
    static get_defense = function()
    {
        return ___defense;
    }
    
    /// @function set_attributes(_attributes)
    /// @desc Set attribute modifiers from datagen JSON
    /// @param {Array} _attributes - Array of {attribute, modifier} objects
    static set_attributes = function(_attributes)
    {
        if (_attributes != undefined)
        {
            ___modifiers_length = array_length(_attributes);
            ___modifiers = array_create(___modifiers_length);
            
            for (var i = 0; i < ___modifiers_length; ++i)
            {
                var _attr = _attributes[i];
                
                ___modifiers[i] = {
                    attribute: _attr.attribute,
                    modifier: new EffectModifier(_attr.modifier.value, _attr.modifier.operation)
                }
            }
        }
        
        return self;
    }
    
    static get_attributes = function()
    {
        return ___modifiers;
    }
    
    static get_modifiers = function()
    {
        return ___modifiers;
    }
    
    static get_modifiers_length = function()
    {
        return ___modifiers_length;
    }
    
    /// @function apply_modifiers(_base_attributes)
    /// @desc Apply all armor modifiers to a base attribute set
    /// @param {Struct.Attribute} _base_attributes - The attribute struct to modify
    static apply_modifiers = function(_base_attributes)
    {
        // 1. Convert Defense to Max HP (Heart Containers)
        // 1 Defense Point = 10 HP (0.5 Heart Container if 20HP base, but we use 100HP base -> 10HP = 0.5 Heart visual?)
        // Let's assume 1 Defense = 10 HP.
        if (___defense > 0)
        {
            if (struct_exists(_base_attributes, "get_hp_max") && struct_exists(_base_attributes, "set_hp_max"))
            {
                var _current_max = _base_attributes.get_hp_max();
                _base_attributes.set_hp_max(_current_max + (___defense * 10));
            }
        }
        
        if (___modifiers == undefined) exit;
        
        for (var i = 0; i < ___modifiers_length; ++i)
        {
            var _mod = ___modifiers[i];
            var _attr = _mod.attribute;
            var _modifier = _mod.modifier;
            
            // Get current value using getter pattern
            var _getter = $"get_{_attr}";
            var _setter = $"set_{_attr}";
            
            if (struct_exists(_base_attributes, _getter))
            {
                var _current = _base_attributes[$ _getter]();
                var _new_value = _modifier.calculate(_current, 1);
                
                if (struct_exists(_base_attributes, _setter))
                {
                    _base_attributes[$ _setter](_new_value);
                }
            }
        }
    }
}