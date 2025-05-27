#macro GUI_INVENTORY_DURABILITY_PADDING 2

function gui_inventory_durability(_xoffset, _yoffset, _durability, _data, _gui_multiplier_x, _gui_multiplier_y)
{
    var _durability_max = _data.get_durability_amount();
    
    if (_durability >= _durability_max) exit;
    
    var _percentage = _durability / _durability_max;
    
    var _x = _gui_multiplier_x * (GUI_INVENTORY_SURFACE_PADDING + (INVENTORY_SLOT_SCALE * GUI_INVENTORY_DURABILITY_PADDING) + _xoffset);
    var _y = _gui_multiplier_y * (GUI_INVENTORY_SURFACE_PADDING - (INVENTORY_SLOT_SCALE * (GUI_INVENTORY_DURABILITY_PADDING + 1)) + INVENTORY_SLOT_DIMENSION_SCALED + _yoffset);
    
    var _xscale = _gui_multiplier_x * INVENTORY_SLOT_SCALE * (INVENTORY_SLOT_DIMENSION - (GUI_INVENTORY_DURABILITY_PADDING * 2));
    var _yscale = _gui_multiplier_y * INVENTORY_SLOT_SCALE * 1;
    
    var _durability_bar = tag_get(_data.get_durability_bar());
    
    draw_sprite_ext(spr_Square, 0, _x, _y, _xscale, _yscale, 0, hex_parse(_durability_bar.base_colour), 1);
    
    var _durability_threshold_min = 0;
    var _durability_threshold_max = 1;
    
    var _durability_colour_first = -1;
    var _durability_colour_next  = -1;
    
    var _bar = _durability_bar.data;
    
    var _length = _data.get_durability_bar_length();
    
    for (var l = 0; l < _length; ++l)
    {
        var _durability_data = _bar[l];
        
        var _min_percentage = _durability_data.min_percentage;
        
        _durability_threshold_max = _durability_threshold_min;
        _durability_threshold_min = _min_percentage;
        
        var _colour = _durability_data.colour;
        
        _durability_colour_next  = ((_durability_colour_first == -1) ? _colour : _durability_colour_first);
        _durability_colour_first = _colour;
        
        if (_percentage > _min_percentage) break;
    }
    
    var _t = normalize(_percentage, _durability_threshold_min, _durability_threshold_max);
    
    var _a = hex_parse(_durability_colour_first);
    var _b = hex_parse(_durability_colour_next);
    
    draw_sprite_ext(spr_Square, 0, _x, _y, _xscale * _percentage, _yscale, 0, merge_colour(_a, _b, _t), 1);
}