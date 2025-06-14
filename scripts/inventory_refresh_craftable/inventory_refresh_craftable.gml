function inventory_refresh_craftable()
{
    inventory_resize("craftable", 0);
    
    inventory_refresh_crafting_station();
    
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
            var _count = 0;
            var _crafting_stations_length = _data.get_crafting_stations_length();
            
            for (var j = 0; j < _crafting_stations_length; ++j)
            {
                if (_crafting_stations[j] > TILE_SIZE * 4) break;
                
                ++_count;
            }
            
            if (_count != _crafting_stations_length) continue;
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
        
        var _inst = instance_create_layer(0, 0, "Instances", obj_Inventory);
        
        _inst.xoffset = 0;
        _inst.yoffset = INVENTORY_SLOT_DIMENSION_SCALED * _offset;
        
        _inst.slot_type = INVENTORY_SLOT_TYPE.ARMOR_HELMET;
        
        _inst.inventory_type  = "craftable";
        _inst.inventory_index = _offset;
        
        global.inventory_instance.craftable[@ _offset] = _inst;
        
        ++_offset;
    }
    
    global.gui_inventory.surface_width  = (GUI_INVENTORY_SURFACE_PADDING * 2) + INVENTORY_SLOT_DIMENSION_SCALED;
    global.gui_inventory.surface_height = (GUI_INVENTORY_SURFACE_PADDING * 2) + (INVENTORY_SLOT_DIMENSION_SCALED * _offset);
    
    global.gui_inventory.outline[@ 0].width  = (INVENTORY_OUTLINE_THICKNESS * 2) + INVENTORY_SLOT_DIMENSION;
    global.gui_inventory.outline[@ 0].height = (INVENTORY_OUTLINE_THICKNESS * 2) + (INVENTORY_SLOT_DIMENSION * _offset);
}