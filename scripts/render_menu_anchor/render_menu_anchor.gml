function render_menu_anchor(_xoffset, _yoffset)
{
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_align(id[$ "halign"] ?? _halign, id[$ "valign"] ?? _valign);
    
    var _x = _xoffset + x;
    var _y = _yoffset + y;
    
    render_text(_x, _y + image_yscale, text, image_xscale, image_yscale, 0, c_black, 0.25);
    render_text(_x, _y,                text, image_xscale, image_yscale, 0, c_white, 1);
    
    draw_set_align(_halign, _valign);
}