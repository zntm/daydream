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
                if (global.network_role == RELAY_ROLE.CLIENT)
                {
                    network_send_inventory_action(INVENTORY_ACTION_TYPE.SPLIT, _type, _index, "mouse", 0, ceil(_amount / 2));
                }
                
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
        sfx_play("phantasia:sfx/item/collect", global.settings.audio_sfx);
        
        if (instance_exists(_inst)) && (_inst.slot_type != INVENTORY_SLOT_TYPE.CRAFTABLE)
        {
            var _type  = _inst.inventory_type;
            var _index = _inst.inventory_index;
            
            if (global.network_role == RELAY_ROLE.CLIENT)
            {
                network_send_inventory_action(INVENTORY_ACTION_TYPE.SPLIT, "mouse", 0, _type, _index, 1);
            }
            
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
                        
                        if (_item2 != INVENTORY_EMPTY) inventory_give(0, 0, _item2, global.inventory, false);
                    }
                }
                else
                {
                    if (_item2 != INVENTORY_EMPTY) inventory_give(0, 0, _item2, global.inventory, false);
                }
            }
            else
            {
                global.inventory[$ _type][@ _index] = global.inventory.mouse.item;
            }
        }
        else
        {
            var _mouse = global.inventory.mouse;
            var _target_item = global.inventory[$ _mouse.type][_mouse.index];
            
            if (_target_item == INVENTORY_EMPTY)
            {
                global.inventory[$ _mouse.type][@ _mouse.index] = _mouse.item;
            }
            else
            {
                _target_item.add_amount(_mouse.item.get_amount());
                delete _mouse.item;
            }
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
                sfx_play("phantasia:sfx/item/collect", global.settings.audio_sfx);
                
                inventory_mouse_select_type = INVENTORY_MOUSE_SELECT_TYPE.LEFT;
                
                global.inventory_selected_backpack.type  = _type;
                global.inventory_selected_backpack.index = _index;
                
                if (global.network_role == RELAY_ROLE.CLIENT)
                {
                    network_send_inventory_action(INVENTORY_ACTION_TYPE.MOVE, _type, _index, "mouse", 0, _item.get_amount());
                }
                
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
        sfx_play("phantasia:sfx/item/collect", global.settings.audio_sfx);
        
        if (instance_exists(_inst)) && (_inst.slot_type != INVENTORY_SLOT_TYPE.CRAFTABLE)
        {
            var _type  = _inst.inventory_type;
            var _index = _inst.inventory_index;
            
            if (global.network_role == RELAY_ROLE.CLIENT)
            {
                network_send_inventory_action(INVENTORY_ACTION_TYPE.MOVE, "mouse", 0, _type, _index, global.inventory.mouse.item.get_amount());
            }
            
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
                        
                        if (_item2 != INVENTORY_EMPTY) inventory_give(0, 0, _item2, global.inventory, false);
                    }
                }
                else
                {
                    if (_item2 != INVENTORY_EMPTY) inventory_give(0, 0, _item2, global.inventory, false);
                }
            }
            else
            {
                global.inventory[$ _type][@ _index] = global.inventory.mouse.item;
            }
        }
        else
        {
            var _mouse = global.inventory.mouse;
            var _target_item = global.inventory[$ _mouse.type][_mouse.index];
            
            if (_target_item == INVENTORY_EMPTY)
            {
                global.inventory[$ _mouse.type][@ _mouse.index] = _mouse.item;
            }
            else
            {
                _target_item.add_amount(_mouse.item.get_amount());
                delete _mouse.item;
            }
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
            timer_crafting += global.delta_time;
            
            if (timer_crafting >= timer_crafting_max)
            {
                timer_crafting %= timer_crafting_max;
                
                timer_crafting_max = max(timer_crafting_max - 0.04, 0.08);
                
                sfx_play("phantasia:sfx/item/collect", global.settings.audio_sfx);
                
                var _index = _inst.index;
                
                var _item = global.crafting_data[_index];
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
                
                if (global.network_role == RELAY_ROLE.CLIENT)
                {
                    network_send_inventory_action(INVENTORY_ACTION_TYPE.CRAFT, "base", _index, "mouse", 0, _amount);
                }
                
                inventory_craft_clear(_index);
                
                with (obj_Inventory)
                {
                    if (inventory_type == "_craftable")
                    {
                        instance_destroy();
                    }
                }
                
                inventory_refresh_craftable();
                
                surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK | SURFACE_REFRESH_BOOLEAN.INVENTORY_CRAFTABLE;
            }
        }
    }
    else if (mouse_check_button_released(mb_left)) && (inventory_mouse_select_type == INVENTORY_MOUSE_SELECT_TYPE.CRAFTING)
    {
        sfx_play("phantasia:sfx/item/collect", global.settings.audio_sfx);
        
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
                        
                        if (_item2 != INVENTORY_EMPTY) inventory_give(0, 0, _item2, global.inventory, false);
                    }
                }
                else
                {
                    if (_item2 != INVENTORY_EMPTY) inventory_give(0, 0, _item2, global.inventory, false);
                }
            }
            else
            {
                global.inventory[$ _type][@ _index] = global.inventory.mouse.item;
            }
        }
        else
        {
            var _item_mouse = global.inventory.mouse.item;
            if (_item_mouse != INVENTORY_EMPTY) inventory_give(0, 0, _item_mouse, global.inventory, false);
        }
        
        timer_crafting_max = 0.3;
        timer_crafting = timer_crafting_max;
        
        with (obj_Inventory)
        {
            if (inventory_type == "_craftable")
            {
                instance_destroy();
            }
        }
        
        inventory_refresh_craftable();
        
        inventory_mouse_select_type = INVENTORY_MOUSE_SELECT_TYPE.NONE;
        
        global.inventory.mouse.item = INVENTORY_EMPTY;
        
        global.inventory.mouse.type  = "";
        global.inventory.mouse.index = -1;
        
        surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK | SURFACE_REFRESH_BOOLEAN.INVENTORY_CRAFTABLE;
    }
}