function render_menu_title(_xoffset, _yoffset)
{
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_align(fa_center, fa_middle);
    
    render_text(_xoffset + x, _yoffset + y, text, 1.5, 1.5);
    
    draw_set_align(_halign, _valign);
}