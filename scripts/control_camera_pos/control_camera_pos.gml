#macro CAMERA_SPEED 0.2

function control_camera_pos(_x, _y)
{
    var _camera_x = lerp(global.camera_x, _x, CAMERA_SPEED);
    var _camera_y = lerp(global.camera_y, _y, CAMERA_SPEED);
    
    global.camera_x = _camera_x;
    global.camera_y = _camera_y;
    
    global.camera_x_real = _x;
    global.camera_y_real = _y;
    
    camera_set_view_pos(view_camera[0], _camera_x, _camera_y);
}