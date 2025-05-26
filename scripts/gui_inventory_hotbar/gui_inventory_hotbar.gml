function gui_inventory_hotbar(_gui_multiplier_x, _gui_multiplier_y)
{
    var _item_data = global.item_data;
    var _inventory_data = global.gui_inventory.hotbar;
    
    var _inventory = global.inventory.base;
    var _inventory_instance = global.inventory_instance.base;
    
    var _surface_width  = _inventory_data.surface_width;
    var _surface_height = _inventory_data.surface_height;
    
    var _surface_inventory = surface_inventory.hotbar;
    
    var _surface_slot = _surface_inventory.surface_slot;
    
    if (!surface_exists(_surface_slot))
    {
        _surface_slot = surface_create(ceil(_surface_width / INVENTORY_SLOT_SCALE), ceil(_surface_height / INVENTORY_SLOT_SCALE));
        
        surface_inventory.hotbar.surface_slot = _surface_slot;
    }
    
    var _sprite = _inventory_data.sprite;
    
    surface_set_target(_surface_slot);
    draw_clear_alpha(c_black, 0);
    
    var _outline = _inventory_data.outline;
    var _outline_length = array_length(_outline);
    
    for (var j = 0; j < _outline_length; ++j)
    {
        var _ = _outline[j];
        
        draw_sprite_ext(spr_Square, 0, _.xoffset, _.yoffset, _.width, _.height, 0, _.colour, 1);
    }
    
    var _id2 = _inventory_instance[global.inventory_selected_hotbar];
    
    var _x2 = (INVENTORY_GUI_SURFACE_PADDING + _id2.xoffset) / INVENTORY_SLOT_SCALE;
    var _y2 = (INVENTORY_GUI_SURFACE_PADDING + _id2.yoffset) / INVENTORY_SLOT_SCALE;
    
    draw_sprite_ext(spr_Square, 0, _x2 - 1 - INVENTORY_OUTLINE_THICKNESS, _y2 - 1 - INVENTORY_OUTLINE_THICKNESS, 18 + (INVENTORY_OUTLINE_THICKNESS * 2), 18 + (INVENTORY_OUTLINE_THICKNESS * 2), 0, INVENTORY_OUTLINE_COLOUR, 1);
    
    for (var j = 0; j < INVENTORY_LENGTH.ROW; ++j)
    {
        var _id = _inventory_instance[j];
        
        var _x = (INVENTORY_GUI_SURFACE_PADDING + _id.xoffset) / INVENTORY_SLOT_SCALE;
        var _y = (INVENTORY_GUI_SURFACE_PADDING + _id.yoffset) / INVENTORY_SLOT_SCALE;
        
        draw_sprite_ext(_sprite, 0, _x, _y, 1, 1, 0, c_white, 1);
    }
    
    draw_sprite_ext(spr_Inventory_Hotbar, 0, _x2, _y2, 1, 1, 0, c_white, 1);
    
    surface_reset_target();
    
    var _surface_item = _surface_inventory.surface_item;
    
    if (!surface_exists(_surface_item))
    {
        _surface_item = surface_create(ceil(_surface_width * _gui_multiplier_x), ceil(_surface_height * _gui_multiplier_y));
        
        surface_inventory.hotbar.surface_item = _surface_item;
    }

    surface_set_target(_surface_item);
    draw_clear_alpha(c_black, 0);
    
    for (var j = 0; j < INVENTORY_LENGTH.ROW; ++j)
    {
        var _item = _inventory[j];
        
        if (_item == INVENTORY_EMPTY) continue;
        
        var _id = _inventory_instance[j];
        
        var _data = _item_data[$ _item.get_item_id()];
        
        var _xoffset = _id.xoffset;
        var _yoffset = _id.yoffset;
        
        var _x = _gui_multiplier_x * ((INVENTORY_GUI_SURFACE_PADDING + (INVENTORY_SLOT_DIMENSION_SCALED / 2)) + _xoffset);
        var _y = _gui_multiplier_y * ((INVENTORY_GUI_SURFACE_PADDING + (INVENTORY_SLOT_DIMENSION_SCALED / 2)) + _yoffset);
        
        var _inventory_scale = _data.get_inventory_scale();
        
        var _xscale = _gui_multiplier_x * _inventory_scale;
        var _yscale = _gui_multiplier_y * _inventory_scale;
        
        draw_sprite_ext(_data.get_sprite(), 0, _x, _y, _xscale, _yscale, 0, c_white, 1);
        
        if (_data.get_durability() > 0)
        {
            gui_inventory_durability(_xoffset, _yoffset, _item.get_durability(), _data, _gui_multiplier_x, _gui_multiplier_y);
        }
    }
    
    for (var j = 0; j < INVENTORY_LENGTH.ROW; ++j)
    {
        var _item = _inventory[j];
        
        if (_item == INVENTORY_EMPTY) continue;
        
        var _amount = _item.get_amount();
        
        if (_amount <= 1) continue;
        
        var _id = _inventory_instance[j];
        
        var _x = _gui_multiplier_x * (GUI_INVENTORY_AMOUNT_XOFFSET + (INVENTORY_GUI_SURFACE_PADDING + (INVENTORY_SLOT_DIMENSION_SCALED / 2)) + _id.xoffset);
        var _y = _gui_multiplier_y * (GUI_INVENTORY_AMOUNT_YOFFSET + (INVENTORY_GUI_SURFACE_PADDING + (INVENTORY_SLOT_DIMENSION_SCALED / 2)) + _id.yoffset);
        
        draw_text_transformed_colour(_x, _y, _amount, _gui_multiplier_x * GUI_INVENTORY_STRING_SCALE, _gui_multiplier_y * GUI_INVENTORY_STRING_SCALE, 0, c_white, c_white, c_white, c_white, 1);
    }
    
    var _item_holding = _inventory[global.inventory_selected_hotbar];
    
    if (_item_holding != INVENTORY_EMPTY)
    {
        var _x = _gui_multiplier_x * INVENTORY_GUI_SURFACE_PADDING;
        var _y = _gui_multiplier_y * (INVENTORY_GUI_SURFACE_PADDING + INVENTORY_SLOT_DIMENSION_SCALED + 1);
        
        draw_text_transformed(_x, _y, _item_holding, _gui_multiplier_x * GUI_INVENTORY_STRING_SCALE, _gui_multiplier_y * GUI_INVENTORY_STRING_SCALE, 0);
        // draw_text();
    }
    
    surface_reset_target();
}