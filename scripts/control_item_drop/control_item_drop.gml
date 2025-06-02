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
        spawn_floating_text(x, y, "TEST", 0, -2.4);
        
        instance_destroy();
    }
}