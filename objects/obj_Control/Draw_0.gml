if (window_width <= 0) || (window_height <= 0) exit;

gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);

var _camera_x = global.camera_x;
var _camera_y = global.camera_y;

var _camera_width  = global.camera_width;
var _camera_height = global.camera_height;

render_pipeline(_camera_x, _camera_y, _camera_width, _camera_height);

if (harvest_amount > 0)
{
    render_harvest(_camera_x, _camera_y, _camera_width, _camera_height);
}

with (obj_Inventory)
{
    draw_sprite(spr_Glow_Corner, 0, x, y);
}

gpu_set_blendmode(bm_normal);