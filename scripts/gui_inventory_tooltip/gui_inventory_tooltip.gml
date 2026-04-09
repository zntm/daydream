#macro GUI_TOOLTIP_XOFFSET 2
#macro GUI_TOOLTIP_YOFFSET 2

#macro GUI_INVENTORY_TOOLTIP_TEXT_XOFFSET 0
#macro GUI_INVENTORY_TOOLTIP_TEXT_YOFFSET -1

#macro GUI_TOOLTIP_DESCRIPTION_XSCALE 0.6
#macro GUI_TOOLTIP_DESCRIPTION_YSCALE 0.6

#macro GUI_INVENTORY_TOOLTIP_BG_PADDING 8

#macro GUI_INVENTORY_TOOLTIP_PADDING_NAME 8
#macro GUI_INVENTORY_TOOLTIP_PADDING_DESCRIPTION 4


function gui_inventory_tooltip_resolve_target()
{
    var _inventory_mouse = global.inventory.mouse;
    
    if ((_inventory_mouse.index ?? -1) != -1) || (_inventory_mouse.item != INVENTORY_EMPTY)
    {
        return {
            type: _inventory_mouse.type,
            index: _inventory_mouse.index,
            item: _inventory_mouse.item,
            slot_type: INVENTORY_SLOT_TYPE.BASE
        };
    }
    
    var _hover = global.inventory_ui_hover;
    
    if (is_struct(_hover))
    {
        var _type = _hover.inventory_type;
        var _index = _hover.inventory_index;
        var _list = global.inventory[$ _type];
        
        if (_list != undefined) && (_index >= 0) && (_index < array_length(_list))
        {
            return {
                type: _type,
                index: _index,
                item: _list[_index],
                slot_type: _hover.slot_type ?? INVENTORY_SLOT_TYPE.BASE
            };
        }
    }
    
    var _inst = global.inventory_selected_hover;
    
    if (instance_exists(_inst))
    {
        return {
            type: _inst.inventory_type,
            index: _inst.inventory_index,
            item: global.inventory[$ _inst.inventory_type][_inst.inventory_index],
            slot_type: _inst.slot_type
        };
    }
    
    return undefined;
}


function gui_inventory_tooltip_get_loca(_data, _suffix)
{
    var _key = $"{_data.get_namespace()}:item.{_data.get_id()}.{_suffix}";
    var _value = loca_translate(_key);
    
    return (_value == _key) ? undefined : _value;
}


function gui_inventory_tooltip_build_slot_string(_filled, _slots)
{
    var _text = "";
    
    for (var i = 0; i < _slots; ++i)
    {
        _text += (i < _filled) ? "[x]" : "[ ]";
    }
    
    return _text;
}


function gui_inventory_tooltip_build_lines(_item, _data)
{
    var _lines = [];
    var _item_damage = _data.get_item_damage();
    var _hold_type = _data.get_hold_type();
    var _item_armor = _data.get_item_armor();
    
    if (_item_armor != undefined)
    {
        array_push(_lines, {
            text: $"{_item_armor.get_defense()} Defense",
            colour: c_aqua,
            scale: GUI_INVENTORY_STRING_SCALE
        });
    }
    else if ((_data.get_type() & ITEM_TYPE_BIT.TOOL) && (_item_damage > 0))
    {
        var _damage_type = (_hold_type == ITEM_HOLD_TYPE.LAUNCHER) ? "Ranged" : "Melee";
        
        array_push(_lines, {
            text: $"{_item_damage} {_damage_type} Damage",
            colour: c_yellow,
            scale: GUI_INVENTORY_STRING_SCALE
        });
    }
    
    var _durability_def = _data.get_item_durability();
    
    if (_durability_def != undefined)
    {
        array_push(_lines, {
            text: $"Durability {_item.get_item_durability() ?? 0}/{_durability_def.get_amount()}",
            colour: c_lime,
            scale: GUI_INVENTORY_STRING_SCALE
        });
    }
    
    if (inventory_item_has_nested_inventory(_item))
    {
        var _nested_inventory = _item.get_inventory();
        var _used_slots = 0;
        
        for (var i = 0; i < array_length(_nested_inventory); ++i)
        {
            if (_nested_inventory[i] != INVENTORY_EMPTY)
            {
                ++_used_slots;
            }
        }
        
        array_push(_lines, {
            text: $"Stores {_used_slots}/{array_length(_nested_inventory)} items",
            colour: c_silver,
            scale: GUI_INVENTORY_STRING_SCALE
        });
    }
    
    var _enchantment_slots = _data.get_item_enchantment_slots();
    
    if (_enchantment_slots > 0)
    {
        var _enchantments = _item.get_enchantments();
        var _filled = min(array_length(_enchantments), _enchantment_slots);
        
        array_push(_lines, {
            text: $"Enchantment Slots {gui_inventory_tooltip_build_slot_string(_filled, _enchantment_slots)}",
            colour: make_colour_rgb(180, 220, 255),
            scale: GUI_INVENTORY_STRING_SCALE
        });
        
        for (var i = 0; i < array_length(_enchantments); ++i)
        {
            var _entry = _enchantments[i];
            var _name = is_struct(_entry) ? (_entry.name ?? _entry.id ?? "Enchantment") : string(_entry);
            var _level = is_struct(_entry) ? (_entry.level ?? 1) : 1;
            
            array_push(_lines, {
                text: $"+ {_name} {_level}",
                colour: make_colour_rgb(160, 200, 255),
                scale: GUI_INVENTORY_STRING_SCALE
            });
        }
    }
    
    return _lines;
}

function gui_inventory_tooltip(_gui_multiplier_x, _gui_multiplier_y)
{
    var _surface_data = surface_inventory.tooltip;
    var _target = gui_inventory_tooltip_resolve_target();
    
    if (_target == undefined) exit;
    
    var _item = _target.item;
    var _type = _target.type;
    var _index = _target.index;
    
    // if (_index == -1) || ((_surface_data.type == _index) && (_surface_data.index == _index)) exit;
    
    if (_item == INVENTORY_EMPTY)
    {
        var _surface = surface_inventory.tooltip.surface;
        
        if (surface_exists(_surface))
        {
            surface_free(_surface);
            
            surface_inventory.tooltip.surface = -1;
        }
        
        exit;
    }
    
    var _data = global.item_data[$ _item.get_id()];
    
    var _item_name = gui_inventory_tooltip_get_loca(_data, "name") ?? _item.get_id();
    var _item_description = gui_inventory_tooltip_get_loca(_data, "description");
    var _lines = gui_inventory_tooltip_build_lines(_item, _data);
    
    var _sprite = global.sprite_asset[$ _data.get_sprite()];
    
    var _inventory_scale = _data.get_inventory_scale();
    
    var _sprite_xscale = _gui_multiplier_y * _inventory_scale;
    var _sprite_yscale = _gui_multiplier_y * _inventory_scale;
    
    var _sprite_width  = _sprite.get_width();
    var _sprite_height = _sprite.get_height();
    
    var _sprite_xoffset = _sprite_width  / 2;
    var _sprite_yoffset = _sprite_height / 2;
    
    var _surface_width  = (_inventory_scale * _sprite_width) + cuteify_get_width(_item_name) + GUI_INVENTORY_TOOLTIP_PADDING_NAME;
    var _surface_height = (_inventory_scale * _sprite_height);
    
    var _sprite_x = _gui_multiplier_y * _sprite_xoffset;
    var _sprite_y = _gui_multiplier_y * _sprite_yoffset;
    
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
    
    var _name_x = (_sprite_xscale * _sprite_width) + (_gui_multiplier_y * (GUI_INVENTORY_TOOLTIP_TEXT_XOFFSET + GUI_INVENTORY_TOOLTIP_PADDING_NAME));
    var _name_y = _sprite_y - (_sprite_yscale / 2);
    
    if (_item_description != undefined)
    {
        _surface_width  = max(_surface_width, GUI_INVENTORY_STRING_SCALE * cuteify_get_width(_item_description));
        _surface_height += GUI_INVENTORY_TOOLTIP_PADDING_DESCRIPTION + (GUI_INVENTORY_STRING_SCALE * (cuteify_get_height(_item_description) - GUI_INVENTORY_TOOLTIP_TEXT_YOFFSET));
    }
    
    var _line_count = array_length(_lines);
    
    if (_line_count > 0)
    {
        for (var i = 0; i < _line_count; ++i)
        {
            var _line = _lines[i];
            var _line_scale = _line.scale ?? GUI_INVENTORY_STRING_SCALE;
            
            _surface_width = max(_surface_width, _line_scale * cuteify_get_width(_line.text));
            _surface_height += (_line_scale * cuteify_get_height(_line.text)) + 2;
        }
    }
    
    var _surface = surface_inventory.tooltip.surface;
    
    if (!surface_exists(_surface))
    {
        _surface = surface_create(ceil(_surface_width * _gui_multiplier_y), ceil(_surface_height * _gui_multiplier_y));
        
        surface_inventory.tooltip.surface = _surface;
    }
    else
    {
        surface_resize(_surface, ceil(_surface_width * _gui_multiplier_y), ceil(_surface_height * _gui_multiplier_y));
    }
    
    surface_set_target(_surface);
    draw_clear_alpha(c_black, 0);
    
    surface_inventory.tooltip.surface_width  = _surface_width;
    surface_inventory.tooltip.surface_height = _surface_height;
    
    surface_inventory.tooltip.type  = _type;
    surface_inventory.tooltip.index = _index;
    
    draw_set_align(fa_left, fa_center);
    
    var _inventory_index = _data.get_inventory_index();
    
    draw_sprite_ext(_sprite.get_sprite(), _inventory_index, _sprite_x, _sprite_y, _sprite_xscale, _sprite_yscale, 0, c_white, 1);
    
    var _rarity = _data.get_rarity();
    var _rarity_colour = ((_data.get_rarity() != undefined) ? (global.rarity_data[$ _rarity] ?? c_white) : c_white);
    
    render_text(_name_x, _name_y, _item_name, _gui_multiplier_x, _gui_multiplier_y, 0, _rarity_colour);
    
    draw_set_valign(fa_top);
    
    if (_item_description != undefined)
    {
        var _description_x = 0;
        var _description_y = ((GUI_INVENTORY_TOOLTIP_TEXT_YOFFSET + GUI_INVENTORY_TOOLTIP_PADDING_DESCRIPTION + max(_inventory_scale * _sprite_height, cuteify_get_height(_item_name))) * _gui_multiplier_y);
        
        var _description_xscale = _gui_multiplier_y * GUI_INVENTORY_STRING_SCALE;
        var _description_yscale = _gui_multiplier_y * GUI_INVENTORY_STRING_SCALE;
        
        render_text(_description_x, _description_y, _item_description, _description_xscale, _description_yscale);
        
        var _line_y = _description_y + (_description_yscale * cuteify_get_height(_item_description)) + (_gui_multiplier_y * 4);
        
        for (var i = 0; i < _line_count; ++i)
        {
            var _line = _lines[i];
            var _line_scale = _line.scale ?? GUI_INVENTORY_STRING_SCALE;
            var _draw_scale_x = _gui_multiplier_x * _line_scale;
            var _draw_scale_y = _gui_multiplier_y * _line_scale;
            
            render_text(0, _line_y, _line.text, _draw_scale_x, _draw_scale_y, 0, _line.colour ?? c_white);
            
            _line_y += (_draw_scale_y * cuteify_get_height(_line.text)) + (_gui_multiplier_y * 2);
        }
    }
    else
    {
        var _line_y = ((max(_inventory_scale * _sprite_height, cuteify_get_height(_item_name)) + GUI_INVENTORY_TOOLTIP_PADDING_DESCRIPTION) * _gui_multiplier_y);
        
        for (var i = 0; i < _line_count; ++i)
        {
            var _line = _lines[i];
            var _line_scale = _line.scale ?? GUI_INVENTORY_STRING_SCALE;
            var _draw_scale_x = _gui_multiplier_x * _line_scale;
            var _draw_scale_y = _gui_multiplier_y * _line_scale;
            
            render_text(0, _line_y, _line.text, _draw_scale_x, _draw_scale_y, 0, _line.colour ?? c_white);
            
            _line_y += (_draw_scale_y * cuteify_get_height(_line.text)) + (_gui_multiplier_y * 2);
        }
    }
    
    surface_reset_target();
}
