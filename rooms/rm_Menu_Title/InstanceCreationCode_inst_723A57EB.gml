menu_anchor_position(x, y, GUI_ANCHOR.BOTTOM_RIGHT, room_width, room_height);

on_draw = function()
{
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_align(fa_right, fa_bottom);
    
    render_text(x, y, program_get_version());
    
    draw_set_align(_halign, _valign);
}