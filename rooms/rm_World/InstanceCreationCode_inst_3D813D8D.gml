on_window_resize = function()
{
    carbasa_repair_all();
    
    var _gui_scale = global.gui_scale;
    
    global.gui_width  = round(_gui_scale * global.window_width);
    global.gui_height = round(_gui_scale * global.window_height);
    
    if (obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.INVENTORY)
    {
        obj_Game_Control.surface_refresh |=
            SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK |
            SURFACE_REFRESH_BOOLEAN.INVENTORY_CRAFTABLE;
    }
    else
    {
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR;
    }
    
    obj_Game_Control.surface_refresh |= 
        SURFACE_REFRESH_BOOLEAN.HP |
        SURFACE_REFRESH_BOOLEAN.LIGHTING;
}

on_window_focus = function()
{
    carbasa_repair_all();
    
    if (obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.INVENTORY)
    {
        obj_Game_Control.surface_refresh |=
            SURFACE_REFRESH_BOOLEAN.INVENTORY_BACKPACK |
            SURFACE_REFRESH_BOOLEAN.INVENTORY_CRAFTABLE;
    }
    else
    {
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR;
    }
    
    obj_Game_Control.surface_refresh |= 
        SURFACE_REFRESH_BOOLEAN.HP |
        SURFACE_REFRESH_BOOLEAN.LIGHTING;
}

on_window_unfocus = function()
{
    obj_Game_Control.is_opened |= IS_OPENED_BOOLEAN.PAUSE;
    
    obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.PAUSE;
    
    control_instance_pause();
}