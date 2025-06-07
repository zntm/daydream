function control_inventory()
{
    if (keyboard_check_pressed(global.settings.input_keyboard_inventory))
    {
        is_opened ^= IS_OPENED_BOOLEAN.INVENTORY;
        
        if (is_opened & IS_OPENED_BOOLEAN.INVENTORY)
        {
            instance_activate_object(obj_Inventory);
        }
        
        surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY;
    }
    
    if !(is_opened & IS_OPENED_BOOLEAN.INVENTORY)
    {
        exit;
    }
    
    control_inventory_position();
    
    var _inst = instance_position(mouse_x, mouse_y, obj_Inventory);
    
    var _mouse = mouse_check_button(mb_left) || mouse_check_button(mb_right);
    
    if (mouse_check_button_pressed(mb_right))
    {
        if (instance_exists(_inst))
        {
            var _type  = _inst.inventory_type;
            var _index = _inst.inventory_index;
            
            var _item = global.inventory[$ _type][_index];
            
            if (_item != INVENTORY_EMPTY)
            {
                global.inventory_selected_backpack.type  = _type;
                global.inventory_selected_backpack.index = _index;
                
                var _amount = _item.get_amount();
                
                global.inventory.mouse.item = variable_clone(_item).set_amount(ceil(_amount / 2));
                
                var _amount2 = floor(_amount / 2);
                
                if (_amount2 <= 0)
                {
                    inventory_delete(_type, _index);
                }
                else
                {
                	_item.set_amount(_amount2);
                }
                
                surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY;
            }
        }
    }
    else if (mouse_check_button_released(mb_right))
    {
        var _inventory_selected_backpack = global.inventory_selected_backpack;
        
        var _type = _inventory_selected_backpack.type;
        var _index = _inventory_selected_backpack.index;
        
        if (_index != -1)
        {
            global.inventory[$ _type][@ _index] = global.inventory.mouse;
            global.inventory_selected_backpack.index = -1;
            
            if (instance_exists(_inst))
            {
                inventory_switch(_type, _index, _inst.inventory_type, _inst.inventory_index); 
            }
        }
        else
        {
            var _item = global.inventory.mouse;
            
            global.inventory[$ _type][_index]
            
        	delete _item;
        }
        
        surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY;
    }
    
    if (mouse_check_button_pressed(mb_left))
    {
        if (instance_exists(_inst))
        {
            var _type  = _inst.inventory_type;
            var _index = _inst.inventory_index;
            
            var _item = global.inventory[$ _type][_index];
            
            if (_item != INVENTORY_EMPTY)
            {
                global.inventory_selected_backpack.type  = _type;
                global.inventory_selected_backpack.index = _index;
                
                global.inventory.mouse = _item;
                global.inventory[$ _type][@ _index] = INVENTORY_EMPTY;
                
                surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY;
            }
        }
    }
    else if (mouse_check_button_released(mb_left))
    {
        var _inventory_selected_backpack = global.inventory_selected_backpack;
        
        var _index = _inventory_selected_backpack.index;
        
        if (_index != -1)
        {
            var _type = _inventory_selected_backpack.type;
            
            global.inventory[$ _type][@ _index] = global.inventory.mouse;
            global.inventory_selected_backpack.index = -1;
            
            if (instance_exists(_inst))
            {
                inventory_switch(_type, _index, _inst.inventory_type, _inst.inventory_index); 
            }
        }
        
        surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY;
    }
    
    global.inventory_selected_hover = _inst;
}