var _splash_data = global.splash_data;
var _splash_current_date = _splash_data[$ $"{current_month}_{current_day}"];

splash_text = array_choose(((chance(0.1)) && (_splash_current_date != undefined)) ? _splash_current_date : _splash_data.generic);

on_draw = function()
{
    draw_sprite_ext(spr_Menu_Title, 0, x, y + 4, 2, 2, 0, c_black, 0.25);
    draw_sprite_ext(spr_Menu_Title, 0, x, y,     2, 2, 0, c_white, 1);
    
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_align(fa_middle, fa_center);
    
    draw_text_transformed_colour(x + (sprite_get_width(spr_Menu_Title) * 2 / 2), y + (sprite_get_height(spr_Menu_Title) * 2), splash_text, FONT_SCALE, FONT_SCALE, 12, MENU_TITLE_SPLASH_COLOUR, MENU_TITLE_SPLASH_COLOUR, MENU_TITLE_SPLASH_COLOUR, MENU_TITLE_SPLASH_COLOUR, 1);
    
    draw_set_align(_halign, _valign);
}