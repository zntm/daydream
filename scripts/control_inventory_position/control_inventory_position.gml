function control_inventory_position()
{
    var _s = global.window_height / 540;
    var _scale_x = _s;
    var _scale_y = _s;
    
    var _inventory_instance = global.inventory_instance;
    
    // Build list of UI instances to process
    var _ui_instances = [];
    
    // Always include hotbar
    if (variable_global_exists("ui_hotbar") && global.ui_hotbar != undefined) {
        array_push(_ui_instances, { instance: global.ui_hotbar, visible: true });
    }
    
    // Include inventory if open
    if (is_opened & WORLD_OPENED_BOOL.INVENTORY) {
        if (variable_global_exists("ui_inventory") && global.ui_inventory != undefined) {
            array_push(_ui_instances, { instance: global.ui_inventory, visible: true });
        }
    } else {
        // Still process inventory slots but mark as hidden
        if (variable_global_exists("ui_inventory") && global.ui_inventory != undefined) {
            array_push(_ui_instances, { instance: global.ui_inventory, visible: false });
        }
    }
    
    // Crafting Panel (old system, keep for now)
    if (variable_global_exists("gui_panel_crafting_modular"))
    {
        var _panel = global.gui_panel_crafting_modular;
        _panel.visible = (is_opened & WORLD_OPENED_BOOL.INVENTORY) && (array_length(_panel.children) > 0);
        
        // Process crafting slots from old system
        var _craft_children = _panel.children;
        var _craft_length = array_length(_craft_children);
        for (var ci = 0; ci < _craft_length; ++ci) {
            var _slot = _craft_children[ci];
            if (!struct_exists(_slot, "inventory_name")) continue;
            
            var _inv_name = _slot.inventory_name;
            var _inv_index = _slot.slot_index;
            var _instances = _inventory_instance[$ _inv_name];
            if (_instances == undefined) continue;
            if (_inv_index >= array_length(_instances)) continue;
            
            var _inst = _instances[_inv_index];
            if (!instance_exists(_inst)) continue;
            
            if (_panel.visible) {
                var _abs_x = struct_exists(_slot, "get_absolute_x") ? _slot.get_absolute_x() : _slot.x;
                var _abs_y = struct_exists(_slot, "get_absolute_y") ? _slot.get_absolute_y() : _slot.y;
                
                _inst.x = global.camera_x + (_abs_x * _scale_x);
                _inst.y = global.camera_y + (_abs_y * _scale_y);
                var _slot_scale = _slot.scale;
                _inst.image_xscale = _scale_x * _slot_scale;
                _inst.image_yscale = _scale_y * _slot_scale;
            } else {
                _inst.x = -10000;
                _inst.y = -10000;
            }
        }
    }
    
    // Process new UI instances (hotbar, inventory)
    for (var p = 0; p < array_length(_ui_instances); p++) {
        var _entry = _ui_instances[p];
        var _ui_inst = _entry.instance;
        var _is_visible = _entry.visible;
        
        // Collect all UISlot elements from this instance
        var _slots = [];
        var _roots = _ui_inst.root_elements;
        for (var r = 0; r < array_length(_roots); r++) {
            ui_collect_slots(_roots[r], _slots);
        }
        
        for (var i = 0; i < array_length(_slots); i++) {
            var _slot = _slots[i];
            var _inv_name = _slot.inventory_name;
            var _inv_index = _slot.slot_index;
            
            var _instances = _inventory_instance[$ _inv_name];
            if (_instances == undefined) continue;
            if (_inv_index >= array_length(_instances)) continue;
            
            var _inst = _instances[_inv_index];
            if (!instance_exists(_inst)) continue;
            
            if (_is_visible) {
                var _abs_x = _slot.get_absolute_x();
                var _abs_y = _slot.get_absolute_y();
                
                _inst.x = global.camera_x + (_abs_x * _scale_x);
                _inst.y = global.camera_y + (_abs_y * _scale_y);
                _inst.image_xscale = _scale_x;
                _inst.image_yscale = _scale_y;
            } else {
                _inst.x = -10000;
                _inst.y = -10000;
            }
        }
    }
}

