on_window_resize = function()
{
    atla_repair_all();
    
    control_update_gui_size();
    
    if (!instance_exists(obj_Game_Control)) exit;
    
    if (obj_Game_Control.is_opened & WORLD_OPENED_BOOL.INVENTORY)
    {
        obj_Game_Control.surface_refresh |=
            SURFACE_REFRESH_BOOL.INVENTORY_BACKPACK |
            SURFACE_REFRESH_BOOL.INVENTORY_CRAFTABLE;
    }
    else
    {
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOL.INVENTORY_HOTBAR;
    }
    
    obj_Game_Control.surface_refresh |= 
        SURFACE_REFRESH_BOOL.HP |
        SURFACE_REFRESH_BOOL.LIGHTING;
    
    var _chunk_in_view = obj_Game_Control.chunk_in_view;
    var _chunk_in_view_length = obj_Game_Control.chunk_in_view_length;
    
    for (var i = 0; i < _chunk_in_view_length; ++i)
    {
        var _inst = _chunk_in_view[i];
        
        if (!instance_exists(_inst)) continue;
        
        _inst.boolean |= CHUNK_BOOL.SURFACE_LIGHTING_REFRESH;
    }
}

on_window_focus = function()
{
    atla_repair_all();
    
    if (!instance_exists(obj_Game_Control)) exit;
    
    if (obj_Game_Control.is_opened & WORLD_OPENED_BOOL.INVENTORY)
    {
        obj_Game_Control.surface_refresh |=
            SURFACE_REFRESH_BOOL.INVENTORY_BACKPACK |
            SURFACE_REFRESH_BOOL.INVENTORY_CRAFTABLE;
    }
    else
    {
        obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOL.INVENTORY_HOTBAR;
    }
    
    obj_Game_Control.surface_refresh |= 
        SURFACE_REFRESH_BOOL.HP |
        SURFACE_REFRESH_BOOL.LIGHTING;
}

on_window_unfocus = function()
{
    if (!instance_exists(obj_Game_Control)) exit;
    
    if (obj_Game_Control.is_opened & WORLD_OPENED_BOOL.GENERATING_WORLD) exit;
    
    obj_Game_Control.is_opened |= WORLD_OPENED_BOOL.PAUSE;
    
    if (obj_Game_Control.surface_refresh & SURFACE_REFRESH_BOOL.PAUSE)
    {
        obj_Game_Control.surface_refresh ^= SURFACE_REFRESH_BOOL.PAUSE;
    }
    
    control_instance_pause();
}