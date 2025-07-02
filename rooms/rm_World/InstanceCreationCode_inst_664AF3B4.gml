on_draw = function(_xoffset, _yoffset)
{
    var _x = _xoffset + x;
    var _y = _yoffset + y;
    
    render_text(_x, _y, loca_translate("phantasia:menu.saving_world.title"));
    
    var _chunk_saved_count     = obj_Game_Control.chunk_saved_count;
    var _chunk_saved_count_max = obj_Game_Control.chunk_saved_count_max;
    
    var _t = _chunk_saved_count / _chunk_saved_count_max;
    
    render_text(_x, _y + 32, string(loca_translate("phantasia:menu.saving_world.progress"), _chunk_saved_count, _chunk_saved_count_max, round(_t)));
    
    draw_sprite_ext(spr_Menu_Square, 0, _x - 128, _y + 128, 256 / 8,      1, 0, c_white, 1);
    draw_sprite_ext(spr_Menu_Square, 1, _x - 128, _y + 128, 256 / 8 * _t, 1, 0, c_white, 1);
}