on_draw = function()
{
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_align(fa_right, fa_bottom);
    
    if (PROGRAM_VERSION_PATCH > 0)
    {
        render_text(x, y, string(loca_translate("phantasia:menu.title.version.patch"), PROGRAM_VERSION_MAJOR, PROGRAM_VERSION_MINOR, PROGRAM_VERSION_PATCH));
    }
    else
    {
        render_text(x, y, string(loca_translate("phantasia:menu.title.version"), PROGRAM_VERSION_MAJOR, PROGRAM_VERSION_MINOR));
    }
    
    draw_set_align(_halign, _valign);
}