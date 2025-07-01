if (global.window_width <= 0) || (global.window_height <= 0)
{
    is_opened |= IS_OPENED_BOOLEAN.PAUSE;
    
    surface_refresh |= SURFACE_REFRESH_BOOLEAN.PAUSE;
    
    control_instance_pause();
}
else if (keyboard_check_pressed(global.settings.input_keyboard_pause))
{
    is_opened ^= IS_OPENED_BOOLEAN.PAUSE;
    
    if (is_opened & IS_OPENED_BOOLEAN.PAUSE)
    {
        if (surface_refresh & SURFACE_REFRESH_BOOLEAN.PAUSE)
        {
            surface_refresh ^= SURFACE_REFRESH_BOOLEAN.PAUSE;
        }
        
        control_instance_pause();
    }
    else
    {
    	control_instance_unpause();
    }
}