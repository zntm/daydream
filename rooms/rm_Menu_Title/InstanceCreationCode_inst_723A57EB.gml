menu_anchor_position(x, y, GUI_ANCHOR.BOTTOM_RIGHT, room_width, room_height);

on_draw = function(_x, _y, _sx, _sy)
{
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_align(fa_right, fa_bottom);
    
    // Version text was scale 1 in 540p. 
    // Now it should be scale 1 * _sx in high-res GUI.
    render_text(_x, _y, program_get_version(), _sx, _sy);
    
    draw_set_align(_halign, _valign);
}