on_draw = function(_xoffset, _yoffset, _xscale, _yscale)
{
    if (y <= -1000) exit;
    
    var _x = (_xoffset + x) * _xscale;
    var _y = (_yoffset + y) * _yscale;
    
    var _chunk_saved_count     = obj_Game_Control.chunk_saved_count;
    var _chunk_saved_count_max = obj_Game_Control.chunk_saved_count_max;
    
    var _t = _chunk_saved_count / _chunk_saved_count_max;
    
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();
    
    draw_set_align(fa_center, fa_middle);
    
    render_text(480 * _xscale, _y - (32 * _yscale), loca_translate("phantasia:menu.saving_world.title"), 1.5 * _xscale, 1.5 * _yscale);
    
    render_text(480 * _xscale, _y - (16 * _yscale), string(loca_translate("phantasia:menu.saving_world.progress"), _chunk_saved_count, _chunk_saved_count_max, round(_t)), _xscale, _yscale);
    
    draw_set_align(_halign, _valign);
    
    var _width      = 256 * _xscale;
    var _width_half = _width / 2;
    
    draw_sprite_ext(spr_Menu_Square, 0, _x - _width_half, _y + (16 * _yscale), (_width / 8),      _yscale, 0, c_white, 1);
    draw_sprite_ext(spr_Menu_Square, 1, _x - _width_half, _y + (16 * _yscale), (_width / 8) * _t, _yscale, 0, c_white, 1);
}