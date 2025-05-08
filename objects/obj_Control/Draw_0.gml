var _camera_x = camera_get_view_x(view_camera[0]);
var _camera_y = camera_get_view_y(view_camera[0]);

var _camera_width  = camera_get_view_width(view_camera[0]);
var _camera_height = camera_get_view_height(view_camera[0]);

render_pipeline(_camera_x, _camera_y, _camera_width, _camera_height);

with (obj_Player)
{
    draw_sprite_ext(sprite_index, 0, x, y, image_xscale, image_yscale, image_angle, (tile_meeting(x, y) ? c_red : c_white), 1);
    
    var _collision_box = entity_value.collision_box;
    
    var _collision_width  = _collision_box.width;
    var _collision_height = _collision_box.height;
    
	var _xscale = abs(image_xscale / 8);
	var _yscale = abs(image_yscale / 8);
    
    var _x1 = x - (_xscale * _collision_width);
    var _y1 = y - (_yscale * _collision_height);
    
    var _x2 = x - 1 + (_xscale * _collision_width);
    var _y2 = y - 1;
    
    draw_rectangle(_x1, _y1, _x2, _y2, true);
}