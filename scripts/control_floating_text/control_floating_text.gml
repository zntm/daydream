function control_floating_text(_dt)
{
    time_life -= _dt / GAME_TICK;
    
    if (time_life <= 0)
    {
        instance_destroy();
        
        exit;
    }
    
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    var _camera_width  = global.camera_width;
    var _camera_height = global.camera_height;
    
    if (!rectangle_in_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, _camera_x, _camera_y, _camera_x + _camera_width, _camera_y + _camera_height))
    {
        instance_destroy();
        
        exit;
    }
    
    control_physics_y(_dt, 0.14, false);
}