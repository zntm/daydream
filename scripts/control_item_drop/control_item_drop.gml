function control_item_drop(_dt)
{
    time_life -= _dt / GAME_TICK;
    
    if (time_life <= 0)
    {
        delete item;
        
        instance_destroy();
        
        exit;
    }
    
    control_physics_item_drop(_dt, id);
    
    if (time_pickup <= 0) && (instance_exists(inst)) && (place_meeting(x, y, inst))
    {
        item = inventory_give(x, y, item);
        
        if (item == undefined) || (item.get_amount() <= 0)
        {
            instance_destroy();
        }
    }
}