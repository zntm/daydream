on_draw = function()
{
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_align(fa_right, fa_bottom);
    
    if (PROGRAM_VERSION_PATCH > 0)
    {
        draw_text(x, y, $"v{PROGRAM_VERSION_MAJOR}.{PROGRAM_VERSION_MINOR}.{PROGRAM_VERSION_PATCH}");
    }
    else
    {
    	draw_text(x, y, $"v{PROGRAM_VERSION_MAJOR}.{PROGRAM_VERSION_MINOR}");
    }
    
    draw_set_align(_halign, _valign);
}