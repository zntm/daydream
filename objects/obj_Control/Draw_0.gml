var _camera_x = global.camera_x;
var _camera_y = global.camera_y;

var _camera_width  = global.camera_width;
var _camera_height = global.camera_height;

render_pipeline(_camera_x, _camera_y, _camera_width, _camera_height);

with (obj_Player)
{
    draw_sprite_ext(sprite_index, 0, x, y, image_xscale, image_yscale, image_angle, c_white, 1);
}