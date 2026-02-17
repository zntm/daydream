#macro CAMERA_SPEED 0.2

/// @desc Control camera position.
/// @param {real} _x The x position.
/// @param {real} _y The y position.
/// @param {bool} [_force] OPTIONAL! Force the camera to the new position.
function control_camera_pos(_x, _y, _force = false)
{
    var _camera_x, _camera_y;
    
    _y = clamp(_y, 0, global.world_data[$ global.world_save_data.dimension].get_world_height() * TILE_SIZE);
    
    if (_force)
    {
        _camera_x = _x;
        _camera_y = _y;
    }
    else
    {
        _camera_x = lerp(global.camera_x, _x, CAMERA_SPEED);
        _camera_y = lerp(global.camera_y, _y, CAMERA_SPEED);
    }
    
    global.camera_x = _camera_x;
    global.camera_y = _camera_y;
    
    global.camera_x_real = _x;
    global.camera_y_real = _y;
    
    /* fix sub-pixel camera positioning to minimize chunk edge visual bugs */
    var _ratio = camera_get_view_width(view_camera[0]) / surface_get_width(application_surface);
    
    camera_set_view_pos(
        view_camera[0],
        round(_camera_x / _ratio) * _ratio,
        round(_camera_y / _ratio) * _ratio
    );
}