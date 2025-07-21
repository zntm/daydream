function control_update_gui_size(_width, _height)
{
    global.gui_width  = _width;
    global.gui_height = _height;
    
    display_set_gui_size(_width, _height);
    
    obj_Menu_Control_Render.xscale = global.window_width  / global.camera_width;
    obj_Menu_Control_Render.yscale = global.window_height / global.camera_height;
}