function control_instance_pause()
{
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    obj_Menu_Control_Render.xoffset = -_camera_x;
    obj_Menu_Control_Render.yoffset = -_camera_y;
    
    // Account for gui_scale since menus are rendered on the GUI layer which is already scaled
    var _gui_scale = global.gui_scale;
    obj_Menu_Control_Render.xscale = _gui_scale * (global.window_width  / global.camera_width);
    obj_Menu_Control_Render.yscale = _gui_scale * (global.window_height / global.camera_height);
    
    var _layer = layer_get_id("Menu_Pause");
    
    with (all)
    {
        if (layer == _layer)
        {
            x = _camera_x + xstart;
            y = _camera_y + ystart;
        }
    }
}