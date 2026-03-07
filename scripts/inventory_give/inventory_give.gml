function inventory_give(_x, _y, _item, _inventory_target = global.inventory, _text = true, _out_changed_slots = undefined)
{
    if (_item == INVENTORY_EMPTY) return INVENTORY_EMPTY;
    
    var _id = _item.get_id();
    var _amount = _item.get_amount();
    
    var _pickup_amount = 0;
    
    var _data = global.item_data[$ _id];
    
    if (_data == undefined)
    {
        PRINT($"[inventory_give] Failed to give item '{_id}': item data not found.");

        return _item;
    }

    var _inventory_max = _data.get_inventory_max();
    
    var _length = global.inventory_length.base;
    
    for (var i = 0; i < _length; ++i)
    {
        var _inventory = _inventory_target.base[i];
        
        if (_inventory != INVENTORY_EMPTY) && (_inventory.get_id() == _id)
        {
            var _amount2 = _inventory.get_amount();
            
            if (_amount2 < _inventory_max)
            {
                if (_amount + _amount2 <= _inventory_max)
                {
                    _inventory_target.base[@ i].add_amount(_amount);
                    
                    if (is_array(_out_changed_slots)) array_push(_out_changed_slots, i);
                    
                    delete _item;
                    
                    _item = undefined;
                    
                    _pickup_amount += _amount;
                    
                    break;
                }
                
                _inventory_target.base[@ i].set_amount(_inventory_max);
                
                if (is_array(_out_changed_slots)) array_push(_out_changed_slots, i);
                
                var _amount3 = _inventory_max - _amount2;
                
                _item.add_amount(-_amount3);
                
                _pickup_amount += _amount3;
            }
        }
    }
    
    if (_item != undefined) && (_item.get_amount() > 0)
    {
        for (var i = 0; i < _length; ++i)
        {
            var _inventory = _inventory_target.base[i];
            
            if (_inventory == INVENTORY_EMPTY)
            {
                if (_amount <= _inventory_max)
                {
                    _inventory_target.base[@ i] = _item;
                    
                    if (is_array(_out_changed_slots)) array_push(_out_changed_slots, i);
                    
                    _item = undefined;
                    
                    _pickup_amount += _amount;
                    
                    break;
                }
                
                _inventory_target.base[@ i] = variable_clone(_item).set_amount(_inventory_max);
                
                if (is_array(_out_changed_slots)) array_push(_out_changed_slots, i);
                
                _item.add_amount(-_inventory_max);
                
                _pickup_amount += _inventory_max;
            }
        }
    }
    
    if (_pickup_amount > 0)
    {
        // Only show UI feedback if we modified the local player's inventory (global.inventory)
        if (_inventory_target == global.inventory)
        {
            obj_Game_Control.surface_refresh |= ((obj_Game_Control.is_opened & WORLD_OPENED_BOOL.INVENTORY) ? SURFACE_REFRESH_BOOL.INVENTORY_BACKPACK : SURFACE_REFRESH_BOOL.INVENTORY_HOTBAR);
            
            if (_text)
            {
                var _loca = loca_translate($"{_data.get_namespace()}:item.{_data.get_id()}.name");
                
                if (_pickup_amount > 1)
                {
                    spawn_floating_text(_x, _y, string(loca_translate("phantasia:gui.item_tooltip.header.amount"), _loca, _pickup_amount), 0, -3.9);
                }
                else
                {
                    spawn_floating_text(_x, _y, string(loca_translate("phantasia:gui.item_tooltip.header"), _loca), 0, -3.9);
                }
            }
        }
    }
    
    return _item;
}
