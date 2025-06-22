if (global.window_width != window_get_width()) || (global.window_height != window_get_height()) && (keyboard_check_pressed(vk_escape))
{
    is_opened ^= IS_OPENED_BOOLEAN.PAUSE;
    
    if (surface_refresh & SURFACE_REFRESH_BOOLEAN.PAUSE)
    {
        surface_refresh ^= SURFACE_REFRESH_BOOLEAN.PAUSE;
    }
}