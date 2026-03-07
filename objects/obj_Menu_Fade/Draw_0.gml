var _cx = variable_global_exists("camera_x") ? global.camera_x : 0;
var _cy = variable_global_exists("camera_y") ? global.camera_y : 0;

var _cw = variable_global_exists("camera_width") ? global.camera_width : 960;
var _ch = variable_global_exists("camera_height") ? global.camera_height : 540;

draw_sprite_ext(spr_Square, 0, _cx, _cy, _cw, _ch, 0, c_black, image_alpha);
