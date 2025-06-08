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
                
                global.inventory.mouse.type  = _type;
                global.inventory.mouse.index = _index;
                
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
        if (instance_exists(_inst))
        {
            var _type  = _inst.inventory_type;
            var _index = _inst.inventory_index;
            
            var _item = global.inventory[$ _type][_index];
            
            if (_item != INVENTORY_EMPTY)
            {
                var _item2 = global.inventory.mouse.item;
                
                var _item_id = _item.get_item_id();
                
                if (_item_id == _item2.get_item_id())
                {
                    var _data = global.item_data[$ _item_id];
                    
                    var _inventory_max = _data.get_inventory_max();
                    
                    var _amount  = _item.get_amount();
                    var _amount2 = _item2.get_amount();
                    
                    if (_amount + _amount2 <= _inventory_max)
                    {
                        global.inventory[$ _type][@ _index].add_amount(_amount2);
                        
                        delete _item2;
                        
                        global.inventory.mouse.item = INVENTORY_EMPTY;
                    }
                    else
                    {
                        global.inventory[$ _type][@ _index].set_amount(_inventory_max);
                        
                        _item2.add_amount(_amount - _inventory_max);
                        
                        inventory_give(0, 0, _item2, false);
                    }
                }
                else
                {
                	inventory_give(0, 0, _item2, false);
                }
            }
            else
            {
            	global.inventory[$ _type][@ _index] = global.inventory.mouse.item;
            }
        }
        else
        {
            var _item = global.inventory.mouse;
            
            global.inventory[$ _item.type][_item.index].add_amount(_item.item.get_amount());
            
        	delete _item.item;
            
            global.inventory.mouse.item = INVENTORY_EMPTY;
        }
        
        global.inventory.mouse.type  = "";
        global.inventory.mouse.index = -1;
        
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
                
                global.inventory[$ _type][@ _index] = INVENTORY_EMPTY;
                global.inventory.mouse.item = _item;
                
                global.inventory.mouse.type  = _type;
                global.inventory.mouse.index = _index;
                
                surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY;
            }
        }
    }
    else if (mouse_check_button_released(mb_left))
    {
        if (instance_exists(_inst))
        {
            var _type  = _inst.inventory_type;
            var _index = _inst.inventory_index;
            
            var _item = global.inventory[$ _type][_index];
            
            if (_item != INVENTORY_EMPTY)
            {
                var _item2 = global.inventory.mouse.item;
                
                var _item_id = _item.get_item_id();
                
                if (_item_id == _item2.get_item_id())
                {
                    var _data = global.item_data[$ _item_id];
                    
                    var _inventory_max = _data.get_inventory_max();
                    
                    var _amount  = _item.get_amount();
                    var _amount2 = _item2.get_amount();
                    
                    if (_amount + _amount2 <= _inventory_max)
                    {
                        global.inventory[$ _type][@ _index].add_amount(_amount2);
                        
                        delete _item2;
                        
                        global.inventory.mouse.item = INVENTORY_EMPTY;
                    }
                    else
                    {
                        global.inventory[$ _type][@ _index].set_amount(_inventory_max);
                        
                        _item2.add_amount(_amount - _inventory_max);
                        
                        inventory_give(0, 0, _item2, false);
                    }
                }
                else
                {
                	inventory_give(0, 0, _item2, false);
                }
            }
            else
            {
            	global.inventory[$ _type][@ _index] = global.inventory.mouse.item;
            }
        }
        else
        {
            var _item = global.inventory.mouse;
            
            global.inventory[$ _item.type][_item.index].add_amount(_item.item.get_amount());
            
        	delete _item.item;
            
            global.inventory.mouse.item = INVENTORY_EMPTY;
        }
        
        global.inventory.mouse.type  = "";
        global.inventory.mouse.index = -1;
        
        surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY;
    }
    
    global.inventory_selected_hover = _inst;
}