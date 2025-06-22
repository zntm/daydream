function gui_inventory_craftable(_gui_multiplier_x, _gui_multiplier_y)
{
    var _crafting_data = global.crafting_data;
    var _item_data = global.item_data;
    
    var _inventory_data = global.gui_inventory.craftable;
    
    var _inventory_instance = global.inventory_instance.craftable;
    
    var _length = array_length(_inventory_instance);
    
    if (_length <= 0) exit;
    
    var _surface_width  = _inventory_data.surface_width;
    var _surface_height = _inventory_data.surface_height;
    
    var _surface_inventory = surface_inventory.craftable;
    
    var _surface_slot = _surface_inventory.surface_slot;
    
    if (!surface_exists(_surface_slot))
    {
        _surface_slot = surface_create(ceil(_surface_width / INVENTORY_SLOT_SCALE), ceil(_surface_height / INVENTORY_SLOT_SCALE));
        
        surface_inventory.craftable.surface_slot = _surface_slot;
    }
    
    var _sprite_inventory = _inventory_data.sprite;
    
    surface_set_target(_surface_slot);
    draw_clear_alpha(c_black, 0);
    
    var _outline = _inventory_data.outline;
    var _outline_length = array_length(_outline);
    
    for (var i = 0; i < _outline_length; ++i)
    {
        var _ = _outline[i];
        
        draw_sprite_ext(spr_Square, 0, _.xoffset, _.yoffset, _.width, _.height, 0, _.colour, 1);
    }
    
    for (var i = 0; i < _length; ++i)
    {
        var _id = _inventory_instance[i];
        
        var _x = (GUI_INVENTORY_SURFACE_PADDING + _id.xoffset) / INVENTORY_SLOT_SCALE;
        var _y = (GUI_INVENTORY_SURFACE_PADDING + _id.yoffset) / INVENTORY_SLOT_SCALE;
        
        draw_sprite_ext(_sprite_inventory, 0, _x, _y, 1, 1, 0, c_white, 1);
    }
    
    surface_reset_target();
    
    var _surface_item = _surface_inventory.surface_item;
    
    if (!surface_exists(_surface_item))
    {
        _surface_item = surface_create(ceil(_surface_width * _gui_multiplier_x), ceil(_surface_height * _gui_multiplier_y));
        
        surface_inventory.craftable.surface_item = _surface_item;
    }
    
    surface_set_target(_surface_item);
    draw_clear_alpha(c_black, 0);
    
    for (var i = 0; i < _length; ++i)
    {
        var _id = _inventory_instance[i];
        var _item = _crafting_data[_id.index];
        
        var _data = _item_data[$ _item.get_id()];
        
        var _xoffset = _id.xoffset;
        var _yoffset = _id.yoffset;
        
        var _x = _gui_multiplier_x * ((GUI_INVENTORY_SURFACE_PADDING + (INVENTORY_SLOT_DIMENSION_SCALED / 2)) + _xoffset);
        var _y = _gui_multiplier_y * ((GUI_INVENTORY_SURFACE_PADDING + (INVENTORY_SLOT_DIMENSION_SCALED / 2)) + _yoffset);
        
        var _sprite = _data.get_sprite();
        var _index  = _data.get_inventory_index();
        
        var _inventory_scale = _data.get_inventory_scale();
        
        var _xscale = _gui_multiplier_x * _inventory_scale;
        var _yscale = _gui_multiplier_y * _inventory_scale;
        
        draw_sprite_ext(_sprite, _index, _x, _y, _xscale, _yscale, 0, c_white, 1);
    }
    
    for (var i = 0; i < _length; ++i)
    {
        var _id = _inventory_instance[i];
        var _item = _crafting_data[_id.index];
        
        var _amount = _item.get_amount();
        
        if (_amount <= 1) continue;
        
        var _x = _gui_multiplier_x * (GUI_INVENTORY_AMOUNT_XOFFSET + (GUI_INVENTORY_SURFACE_PADDING + (INVENTORY_SLOT_DIMENSION_SCALED / 2)) + _id.xoffset);
        var _y = _gui_multiplier_y * (GUI_INVENTORY_AMOUNT_YOFFSET + (GUI_INVENTORY_SURFACE_PADDING + (INVENTORY_SLOT_DIMENSION_SCALED / 2)) + _id.yoffset);
        
        render_text(_x, _y, _amount, _gui_multiplier_x * GUI_INVENTORY_STRING_SCALE, _gui_multiplier_y * GUI_INVENTORY_STRING_SCALE);
    }
    
    surface_reset_target();
}