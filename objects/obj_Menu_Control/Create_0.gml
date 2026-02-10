function menu_update_gui_size()
{
    var _window_width = window_get_width();
    var _window_height = window_get_height();
    
    if (_window_width <= 0) || (_window_height <= 0) return;
    
    var _gui_scale = global.gui_scale;
    var _gui_height = round(_gui_scale * global.resolution_height_reference);
    var _gui_width = round(_gui_height * (_window_width / _window_height));
    
    display_set_gui_size(_gui_width, _gui_height);
    
    global.gui_width = _gui_width;
    global.gui_height = _gui_height;
    
    // Position menu renderer to center the 960x540 room content
    if (instance_exists(obj_Menu_Control_Render))
    {
        obj_Menu_Control_Render.xoffset = (_gui_width / _gui_scale - 960) / 2;
        obj_Menu_Control_Render.yoffset = (_gui_height / _gui_scale - 540) / 2;
        
        // Scale the 540p menu to match the higher-res GUI
        obj_Menu_Control_Render.xscale = _gui_scale;
        obj_Menu_Control_Render.yscale = _gui_scale;
    }
}

menu_update_gui_size();

// Update on resize
if (instance_exists(obj_Control))
{
    obj_Control.on_window_resize = menu_update_gui_size;
}

if (!instance_exists(obj_Game_Control))
{
    global.gui_mouse_x = device_mouse_x_to_gui(0);
    global.gui_mouse_y = device_mouse_y_to_gui(0);
}