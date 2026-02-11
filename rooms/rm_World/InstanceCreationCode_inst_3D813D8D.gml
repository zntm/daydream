on_window_resize = function()
{
    atla_repair_all();
    
    var _gui_scale = global.gui_scale;
    
    var _gui_height = round(_gui_scale * global.resolution_height_reference);
    var _gui_width  = round(_gui_height * (global.window_width / global.window_height));
    
    global.gui_scale = _gui_scale;
    
    control_update_gui_size(_gui_width, _gui_height);
    
    if (!instance_exists(obj_Game_Control)) return;
    
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
        
        if (!instance_exists(_inst)) continue;
        
        _inst.boolean |= CHUNK_BOOLEAN.SURFACE_LIGHTING_REFRESH;
    }
}

on_window_focus = function()
{
    atla_repair_all();
    
    if (!instance_exists(obj_Game_Control)) return;
    
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
    if (!instance_exists(obj_Game_Control)) return;
    
    if (obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.GENERATING_WORLD) exit;
    
    obj_Game_Control.is_opened |= IS_OPENED_BOOLEAN.PAUSE;
    
    if (obj_Game_Control.surface_refresh & SURFACE_REFRESH_BOOLEAN.PAUSE)
    {
        obj_Game_Control.surface_refresh ^= SURFACE_REFRESH_BOOLEAN.PAUSE;
    }
    
    control_instance_pause();
}