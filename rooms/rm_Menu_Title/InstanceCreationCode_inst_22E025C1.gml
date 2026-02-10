menu_anchor_position(x, y, GUI_ANCHOR.TOP, room_width, room_height);

var _splash_data = global.menu_data.splash_texts;
var _splash_current_date = _splash_data[$ $"{current_month}_{current_day}"];

text = array_choose(((chance(0.1)) && (_splash_current_date != undefined)) ? _splash_current_date : _splash_data.generic);

on_draw = function(_x, _y, _sx, _sy)
{
    // The logo was authored at scale 2 for 540p.
    // To maintain relative size in high-res GUI, we multiply by the GUI scale (_sx).
    var _logo_lx = 2 * _sx;
    var _logo_ly = 2 * _sy;
    
    draw_sprite_ext(spr_Menu_Title, 0, _x, _y + (4 * _sy), _logo_lx, _logo_ly, 0, c_black, 0.25);
    draw_sprite_ext(spr_Menu_Title, 0, _x, _y,             _logo_lx, _logo_ly, 0, c_white, 1);
    
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_align(fa_middle, fa_center);
    
    // Splash text should be half the size of the logo scale (which was scale 1 in 540p original).
    // So 1 * _sx.
    render_text(_x + (sprite_get_width(spr_Menu_Title) * _logo_lx / 2), _y + (sprite_get_height(spr_Menu_Title) * _logo_ly), text, _sx, _sy, 12, MENU_TITLE_SPLASH_COLOUR);
    
    draw_set_align(_halign, _valign);
}