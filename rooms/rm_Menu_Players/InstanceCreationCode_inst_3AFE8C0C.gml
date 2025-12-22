on_select_hold = function(_x, _y, _id)
{
	y = clamp(mouse_y, 86, 454);
	
	global.players_list_offset = lerp(0, global.players_list_size, normalize(y, 86, 454));
	
	var _offset = global.players_list_offset;
	
	with (all)
	{
		if (id[$ "is_option"])
        {
            y = ystart - _offset;
        }
	}
}

on_step = function()
{
	var _speed = (mouse_wheel_up() - mouse_wheel_down()) * 16 * global.delta_time * GAME_TICK;
	
	if (_speed == 0) exit;
	
    var _ = normalize(y - _speed, 86, 454);
    
	global.players_list_offset = lerp(0, global.players_list_size, _);
	
	var _offset = global.players_list_offset;
	
	with (all)
	{
		if (id[$ "is_option"])
        {
            y = ystart - _offset;
        }
	}
    
    y = lerp(86, 454, _);
}

on_draw_behind = function(_x, _y, _render_xscale, _render_yscale, _colour)
{
	var _y1 = 86 * _render_xscale;
	var _y2 = 454 * _render_yscale;
	
	var _a = (_y1 + _y2) / 2;
	var _scale = (_y2 - _y1) / 8;
	
	draw_sprite_ext(spr_Menu_Indent, 0, _x * _render_xscale, _a, _render_yscale, _scale, 0, c_white, 1);
}