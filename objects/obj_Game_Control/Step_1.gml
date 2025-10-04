if (obj_Game_Control.is_opened & (IS_OPENED_BOOLEAN.GENERATING_WORLD | IS_OPENED_BOOLEAN.EXIT)) exit;

if (global.window_width <= 0) || (global.window_height <= 0)
{
    is_opened |= IS_OPENED_BOOLEAN.PAUSE;
    
    with (obj_Menu_Anchor)
    {
        y = -1000;
    }
    
    with (obj_Menu_Button)
    {
        y = -1000;
    }
    
    with (obj_Menu_Dropdown)
    {
        y = -1000;
    }
    
    with (obj_Menu_Textbox)
    {
        y = -1000;
    }
    
    if (is_opened & IS_OPENED_BOOLEAN.MENU)
    {
        is_opened ^= IS_OPENED_BOOLEAN.MENU;
        
        var _layer = layer_get_id("Menu_Item");
        
        with (all)
        {
            if (layer == _layer)
            {
                instance_destroy();
            }
        }
    }
    
    if (surface_refresh & SURFACE_REFRESH_BOOLEAN.PAUSE)
    {
        surface_refresh ^= SURFACE_REFRESH_BOOLEAN.PAUSE;
    }
    
    control_instance_pause();
}
else if (keyboard_check_pressed(global.settings.input_keyboard_pause))
{
    with (obj_Menu_Anchor)
    {
        y = -1000;
    }
    
    with (obj_Menu_Button)
    {
        y = -1000;
    }
    
    with (obj_Menu_Dropdown)
    {
        y = -1000;
    }
    
    with (obj_Menu_Textbox)
    {
        y = -1000;
    }
    
    if (is_opened & IS_OPENED_BOOLEAN.MENU)
    {
        is_opened ^= IS_OPENED_BOOLEAN.MENU;
        
        var _layer = layer_get_id("Menu_Item");
        
        with (all)
        {
            if (layer == _layer)
            {
                instance_destroy();
            }
        }
    }
    else
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
}