/// @function get_buffs(_base_attributes)
/// @desc Recalculate entity attributes based on base stats, active effects, and equipment
/// @param {Struct.Attribute} _base_attributes - The base attributes to start from
function get_buffs(_base_attributes)
{
    // 1. Reset attributes to base values
    attribute.copy_from(_base_attributes);
    
    // 2. Apply active effect modifiers
    var _names = struct_get_names(effects);
    var _length = array_length(_names);
    var _effect_data_map = global.effect_data;
    
    for (var i = 0; i < _length; ++i)
    {
        var _effect_id = _names[i];
        var _active_effect = effects[$ _effect_id];
        var _effect_data = _effect_data_map[$ _effect_id];
        
        if (_effect_data == undefined) continue;
        
        var _attr_name = _effect_data.get_attribute();
        
        if (_attr_name != undefined)
        {
            // Construct getter/setter names
            var _getter = $"get_{_attr_name}";
            var _setter = $"set_{_attr_name}";
            
            // Apply modifier if attribute exists
            if (variable_struct_exists(attribute, _getter) && variable_struct_exists(attribute, _setter))
            {
                var _current_val = attribute[$ _getter]();
                var _level = _active_effect.level;
                
                // Calculate effect value (base + modifiers)
                var _effect_val = _effect_data.calculate_value(_level);
                
                // Add effect value to current attribute (Additive buff/debuff)
                attribute[$ _setter](_current_val + _effect_val);
            }
        }
    }
    
    // 3. Apply equipment modifiers (Player only)
    if (object_index == obj_Player)
    {
        var _inventory = global.inventory;
        var _item_data = global.item_data;
        
        // Armor slots
        var _armor_slots = ["armor_helmet", "armor_breastplate", "armor_leggings"];
        
        for (var i = 0; i < 3; ++i)
        {
            var _item = _inventory[$ _armor_slots[i]][0];
            
            if (_item != INVENTORY_EMPTY)
            {
                var _data = _item_data[$ _item.get_id()];
                if (_data != undefined && is_instanceof(_data, ItemArmor))
                {
                    _data.apply_modifiers(attribute);
                }
            }
        }
        
        // Accessory slots
        var _accessories = _inventory.accessory;
        var _acc_length = array_length(_accessories);
        
        for (var i = 0; i < _acc_length; ++i)
        {
            var _item = _accessories[i];
            
            if (_item != INVENTORY_EMPTY)
            {
                var _data = _item_data[$ _item.get_id()];
                // Check if it's an AccessoryItem (which extends ItemArmor/Item) and has apply_modifiers
                // Assuming AccessoryItem datagen creates ItemArmor or similar runtime struct
                // In daymare engine, ItemArmor was used for accessories too usually.
                // Let's check type or just check method existence
                if (_data != undefined && variable_struct_exists(_data, "apply_modifiers"))
                {
                    _data.apply_modifiers(attribute);
                }
            }
        }
    }
}
