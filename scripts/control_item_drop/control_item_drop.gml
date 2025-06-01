function control_item_drop(_dt)
{
    control_physics_item_drop(_dt, id);
    
    if (instance_exists(inst)) && (place_meeting(x, y, inst))
    {
        instance_destroy();
    }
}