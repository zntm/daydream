function control_instance_pause()
{
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    obj_Menu_Control_Render.xoffset = -_camera_x;
    obj_Menu_Control_Render.yoffset = -_camera_y;
    
    with (obj_Menu_Anchor)
    {
        x = _camera_x + xstart;
        y = _camera_y + ystart;
    }
    
    with (obj_Menu_Button)
    {
        x = _camera_x + xstart;
        y = _camera_y + ystart;
    }
}