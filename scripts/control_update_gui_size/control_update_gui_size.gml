function control_update_gui_size(_width, _height)
{
    global.gui_width  = _width;
    global.gui_height = _height;
    
    display_set_gui_size(_width, _height);
    
    // Account for gui_scale since menus are rendered on the GUI layer which is already scaled
    var _gui_scale = global.gui_scale;
    var _scale = _gui_scale * (global.window_height / global.resolution_height_reference);
    
    obj_Menu_Control_Render.xscale = _scale;
    obj_Menu_Control_Render.yscale = _scale;
}
