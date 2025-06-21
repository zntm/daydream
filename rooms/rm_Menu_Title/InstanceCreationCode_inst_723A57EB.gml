on_draw = function()
{
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_align(fa_right, fa_bottom);
    
    if (PROGRAM_VERSION_PATCH > 0)
    {
        show_debug_message()
        draw_text_transformed(x, y, string(loca_translate("phantasia:menu.title.version.patch"), PROGRAM_VERSION_MAJOR, PROGRAM_VERSION_MINOR, PROGRAM_VERSION_PATCH), FONT_SCALE, FONT_SCALE, 0);
    }
    else
    {
        draw_text_transformed(x, y, string(loca_translate("phantasia:menu.title.version"), PROGRAM_VERSION_MAJOR, PROGRAM_VERSION_MINOR), FONT_SCALE, FONT_SCALE, 0);
    }
    
    draw_set_align(_halign, _valign);
}