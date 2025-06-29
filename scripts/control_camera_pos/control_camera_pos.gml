#macro CAMERA_SPEED 0.3

function control_camera_pos(_x, _y, _force = false, _delta_time = global.delta_time)
{
    var _camera_x, _camera_y;
    
    if (_force)
    {
        _camera_x = _x;
        _camera_y = _y;
    }
    else
    {
        _camera_x = lerp_delta(global.camera_x, _x, CAMERA_SPEED, _delta_time);
        _camera_y = lerp_delta(global.camera_y, _y, CAMERA_SPEED, _delta_time);
    }
    
    global.camera_x = _camera_x;
    global.camera_y = _camera_y;
    
    global.camera_x_real = _x;
    global.camera_y_real = _y;
    
    camera_set_view_pos_subpixel(view_camera[0], _camera_x, _camera_y);
}

function camera_set_view_pos_subpixel(_cam, _x, _y) {
    var    _sw = surface_get_width(application_surface),
        _vw = camera_get_view_width(_cam),
        _ratio = _vw/_sw;

    _x = round(_x/_ratio)*_ratio;
    _y = round(_y/_ratio)*_ratio;

    camera_set_view_pos(_cam,_x,_y);
}