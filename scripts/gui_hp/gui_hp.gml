#macro GUI_HP_ROW_LENGTH 10
#macro GUI_HP_PER_SPRITE 10

function gui_hp(_hp, _hp_max)
{
    var _length = ceil(_hp_max / GUI_HP_PER_SPRITE);
    
	if (!surface_exists(surface_hp))
	{
        var _surface_width  = 13 * min(GUI_HP_ROW_LENGTH, _length);
        var _surface_height = 12 * ceil(_length / GUI_HP_ROW_LENGTH);
        
		surface_hp = surface_create(_surface_width, _surface_height);
	}
    
	surface_set_target(surface_hp);
	draw_clear_alpha(c_black, 0);
    
    var _hp_clamped = max(_hp, GUI_HP_PER_SPRITE / 2);
    
	for (var i = 0; i < _length; ++i)
	{
        var _index = clamp(ceil((_hp_clamped - (i * GUI_HP_PER_SPRITE)) / (GUI_HP_PER_SPRITE / 2)), 0, 2);
        
        var _x = (i % GUI_HP_ROW_LENGTH) * 13;
        var _y = floor(i / GUI_HP_ROW_LENGTH) * 12;
        
		draw_sprite_ext(spr_GUI_HP, _index, _x, _y, 1, 1, 0, c_white, 1);
	}
    
    surface_reset_target();
}