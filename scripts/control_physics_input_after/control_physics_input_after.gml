function control_physics_input_after(_dt, _id)
{
    with (_id)
    {
        
        if (tile_meeting(x, y + 1))
        {
            jump_pressed = 0;
            
            jump_count = 0;
            timer_coyote = 0;
        }
        
        if (tile_meeting(x, y - 1))
        {
            jump_pressed = infinity;
        }
    }
}