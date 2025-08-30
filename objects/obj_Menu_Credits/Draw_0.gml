gpu_set_blendmode(bm_add);

var _halign = draw_get_halign();
var _valign = draw_get_valign();

draw_set_align(fa_center, fa_middle);

var _delta_time = (delta_time / 1_000_000) * game_get_speed(gamespeed_fps);

var _hue = hue;
var _sat = sat;
var _val = val;

for (var i = 0; i < glow_length; ++i)
{
    var _glow = glow[i];
    
    _glow.value += _glow.increment * _delta_time;
    
    var _colour = make_colour_hsv(_hue + _glow.colour_offset[0], _sat + _glow.colour_offset[1], _val + _glow.colour_offset[2]);
    
    draw_glow(((dsin(_glow.value) + 1) / 2) * room_width, room_height, _glow.scale, _colour, 1);
}

gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);

var _string_height = font_get_size(draw_get_font()) + 8;

var _x = room_width / 2;
var _y = room_height + list_offset;

var _ystart = room_height * 0.25;
var _yend   = room_height * 0.75;

var _offset = 0;

var _credit_data = global.credit_data;
var _length = array_length(_credit_data);

for (var i = 0; i < _length; ++i)
{
    var _credits = _credit_data[i];
    
    var _header = loca_translate($"menu.credits.header.{_credits.header}");
    
    var _y2 = _y + _offset;
    
    render_text(_x, _y2, _header, 1, 1, 0, _credits.colour, 1);
    
    _offset += _string_height;
    
    var _entries = _credits.entries;
    var _entries_length = _credits.entries_length;
    
    for (var j = 0; j < _entries_length; ++j)
    {
        var _entry = _entries[j];
        
        var _name = _entry.name;
        
        var _y3 = _y + _offset;
        
        render_text(_x, _y3, _name, 0.8, 0.8, 0, _entry[$ "colour"] ?? c_white, 1);
        
        _offset += _string_height * 0.8;
    }
}

draw_vignette(0, 0, room_width, room_height, c_black, 0.5);

draw_set_align(_halign, _valign);

gpu_set_blendmode(bm_normal);