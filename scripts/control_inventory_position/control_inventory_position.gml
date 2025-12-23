function control_inventory_position()
{
    var _gui_scale = global.gui_scale;
    var _scale_x = _gui_scale * (global.gui_width / 960);
    var _scale_y = _gui_scale * (global.gui_height / 540);
    
    // Position inventory slots based on modular GUI components
    // The modular GUI has GUISlot components that know their correct absolute position
    
    var _inventory_instance = global.inventory_instance;
    
    // List of panels to process for inventory slot positioning
    var _panels = [];
    
    // Always include hotbar if it exists
    if (variable_global_exists("gui_panel_hotbar_modular"))
    {
        array_push(_panels, global.gui_panel_hotbar_modular);
    }
    
    // Include inventory if open
    if (is_opened & IS_OPENED_BOOLEAN.INVENTORY)
    {
        if (variable_global_exists("gui_panel_inventory_modular"))
        {
            array_push(_panels, global.gui_panel_inventory_modular);
        }
    }
    
    // Crafting Panel (Visible only if Inventory Open & Has Content)
    if (variable_global_exists("gui_panel_crafting_modular"))
    {
        var _panel = global.gui_panel_crafting_modular;
        _panel.visible = (is_opened & IS_OPENED_BOOLEAN.INVENTORY) && (array_length(_panel.children) > 0);
        
        array_push(_panels, _panel);
    }
    
    var _panels_length = array_length(_panels);
    
    // Iterate through all active panels
    for (var p = 0; p < _panels_length; ++p)
    {
        var _panel = _panels[p];
        if (_panel == undefined) continue;
        
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
            
            // Position obj_Inventory at the scaled GUI position (checing visibility)
            if (_panel.visible)
            {
                _inst.x = _abs_x * _scale_x;
                _inst.y = _abs_y * _scale_y;
                
                // Scale instances to match visual rendering (base scale * component scale)
                _inst.image_xscale = _scale_x * _slot_scale;
                _inst.image_yscale = _scale_y * _slot_scale;
            }
            else
            {
                _inst.x = -10000;
                _inst.y = -10000;
            }
        }
    }
    
    // Note: Armor and accessory positioning should be handled by the modular inventory panel definition (datagen).
    // The previous legacy fallback has been removed.
}

