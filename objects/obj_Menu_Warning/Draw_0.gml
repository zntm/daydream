var _delta_time = global.delta_time;

gpu_set_blendmode(bm_add);

for (var i = 0; i < glow_length; ++i)
{
    var _glow = glow[i];
    
    draw_glow(_glow.x, _glow.y, _glow.scale, _glow.colour, 1);
}

gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);

var _loca_font_scale = global.loca_font_scale;

var _header_height      = string_height(text_header)      * _loca_font_scale * 4;
var _description_height = string_height(text_description) * _loca_font_scale;

var _x = (room_width  / 2);
var _y = (room_height / 2) - ((_header_height + _description_height + 8) / 4);

draw_set_align(fa_center, fa_middle);

render_text(_x, _y, text_header, 4, 4);
render_text(_x, _y + (_header_height / 2) + 8, text_description);

gpu_set_blendmode(bm_normal);