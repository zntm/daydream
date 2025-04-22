var _camera_x = camera_get_view_x(view_camera[0]);
var _camera_y = camera_get_view_y(view_camera[0]);

var _camera_width  = camera_get_view_width(view_camera[0]);
var _camera_height = camera_get_view_height(view_camera[0]);

render_pipeline(_camera_x, _camera_y, _camera_width, _camera_height);

draw_surface(global.carbasa_surface.item, _camera_x, _camera_y + 32)