#macro GUI_INVENTORY_AMOUNT_XOFFSET 4
#macro GUI_INVENTORY_AMOUNT_YOFFSET 4

#macro GUI_INVENTORY_STRING_SCALE 0.5

function gui_inventory(_gui_multiplier_x, _gui_multiplier_y)
{
    var _item_data = global.item_data;
    var _gui_inventory = global.gui_inventory;
    
    var _inventory = global.inventory;
    var _inventory_instance = global.inventory_instance;
    var _inventory_length = global.inventory_length;
    
    var _inventory_names = global.inventory_names;
    var _inventory_names_length = array_length(_inventory_names);
    
    for (var i = 0; i < _inventory_names_length; ++i)
    {
        var _inventory_name = _inventory_names[i];
        
        var _inventory_data = _gui_inventory[$ _inventory_name];
        
        var _anchor_type = _inventory_data.anchor_type;
        
        var _surface_width  = _inventory_data.surface_width;
        var _surface_height = _inventory_data.surface_height;
        
        if (_surface_width <= 0) || (_surface_height <= 0) continue;
        
        var _surface_inventory = surface_inventory[$ _inventory_name];
        
        var _surface_slot = _surface_inventory.surface_slot;
        
        if (!surface_exists(_surface_slot))
        {
            _surface_slot = surface_create(ceil(_surface_width / INVENTORY_SLOT_SCALE), ceil(_surface_height / INVENTORY_SLOT_SCALE));
            
            surface_inventory[$ _inventory_name].surface_slot = _surface_slot;
        }
        
        var _sprite_inventory = _inventory_data.sprite;
        
        var _icon = _inventory_data[$ "icon"];
        var _icon_index = _inventory_data[$ "icon_index"];
        
        surface_set_target(_surface_slot);
        draw_clear_alpha(c_black, 0);
        
        var _length = _inventory_length[$ _inventory_name];
        
        var _outline = _inventory_data.outline;
        var _outline_length = array_length(_outline);
        
        for (var j = 0; j < _outline_length; ++j)
        {
            var _ = _outline[j];
            
            draw_sprite_ext(spr_Square, 0, _.xoffset, _.yoffset, _.width, _.height, 0, _.colour, 1);
        }
        
        var _ = _inventory_instance[$ _inventory_name];
        
        if (_inventory_name == "base")
        {
            var _id = _[global.inventory_selected_hotbar];
            
            var _x = (GUI_INVENTORY_SURFACE_PADDING + _id.xoffset) / INVENTORY_SLOT_SCALE;
            var _y = (GUI_INVENTORY_SURFACE_PADDING + _id.yoffset) / INVENTORY_SLOT_SCALE;
            
            draw_sprite_ext(spr_Square, 0, _x - 2, _y - 2, 20, 20, 0, INVENTORY_OUTLINE_COLOUR, 1);
        }
        
        for (var j = 0; j < _length; ++j)
        {
            var _id = _[j];
            
            var _x = (GUI_INVENTORY_SURFACE_PADDING + _id.xoffset) / INVENTORY_SLOT_SCALE;
            var _y = (GUI_INVENTORY_SURFACE_PADDING + _id.yoffset) / INVENTORY_SLOT_SCALE;
            
            draw_sprite_ext(_sprite_inventory, 0, _x, _y, 1, 1, 0, c_white, 1);
            
            if (_icon != undefined)
            {
                draw_sprite_ext(_icon, _icon_index, _x, _y, 1, 1, 0, c_white, 1);
            }
        }
        
        if (_inventory_name == "base")
        {
            var _id = _[global.inventory_selected_hotbar];
            
            var _x = (GUI_INVENTORY_SURFACE_PADDING + _id.xoffset) / INVENTORY_SLOT_SCALE;
            var _y = (GUI_INVENTORY_SURFACE_PADDING + _id.yoffset) / INVENTORY_SLOT_SCALE;
            
            draw_sprite_ext(spr_Inventory_Hotbar, 0, _x, _y, 1, 1, 0, c_white, 1);
        }
        
        surface_reset_target();
        
        var _surface_item = _surface_inventory.surface_item;
        
        if (!surface_exists(_surface_item))
        {
            _surface_item = surface_create(ceil(_surface_width * _gui_multiplier_x), ceil(_surface_height * _gui_multiplier_y));
            
            surface_inventory[$ _inventory_name].surface_item = _surface_item;
        }
        
        surface_set_target(_surface_item);
        draw_clear_alpha(c_black, 0);
        
        var _inventory_category = _inventory[$ _inventory_name];
        
        for (var j = 0; j < _length; ++j)
        {
            var _item = _inventory_category[j];
            
            if (_item == INVENTORY_EMPTY) continue;
            
            var _id = _[j];
            
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
            
            if (_data.get_durability_amount() > 0)
            {
                gui_inventory_durability(_xoffset, _yoffset, _item.get_durability(), _data, _gui_multiplier_x, _gui_multiplier_y);
            }
        }
        
        for (var j = 0; j < _length; ++j)
        {
            var _item = _inventory_category[j];
            
            if (_item == INVENTORY_EMPTY) continue;
            
            var _amount = _item.get_amount();
            
            if (_amount <= 1) continue;
            
            var _id = _[j];
            
            var _x = _gui_multiplier_x * (GUI_INVENTORY_AMOUNT_XOFFSET + (GUI_INVENTORY_SURFACE_PADDING + (INVENTORY_SLOT_DIMENSION_SCALED / 2)) + _id.xoffset);
            var _y = _gui_multiplier_y * (GUI_INVENTORY_AMOUNT_YOFFSET + (GUI_INVENTORY_SURFACE_PADDING + (INVENTORY_SLOT_DIMENSION_SCALED / 2)) + _id.yoffset);
            
            render_text(_x, _y, _amount, _gui_multiplier_x * GUI_INVENTORY_STRING_SCALE, _gui_multiplier_y * GUI_INVENTORY_STRING_SCALE, 0, c_white, 1);
        }
        
        surface_reset_target();
    }
}