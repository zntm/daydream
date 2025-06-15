function control_item_drop(_dt)
{
    timer_life -= _dt / GAME_TICK;
    
    if (timer_life <= 0)
    {
        delete item;
        
        instance_destroy();
        
        exit;
    }
    
    control_physics_item_drop(_dt, id);
    
    if (tile_meeting(x, y + 1))
    {
        image_angle = 0;
    }
    else if (xvelocity != 0) && (yvelocity != 0)
    {
        image_angle = point_direction(x, y, x + xvelocity, y + yvelocity);
    }
    /*
    var _id = item.get_id();
    var _amount = item.get_amount();
    
    var _data = global.item_data[$ _id];
    
    var _inventory_max = _data.get_inventory_max();
    
    if (_amount < _inventory_max)
    {
        var _inst = instance_place(x, y, obj_Item_Drop);
        
        if (instance_exists(_inst))
        {
            var _item = _inst.item;
            
            if (_id == _item.get_id())
            {
                var _amount2 = _item.get_amount();
                
                if (_amount + _amount2 <= _inventory_max)
                {
                    item.add_amount(_amount);
                    
                    delete _item;
                    
                    instance_destroy(_inst);
                }
                else
                {
                    item.set_amount(_inventory_max);
                    
                    _item.add_amount(-(_inventory_max - _amount2));
                }
            }
        }
    }
    */
    if (timer_pickup <= 0) && (instance_exists(inst)) && (place_meeting(x, y, inst))
    {
        item = inventory_give(x, y, item);
        
        inventory_refresh_craftable();
        
        if (item == undefined) || (item.get_amount() <= 0)
        {
            instance_destroy();
        }
    }
}