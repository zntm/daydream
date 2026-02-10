on_draw = function(_x, _y, _sx, _sy, _c)
{
    if (y <= -1000) exit;
    
    var _chunk_saved_count     = obj_Game_Control.chunk_saved_count;
    var _chunk_saved_count_max = obj_Game_Control.chunk_saved_count_max;
    
    var _t = _chunk_saved_count / _chunk_saved_count_max;
    
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_align(fa_center, fa_middle);
    
    // Original was 1.5. Now 1.5 * _sx.
    render_text(480 * _sx, _y - (32 * _sy), loca_translate("phantasia:menu.saving_world.title"), 1.5 * _sx, 1.5 * _sy);
    
    render_text(480 * _sx, _y - (16 * _sy), string(loca_translate("phantasia:menu.saving_world.progress"), _chunk_saved_count, _chunk_saved_count_max, round(_t * 100)), _sx, _sy);
    
    draw_set_align(_halign, _valign);
    
    // Width was 256. 256 * _sx.
    var _width      = 256 * _sx;
    var _width_half = _width / 2;
    
    draw_sprite_ext(spr_Menu_Square, 0, _x - _width_half, _y + (16 * _sy), (_width / 8),      _sy, 0, c_white, 1);
    draw_sprite_ext(spr_Menu_Square, 1, _x - _width_half, _y + (16 * _sy), (_width / 8) * _t, _sy, 0, c_white, 1);
}