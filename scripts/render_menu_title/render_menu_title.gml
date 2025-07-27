function render_menu_title(_xoffset, _yoffset, _xscale, _yscale, _text = text)
{
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_align(fa_center, fa_middle);
    
    render_text((_xoffset + x) * _xscale, (_yoffset + y) * _yscale, _text, 1.5 * _xscale, 1.5 * _yscale);
    
    draw_set_align(_halign, _valign);
}