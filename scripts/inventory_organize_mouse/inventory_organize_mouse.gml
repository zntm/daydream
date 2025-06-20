function inventory_organize_mouse(_inst)
{
    if (mouse_check_button_pressed(mb_right)) && (inventory_mouse_select_type == INVENTORY_MOUSE_SELECT_TYPE.NONE)
    {
        if (instance_exists(_inst)) && (_inst.slot_type != INVENTORY_SLOT_TYPE.CRAFTABLE)
        {
            var _type  = _inst.inventory_type;
            var _index = _inst.inventory_index;
            
            var _item = global.inventory[$ _type][_index];
            
            if (_item != INVENTORY_EMPTY)
            {
                sfx_play("phantasia:item.collect");
                
                inventory_mouse_select_type = INVENTORY_MOUSE_SELECT_TYPE.RIGHT;
                
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
                
                surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK;
            }
        }
    }
    else if (mouse_check_button_released(mb_right)) && (inventory_mouse_select_type == INVENTORY_MOUSE_SELECT_TYPE.RIGHT)
    {
        sfx_play("phantasia:item.collect");
        
        if (instance_exists(_inst)) && (_inst.slot_type != INVENTORY_SLOT_TYPE.CRAFTABLE)
        {
            var _type  = _inst.inventory_type;
            var _index = _inst.inventory_index;
            
            var _item = global.inventory[$ _type][_index];
            
            if (_item != INVENTORY_EMPTY)
            {
                var _item2 = global.inventory.mouse.item;
                
                var _id = _item.get_id();
                
                if (_id == _item2.get_id())
                {
                    var _data = global.item_data[$ _id];
                    
                    var _inventory_max = _data.get_inventory_max();
                    
                    var _amount  = _item.get_amount();
                    var _amount2 = _item2.get_amount();
                    
                    if (_amount + _amount2 <= _inventory_max)
                    {
                        global.inventory[$ _type][@ _index].add_amount(_amount2);
                        
                        delete _item2;
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
        }
        
        inventory_mouse_select_type = INVENTORY_MOUSE_SELECT_TYPE.NONE;
        
        global.inventory.mouse.item = INVENTORY_EMPTY;
        
        global.inventory.mouse.type  = "";
        global.inventory.mouse.index = -1;
        
        surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK;
    }
    
    if (mouse_check_button_pressed(mb_left)) && (inventory_mouse_select_type == INVENTORY_MOUSE_SELECT_TYPE.NONE)
    {
        if (instance_exists(_inst)) && (_inst.slot_type != INVENTORY_SLOT_TYPE.CRAFTABLE)
        {
            var _type  = _inst.inventory_type;
            var _index = _inst.inventory_index;
            
            var _item = global.inventory[$ _type][_index];
            
            if (_item != INVENTORY_EMPTY)
            {
                sfx_play("phantasia:item.collect");
                
                inventory_mouse_select_type = INVENTORY_MOUSE_SELECT_TYPE.LEFT;
                
                global.inventory_selected_backpack.type  = _type;
                global.inventory_selected_backpack.index = _index;
                
                global.inventory[$ _type][@ _index] = INVENTORY_EMPTY;
                global.inventory.mouse.item = _item;
                
                global.inventory.mouse.type  = _type;
                global.inventory.mouse.index = _index;
                
                surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK;
            }
        }
    }
    else if (mouse_check_button_released(mb_left)) && (inventory_mouse_select_type == INVENTORY_MOUSE_SELECT_TYPE.LEFT)
    {
        sfx_play("phantasia:item.collect");
        
        if (instance_exists(_inst)) && (_inst.slot_type != INVENTORY_SLOT_TYPE.CRAFTABLE)
        {
            var _type  = _inst.inventory_type;
            var _index = _inst.inventory_index;
            
            var _item = global.inventory[$ _type][_index];
            
            if (_item != INVENTORY_EMPTY)
            {
                var _item2 = global.inventory.mouse.item;
                
                var _id = _item.get_id();
                
                if (_id == _item2.get_id())
                {
                    var _data = global.item_data[$ _id];
                    
                    var _inventory_max = _data.get_inventory_max();
                    
                    var _amount  = _item.get_amount();
                    var _amount2 = _item2.get_amount();
                    
                    if (_amount + _amount2 <= _inventory_max)
                    {
                        global.inventory[$ _type][@ _index].add_amount(_amount2);
                        
                        delete _item2;
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
        }
        
        inventory_mouse_select_type = INVENTORY_MOUSE_SELECT_TYPE.NONE;
        
        global.inventory.mouse.item = INVENTORY_EMPTY;
        
        global.inventory.mouse.type  = "";
        global.inventory.mouse.index = -1;
        
        surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK;
    }
    
    if (mouse_check_button(mb_left)) && ((inventory_mouse_select_type == INVENTORY_MOUSE_SELECT_TYPE.NONE) || (inventory_mouse_select_type == INVENTORY_MOUSE_SELECT_TYPE.CRAFTING))
    {
        if (instance_exists(_inst)) && (_inst.slot_type == INVENTORY_SLOT_TYPE.CRAFTABLE)
        {
            var _item = global.crafting_data[_inst.index];
            var _item2 = global.inventory.mouse.item;
            
            var _id = _item.get_id();
            var _amount = _item.get_amount();
            
            if (_item2 != INVENTORY_EMPTY)
            {
                if (_item2.get_id() == _id) && (_amount + _item2.get_amount() <= global.item_data[$ _id].get_inventory_max())
                {
                    global.inventory.mouse.item.add_amount(_amount);
                    
                    inventory_mouse_select_type = INVENTORY_MOUSE_SELECT_TYPE.CRAFTING;
                }
            }
            else
            {
            	global.inventory.mouse.item = new Inventory(_id, _amount);
                
                inventory_mouse_select_type = INVENTORY_MOUSE_SELECT_TYPE.CRAFTING;
            }
        }
    }
    else if (mouse_check_button_released(mb_left)) && (inventory_mouse_select_type == INVENTORY_MOUSE_SELECT_TYPE.CRAFTING)
    {
        sfx_play("phantasia:item.collect");
        
        if (instance_exists(_inst)) && (_inst.slot_type != INVENTORY_SLOT_TYPE.CRAFTABLE)
        {
            var _type  = _inst.inventory_type;
            var _index = _inst.inventory_index;
            
            var _item = global.inventory[$ _type][_index];
            
            if (_item != INVENTORY_EMPTY)
            {
                var _item2 = global.inventory.mouse.item;
                
                var _id = _item.get_id();
                
                if (_id == _item2.get_id())
                {
                    var _data = global.item_data[$ _id];
                    
                    var _inventory_max = _data.get_inventory_max();
                    
                    var _amount  = _item.get_amount();
                    var _amount2 = _item2.get_amount();
                    
                    if (_amount + _amount2 <= _inventory_max)
                    {
                        global.inventory[$ _type][@ _index].add_amount(_amount2);
                        
                        delete _item2;
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
            inventory_give(0, 0, global.inventory.mouse.item, false);
        }
        
        show_debug_message(global.inventory.mouse.item)
        
        inventory_mouse_select_type = INVENTORY_MOUSE_SELECT_TYPE.NONE;
        
        global.inventory.mouse.item = INVENTORY_EMPTY;
        
        global.inventory.mouse.type  = "";
        global.inventory.mouse.index = -1;
        
        surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK;
    }
}