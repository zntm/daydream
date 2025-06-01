function control_floating_text(_dt)
{
    time_life -= _dt / GAME_TICK;
    
    if (time_life <= 0)
    {
        instance_destroy();
        
        exit;
    }
    
    control_physics_y(_dt, 0.14, false);
    
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    var _camera_width  = global.camera_width;
    var _camera_height = global.camera_height;
    
    var _string_width  = string_width(text) / 2;
    var _string_height = string_height(text);
    
    if (!rectangle_in_rectangle(x - _string_width, y - _string_height, x + _string_width, y, _camera_x, _camera_y, _camera_x + _camera_width, _camera_y + _camera_height))
    {
        instance_destroy();
        
        exit;
    }
}