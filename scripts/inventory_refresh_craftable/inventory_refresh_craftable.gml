function inventory_refresh_craftable()
{
    // Destroy old instances to prevent leaks/ghosts
    var _old_instances = global.inventory_instance._craftable;
    for (var k = 0; k < array_length(_old_instances); ++k)
    {
        if (instance_exists(_old_instances[k]))
        {
            instance_destroy(_old_instances[k]);
        }
    }
    array_resize(global.inventory_instance._craftable, 0);
    
    // Clear inventory item data for rendering
    global.inventory._craftable = [];
    
    // Clear modular panel children
    if (variable_global_exists("gui_panel_crafting_modular"))
    {
        global.gui_panel_crafting_modular.children = [];
        
        var _inventory = global.inventory.base;
        var _offset = 0;
        
        var _crafting_data = global.crafting_data;
        var _crafting_data_length = array_length(_crafting_data);
        
        for (var i = 0; i < _crafting_data_length; ++i)
        {
            var _data = _crafting_data[i];
            
            var _crafting_stations = _data.get_crafting_stations();
            
            if (_crafting_stations != undefined)
            {
                var _crafting_stations_distance = global.crafting_stations_distance;
                var _continue = true;
                var _crafting_stations_length = _data.get_crafting_stations_length();
                
                for (var j = 0; j < _crafting_stations_length; ++j)
                {
                    if (_crafting_stations_distance[$ _crafting_stations[j]] <= TILE_SIZE * 4)
                    {
                        _continue = false;
                        break;
                    }
                }
                
                if (_continue) continue;
            }
            
            var _ingredients = _data.get_ingredients();
            var _ingredients_length = _data.get_ingredients_length();
            var _count = 0;
            
            for (var j = 0; j < _ingredients_length; ++j)
            {
                var _ingredient = _ingredients[j];
                if (!inventory_contains(_ingredient.id, _ingredient.amount, _inventory)) break;
                ++_count;
            }
            
            if (_count != _ingredients_length) continue;
            
            // Create Data/Collision Instance
            var _inst = instance_create_layer(0, 0, "Instances", obj_Inventory);
            _inst.slot_type = INVENTORY_SLOT_TYPE.CRAFTABLE;
            _inst.inventory_type  = "_craftable";
            _inst.inventory_index = _offset;
            _inst.index = i; // Map to global.crafting_data index
            global.inventory_instance._craftable[@ _offset] = _inst;
            
            // Create Renderable Inventory Item
            var _item_render = new Inventory(_data.get_id(), _data.get_amount());
            global.inventory._craftable[@ _offset] = _item_render;
            
            // Create Visual GUISlot (horizontal layout)
            var _slot = new GUISlot(_offset * INVENTORY_SLOT_DIMENSION, 0, "_craftable", _offset);
            global.gui_panel_crafting_modular.add_child(_slot);
            
            ++_offset;
        }
        
        // Update Panel Layout
        var _width = _offset * INVENTORY_SLOT_DIMENSION;
        var _height = INVENTORY_SLOT_DIMENSION;
        
        global.gui_panel_crafting_modular.width = _width;
        global.gui_panel_crafting_modular.height = _height;
        
        // Position: Bottom Center, above backpack
        // Backpack (bottom=36), Height=64 (4 rows). Top = 100 from bottom.
        // We want crafting at ~104 from bottom.
        global.gui_panel_crafting_modular.offset_y = 104;
        
        // Ensure anchor is correct (initially set, but good to ensure)
        global.gui_panel_crafting_modular.anchor_x = "center";
        global.gui_panel_crafting_modular.anchor_y = "bottom";
        
        global.gui_panel_crafting_modular.recalculate_layout();
        
        // Set visibility based on inventory state and content
        if ((obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.INVENTORY) && (_offset > 0))
        {
            global.gui_panel_crafting_modular.visible = true;
        }
        else
        {
            global.gui_panel_crafting_modular.visible = false;
        }
        
        // Refresh surfaces (still needed for other systems?)
        if (obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.INVENTORY)
        {
            obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_CRAFTABLE;
        }
    }
}