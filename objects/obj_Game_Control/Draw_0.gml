if (obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.GENERATING_WORLD) exit;

var _window_width  = global.window_width;
var _window_height = global.window_height;

if (_window_width <= 0) || (_window_height <= 0) exit;

gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);

var _camera_x = global.camera_x;
var _camera_y = global.camera_y;

var _camera_width  = global.camera_width;
var _camera_height = global.camera_height;

render_pipeline(_camera_x, _camera_y, _camera_width, _camera_height);

gpu_set_blendmode(bm_normal);

draw_rectangle(mouse_x, mouse_y, mouse_x + (2048 * 0.2), mouse_y + (2048 * 0.2), true)

draw_surface_ext(global.carbasa_surface.item, mouse_x, mouse_y, 0.2, 0.2, 0, c_white, 1)