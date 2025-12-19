/// @description Initialize the modular GUI system

function gui_init_modular()
{
    // Register component types
    gui_register_component("panel", GUIPanel);
    gui_register_component("slot", GUISlot);
    
    // Create root panel using logical dimensions (reference width 960)
    var _gui_scale = global.gui_scale * (global.gui_width / 960);
    var _logical_width = global.gui_width / _gui_scale;
    var _logical_height = global.gui_height / _gui_scale;
    
    global.gui_root = new GUIPanel(0, 0, _logical_width, _logical_height);
    
    // Load hotbar layout
    var _hotbar_path = "resources/data/guis/hotbar.json";
    if (file_exists(_hotbar_path))
    {
        var _hotbar_json = buffer_load_json(_hotbar_path);
        global.gui_panel_hotbar_modular = gui_load_layout(_hotbar_json, global.gui_root);
        global.gui_panel_hotbar_modular.visible = true;
    }
    else
    {
        // Create hotbar programmatically as fallback
        global.gui_panel_hotbar_modular = new GUIPanel(16, 16, INVENTORY_SLOT_DIMENSION * INVENTORY_LENGTH.ROW, INVENTORY_SLOT_DIMENSION);
        global.gui_root.add_child(global.gui_panel_hotbar_modular);
        
        for (var i = 0; i < INVENTORY_LENGTH.ROW; ++i)
        {
            var _slot = new GUISlot(i * INVENTORY_SLOT_DIMENSION, 0, "base", i);
            global.gui_panel_hotbar_modular.add_child(_slot);
        }
    }
    
    // Load inventory layout
    var _inventory_path = "resources/data/guis/inventory.json";
    if (file_exists(_inventory_path))
    {
        var _inventory_json = buffer_load_json(_inventory_path);
        global.gui_panel_inventory_modular = gui_load_layout(_inventory_json, global.gui_root);
    }
    else
    {
        // Create inventory programmatically as fallback
        global.gui_panel_inventory_modular = new GUIPanel(16, 16, INVENTORY_SLOT_DIMENSION * INVENTORY_LENGTH.ROW, INVENTORY_SLOT_DIMENSION * (INVENTORY_LENGTH.BASE div INVENTORY_LENGTH.ROW));
        global.gui_root.add_child(global.gui_panel_inventory_modular);
        
        for (var i = 0; i < INVENTORY_LENGTH.BASE; ++i)
        {
            var _col = i mod INVENTORY_LENGTH.ROW;
            var _row = i div INVENTORY_LENGTH.ROW;
            var _slot = new GUISlot(_col * INVENTORY_SLOT_DIMENSION, _row * INVENTORY_SLOT_DIMENSION, "base", i);
            global.gui_panel_inventory_modular.add_child(_slot);
        }
    }
    
    // Position inventory at top-left with small offset
    global.gui_panel_inventory_modular.x = 16;
    global.gui_panel_inventory_modular.y = 16;
    global.gui_panel_inventory_modular.visible = false;
    
    show_debug_message("GUI: Modular GUI system initialized");
}
