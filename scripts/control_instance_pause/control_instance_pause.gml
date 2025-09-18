function control_instance_pause()
{
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    obj_Menu_Control_Render.xoffset = -_camera_x;
    obj_Menu_Control_Render.yoffset = -_camera_y;
    
    obj_Menu_Control_Render.xscale = global.window_width  / global.camera_width;
    obj_Menu_Control_Render.yscale = global.window_height / global.camera_height;
    
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