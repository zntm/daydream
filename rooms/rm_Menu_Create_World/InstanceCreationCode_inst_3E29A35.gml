if (global.current_world[$ "difficulty"] == undefined)
{
    global.current_world.difficulty = 1.0;
}

slider_x_min = 344;
slider_x_max = 608;

xoffset = 0;

var _t = normalize(global.current_world.difficulty, 0.5, 2.5);
x = lerp(slider_x_min, slider_x_max, _t);

on_select = function()
{
    xoffset = x - mouse_x;
}

on_select_hold = function()
{
    var _x = mouse_x + xoffset;
    
    x = clamp(_x, slider_x_min, slider_x_max);
    
    var _t = normalize(x, slider_x_min, slider_x_max);
    
    var _steps = 4;
    _t = round(_t * _steps) / _steps;
    
    x = lerp(slider_x_min, slider_x_max, _t);
    
    global.current_world.difficulty = lerp(0.5, 2.5, _t);
}

on_draw_behind = function(_x, _y, _xscale, _yscale, _colour)
{
    var _width = (slider_x_max - slider_x_min) * _xscale;
    var _mid = (slider_x_max + slider_x_min) / 2;
    
    var _render_xoffset = 0;
    var _render_yoffset = 0;
    
    var _screen_mid = (_render_xoffset + _mid) * _xscale;
    
    var _track_x = (slider_x_min + slider_x_max) / 2;
    
    var _screen_track_x = (_render_xoffset + _track_x) * _xscale;
    var _screen_track_y = (_render_yoffset + y) * _yscale;
    
    draw_sprite_ext(spr_Menu_Indent, 0, _screen_track_x, _screen_track_y, _width / 8, 16 / 8, 0, c_white, 1); 
    
    var _difficulty = global.current_world.difficulty;
    
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_align(fa_left, fa_bottom);
    render_text((_render_xoffset + slider_x_min) * _xscale, (_render_yoffset + y - 24) * _yscale, "Difficulty", _xscale, _yscale);
    
    draw_set_align(fa_right, fa_bottom);
    render_text((_render_xoffset + slider_x_max) * _xscale, (_render_yoffset + y - 24) * _yscale, string_format(_difficulty, 1, 1), _xscale, _yscale);

    draw_set_align(_halign, _valign);
}