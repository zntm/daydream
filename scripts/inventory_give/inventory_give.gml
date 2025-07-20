function inventory_give(_x, _y, _item, _text = true)
{
    var _id = _item.get_id();
    var _amount = _item.get_amount();
    
    // var _state = _item.get_state();
    
    var _pickup_amount = 0;
    
    var _data = global.item_data[$ _id];
    var _inventory_max = _data.get_inventory_max();
    
    var _length = global.inventory_length.base;
    
    for (var i = 0; i < _length; ++i)
    {
        var _inventory = global.inventory.base[i];
        
        if (_inventory != INVENTORY_EMPTY) && (_inventory.get_id() == _id)
        {
            var _amount2 = _inventory.get_amount();
            
            if (_amount2 < _inventory_max)
            {
                if (_amount + _amount2 <= _inventory_max)
                {
                    global.inventory.base[@ i].add_amount(_amount);
                    
                    delete _item;
                    
                    _item = undefined;
                    
                    _pickup_amount += _amount;
                    
                    break;
                }
                
                global.inventory.base[@ i].set_amount(_inventory_max);
                
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
            var _inventory = global.inventory.base[i];
            
            if (_inventory == INVENTORY_EMPTY)
            {
                if (_amount <= _inventory_max)
                {
                    global.inventory.base[@ i] = _item;
                    
                    _item = undefined;
                    
                    _pickup_amount += _amount;
                    
                    break;
                }
                
                global.inventory.base[@ i] = variable_clone(_item).set_amount(_inventory_max);
                
                _item.add_amount(-_inventory_max);
                
                _pickup_amount += _inventory_max;
            }
        }
    }
    
    if (_pickup_amount > 0)
    {
        obj_Game_Control.surface_refresh |= ((obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.INVENTORY) ? SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK : SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR);
        
        if (_text)
        {
            var _loca = loca_translate($"{_data.get_namespace()}:item.{_data.get_id()}.name");
            
            if (_pickup_amount > 1)
            {
                spawn_floating_text(_x, _y, string(loca_translate("phantasia:gui.item_tooltip.header.amount"), _loca, _pickup_amount), 0, -3.4);
            }
            else
            {
            	spawn_floating_text(_x, _y, string(loca_translate("phantasia:gui.item_tooltip.header"), _loca), 0, -3.4);
            }
        }
    }
    
    return _item;
}