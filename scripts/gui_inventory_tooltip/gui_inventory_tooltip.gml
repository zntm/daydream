#macro GUI_TOOLTIP_XOFFSET 2
#macro GUI_TOOLTIP_YOFFSET 2

#macro GUI_INVENTORY_TOOLTIP_TEXT_XOFFSET 0
#macro GUI_INVENTORY_TOOLTIP_TEXT_YOFFSET -1

#macro GUI_TOOLTIP_DESCRIPTION_XSCALE 0.6
#macro GUI_TOOLTIP_DESCRIPTION_YSCALE 0.6

#macro GUI_INVENTORY_TOOLTIP_BG_PADDING 4

#macro GUI_INVENTORY_TOOLTIP_PADDING_NAME 8
#macro GUI_INVENTORY_TOOLTIP_PADDING_DESCRIPTION 4

function gui_inventory_tooltip(_gui_multiplier_x, _gui_multiplier_y)
{
    var _surface_data = surface_inventory.tooltip;
    /*
    var _inst = global.inventory_selected_hover;
    
    var _item;
    
    if (!instance_exists(_inst))
    {
        var _inventory_selected_backpack = global.inventory_selected_backpack;
        
        _type  = _inventory_selected_backpack.type;
        _index = _inventory_selected_backpack.index;
    }
    else
    {
        _type  = _inst.inventory_type;
        _index = _inst.inventory_index;
    }
    */
    
    var _item = INVENTORY_EMPTY;
    var _type, _index;
    
    var _inventory_mouse = global.inventory.mouse;
    
    var _mouse_type  = _inventory_mouse.type;
    var _mouse_index = _inventory_mouse.index;
    
    if (_mouse_index == -1)
    {
        var _inst = instance_position(mouse_x, mouse_y, obj_Inventory);
        
        if (!instance_exists(_inst)) exit;
        
        _type  = _inst.inventory_type;
        _index = _inst.inventory_index;
        
    	_item = global.inventory[$ _type][_index];
    }
    else
    {
        _type  = _mouse_type;
        _index = _mouse_index;
        
        _item = _inventory_mouse.item;
    }
    
    // if (_index == -1) || ((_surface_data.type == _index) && (_surface_data.index == _index)) exit;
    
    if (_item == INVENTORY_EMPTY) exit;
    
    var _data = global.item_data[$ _item.get_id()];
    
    var _item_name = _item.get_id()//loca_item_name(_item);
    var _item_description = _item.get_id()//loca_item_description(_item);
    
    var _sprite = _data.get_sprite();
    
    var _inventory_scale = _data.get_inventory_scale();
    
    var _sprite_xscale = _gui_multiplier_x * _inventory_scale;
    var _sprite_yscale = _gui_multiplier_y * _inventory_scale;
    
    var _sprite_width  = _data.get_sprite_width();
    var _sprite_height = _data.get_sprite_height();
    
    var _sprite_xoffset = _sprite_width  / 2;
    var _sprite_yoffset = _sprite_height / 2;
    
    var _surface_width  = (_inventory_scale * _sprite_width) + string_width(_item_name) + GUI_INVENTORY_TOOLTIP_PADDING_NAME;
    var _surface_height = (_inventory_scale * _sprite_height);
    
    var _sprite_x = (_gui_multiplier_x * _sprite_xoffset);
    var _sprite_y = (_gui_multiplier_y * _sprite_yoffset);
    
    if (_sprite_xoffset < TILE_SIZE / 2)
    {
        _surface_width += (TILE_SIZE / 2) - _sprite_xoffset;
        
        _sprite_xoffset = TILE_SIZE / 2;
    }
    else
    {
        _sprite_x -= _sprite_xoffset - (TILE_SIZE / 2);
    }
    
    if (_sprite_yoffset < TILE_SIZE / 2)
    {
        _surface_height += (TILE_SIZE / 2) - _sprite_yoffset;
        
        _sprite_yoffset = TILE_SIZE / 2;
    }
    else
    {
        _sprite_y -= _sprite_yoffset - (TILE_SIZE / 2);
    }
    
    var _name_x = (_sprite_xscale * _sprite_width) + (_gui_multiplier_x * (GUI_INVENTORY_TOOLTIP_TEXT_XOFFSET + GUI_INVENTORY_TOOLTIP_PADDING_NAME));
    var _name_y = _sprite_y - (_sprite_yscale / 2);
    
    if (_item_description != undefined)
    {
        _surface_width  = max(_surface_width, GUI_INVENTORY_STRING_SCALE * string_width(_item_description));
        _surface_height += GUI_INVENTORY_TOOLTIP_PADDING_DESCRIPTION + (GUI_INVENTORY_STRING_SCALE * (string_height(_item_description) - GUI_INVENTORY_TOOLTIP_TEXT_YOFFSET));
    }
    
    var _surface = surface_inventory.tooltip.surface;
    
    if (!surface_exists(_surface))
    {
        _surface = surface_create(ceil(_surface_width * _gui_multiplier_x), ceil(_surface_height * _gui_multiplier_y));
        
        surface_inventory.tooltip.surface = _surface;
    }
    else
    {
        surface_resize(_surface, ceil(_surface_width * _gui_multiplier_x), ceil(_surface_height * _gui_multiplier_y));
    }
    
    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);
    
    surface_inventory.tooltip.surface_width  = _surface_width;
    surface_inventory.tooltip.surface_height = _surface_height;
    
    surface_inventory.tooltip.type  = _type;
    surface_inventory.tooltip.index = _index;
    
    draw_set_align(fa_left, fa_center);
    
    draw_sprite_ext(_sprite, 0, _sprite_x, _sprite_y, _sprite_xscale, _sprite_yscale, 0, c_white, 1);
    
    // var _rarity = _data.get_rarity();
    var _rarity_colour = c_white // global.rarity_data[$ ((_rarity != undefined) ? _rarity : "phantasia:common")];
    
    draw_text_transformed_colour(_name_x, _name_y, _item_name, _gui_multiplier_x, _gui_multiplier_y, 0, _rarity_colour, _rarity_colour, _rarity_colour, _rarity_colour, 1);
    
    draw_set_valign(fa_top);
    
    if (_item_description != undefined)
    {
        var _description_x = 0;
        var _description_y = ((GUI_INVENTORY_TOOLTIP_TEXT_YOFFSET + GUI_INVENTORY_TOOLTIP_PADDING_DESCRIPTION + max(_inventory_scale * _sprite_height, string_height(_item_name))) * _gui_multiplier_y);
        
        var _description_xscale = _gui_multiplier_x * GUI_INVENTORY_STRING_SCALE;
        var _description_yscale = _gui_multiplier_y * GUI_INVENTORY_STRING_SCALE;
        
        draw_text_transformed_colour(_description_x, _description_y, _item_description, _description_xscale, _description_yscale, 0, c_white, c_white, c_white, c_white, 1);
    }
    
    surface_reset_target();
}