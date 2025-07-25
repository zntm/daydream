on_window_resize = function()
{
    carbasa_repair_all();
    
    var _gui_scale = global.gui_scale;
    
    var _gui_width  = round(_gui_scale * global.window_width);
    var _gui_height = round(_gui_scale * global.window_height);
    
    global.gui_scale = _gui_scale;
    
    control_update_gui_size(_gui_width, _gui_height);
    
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
    
    var _chunk_in_view = obj_Game_Control.chunk_in_view;
    var _chunk_in_view_length = obj_Game_Control.chunk_in_view_length;
    
    for (var i = 0; i < _chunk_in_view_length; ++i)
    {
        var _inst = _chunk_in_view[i];
        
        _inst.boolean |= CHUNK_BOOLEAN.SURFACE_LIGHTING_REFRESH;
    }
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
    
    if (obj_Game_Control.surface_refresh & SURFACE_REFRESH_BOOLEAN.PAUSE)
    {
        obj_Game_Control.surface_refresh ^= SURFACE_REFRESH_BOOLEAN.PAUSE;
    }
    
    control_instance_pause();
}