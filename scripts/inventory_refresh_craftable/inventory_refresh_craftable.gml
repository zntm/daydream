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
    
    // Clear modular panel children and instances
    if (variable_global_exists("ui_crafting"))
    {
        if (!variable_global_exists("ui_crafting_slots")) global.ui_crafting_slots = [];
        
        while (array_length(global.ui_crafting_slots) > 0) {
            var _inst = array_pop(global.ui_crafting_slots);
            ui_instance_destroy(_inst);
        }
        
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
            
            var _chest_inventories = (global.crafting_pull_from_chests)
                ? inventory_get_nearby_containers(obj_Player.x, obj_Player.y, TILE_SIZE * 4)
                : [];
            
            for (var j = 0; j < _ingredients_length; ++j)
            {
                var _ingredient = _ingredients[j];
                var _id = _ingredient.id;
                var _amount_needed = _ingredient.amount;
                
                var _total_count = 0;
                
                // Check player inventory first
                for (var k = 0; k < array_length(_inventory); ++k)
                {
                    var _slot = _inventory[k];
                    if (_slot == INVENTORY_EMPTY) continue;
                    var _sid = _slot.get_id();
                    if (is_array(_id) ? (!array_contains(_id, _sid)) : (_sid != _id)) continue;
                    _total_count += _slot.get_amount();
                    if (_total_count >= _amount_needed) break;
                }
                
                // Check nearby chests if still needed
                if (_total_count < _amount_needed)
                {
                    for (var k = 0; k < array_length(_chest_inventories); ++k)
                    {
                        var _chest_inv = _chest_inventories[k];
                        for (var l = 0; l < array_length(_chest_inv); ++l)
                        {
                            var _slot = _chest_inv[l];
                            if (_slot == INVENTORY_EMPTY) continue;
                            var _sid = _slot.get_id();
                            if (is_array(_id) ? (!array_contains(_id, _sid)) : (_sid != _id)) continue;
                            _total_count += _slot.get_amount();
                            if (_total_count >= _amount_needed) break;
                        }
                        if (_total_count >= _amount_needed) break;
                    }
                }
                
                if (_total_count < _amount_needed) break;
                
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
            
            // Spawn Categorized UI Slot
            var _slot_inst = ui_spawn(global.ui_crafting_slot_def, {
                link: { slot_index: _offset },
                parent: global.ui_crafting.root_elements[0]
            });
            array_push(global.ui_crafting_slots, _slot_inst);
            
            ++_offset;
        }
        
        // Update Panel Layout and Visibility
        global.ui_crafting.visible = (obj_Game_Control.is_opened & WORLD_OPENED_BOOL.INVENTORY) && (_offset > 0);
        
        if (variable_instance_exists(global.ui_crafting.root_elements[0], "width")) {
            global.ui_crafting.root_elements[0].width = _offset * 16;
            global.ui_crafting.root_elements[0].recalculate_layout();
        }
        
        // Refresh surfaces (still needed for other systems?)
        if (obj_Game_Control.is_opened & WORLD_OPENED_BOOL.INVENTORY)
        {
            obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOL.INVENTORY_CRAFTABLE;
        }
    }
}