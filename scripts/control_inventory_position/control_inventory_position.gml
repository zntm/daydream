function control_inventory_position()
{
    var _gui_scale = global.gui_scale;
    var _scale_x = _gui_scale * (global.gui_width / 960);
    var _scale_y = _gui_scale * (global.gui_height / 540);
    
    // Position inventory slots based on modular GUI components
    // The modular GUI has GUISlot components that know their correct absolute position
    
    var _inventory_instance = global.inventory_instance;
    
    // Get the appropriate panel based on inventory open state
    var _panel = undefined;
    if (is_opened & IS_OPENED_BOOLEAN.INVENTORY)
    {
        _panel = global.gui_panel_inventory_modular;
    }
    else
    {
        _panel = global.gui_panel_hotbar_modular;
    }
    
    if (_panel == undefined) return;
    
    // Iterate through modular GUI slot children and position corresponding obj_Inventory instances
    var _children = _panel.children;
    var _length = array_length(_children);
    
    for (var i = 0; i < _length; ++i)
    {
        var _slot = _children[i];
        
        // Check if this is a GUISlot (has inventory_name property)
        if (!variable_struct_exists(_slot, "inventory_name")) continue;
        
        var _inv_name = _slot.inventory_name;
        var _inv_index = _slot.slot_index;
        
        // Get the corresponding obj_Inventory instance
        var _instances = _inventory_instance[$ _inv_name];
        if (_instances == undefined) continue;
        if (_inv_index >= array_length(_instances)) continue;
        
        var _inst = _instances[_inv_index];
        if (!instance_exists(_inst)) continue;
        
        // Get absolute position from the modular GUI slot (same as rendering)
        var _abs_x = _slot.get_absolute_x();
        var _abs_y = _slot.get_absolute_y();
        
        // Get component scale from datagen
        var _slot_scale = _slot.scale;
        
        // Position obj_Inventory at the scaled GUI position (matching GUISlot.draw_content)
        _inst.x = _abs_x * _scale_x;
        _inst.y = _abs_y * _scale_y;
        
        // Scale instances to match visual rendering (base scale * component scale)
        _inst.image_xscale = _scale_x * _slot_scale;
        _inst.image_yscale = _scale_y * _slot_scale;
    }
    
    // Also handle armor, accessory, and container slots if inventory is open
    if (is_opened & IS_OPENED_BOOLEAN.INVENTORY)
    {
        // Position armor/accessory slots using old system for now (they're not in modular GUI yet)
        var _gui_inventory_data = global.gui_inventory;
        var _other_names = ["armor_helmet", "armor_breastplate", "armor_leggings", "accessory"];
        
        for (var n = 0; n < array_length(_other_names); ++n)
        {
            var _inv_name = _other_names[n];
            var _data = _gui_inventory_data[$ _inv_name];
            if (_data == undefined) continue;
            
            var _anchor_type = _data.anchor_type;
            var _anchor_x = gui_xanchor(_anchor_type, global.gui_width, _scale_x) + (_data.surface_xoffset * _scale_x);
            var _anchor_y = gui_yanchor(_anchor_type, global.gui_height, _scale_y) + (_data.surface_yoffset * _scale_y);
            
            var _instances = _inventory_instance[$ _inv_name];
            if (_instances == undefined) continue;
            
            var _len = array_length(_instances);
            for (var j = 0; j < _len; ++j)
            {
                var _inst = _instances[j];
                if (!instance_exists(_inst)) continue;
                
                _inst.x = _anchor_x + (_inst.xoffset * _scale_x);
                _inst.y = _anchor_y + (_inst.yoffset * _scale_y);
                _inst.image_xscale = _scale_x;
                _inst.image_yscale = _scale_y;
            }
        }
    }
}

