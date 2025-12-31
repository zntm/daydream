/// @description GUI Slot component - displays an inventory slot with item
/// @param {Real} _x X position relative to parent
/// @param {Real} _y Y position relative to parent
/// @param {String} _inventory_name Inventory name (e.g., "base", "armor_helmet")
/// @param {Real} _slot_index Index within the inventory

function GUISlot(_x, _y, _inventory_name, _slot_index, _sprite = spr_Inventory_Slot) : GUIComponent(_x, _y, 16, 16) constructor
{
    inventory_name = _inventory_name;
    slot_index = _slot_index;
    slot_sprite = _sprite;
    
    is_hovered = false;
    is_selected = false;
    
    static draw_content = function()
    {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        // Base GUI scale from resolution
        var _gui_scale = global.gui_scale;
        var _base_scale_x = _gui_scale * (global.gui_width / 960);
        var _base_scale_y = _gui_scale * (global.gui_height / 540);
        
        // Apply component scale from datagen
        var _scale_x = _base_scale_x * scale;
        var _scale_y = _base_scale_y * scale;
        
        // Draw slot background
        draw_sprite_ext(slot_sprite, 0, _abs_x * _base_scale_x, _abs_y * _base_scale_y, _scale_x, _scale_y, 0, c_white, 1);
        
        // Check if this is the selected hotbar slot
        if (inventory_name == "base" && slot_index == global.inventory_selected_hotbar)
        {
            is_selected = true;
            draw_sprite_ext(spr_Inventory_Hotbar, 0, _abs_x * _base_scale_x, _abs_y * _base_scale_y, _scale_x, _scale_y, 0, c_white, 1);
        }
        else
        {
            is_selected = false;
        }
        
        // Get item at this slot
        var _inventory = global.inventory[$ inventory_name];
        if (_inventory == undefined) exit;
        
        var _item = _inventory[slot_index];
        if (_item == INVENTORY_EMPTY)
        {
            if (struct_exists(self, "icon_sprite"))
            {
                var _spr = asset_get_index(icon_sprite);
                if (_spr != -1)
                {
                    var _idx = (struct_exists(self, "icon_index")) ? icon_index : 0;
                    draw_sprite_ext(_spr, _idx, _abs_x * _base_scale_x, _abs_y * _base_scale_y, _scale_x, _scale_y, 0, c_white, 1);
                }
            }
            exit;
        }
        
        var _item_data = global.item_data[$ _item.get_id()];
        if (_item_data == undefined) exit;
        
        // Draw item sprite
        var _sprite_name = _item_data.get_sprite();
        var _sprite = global.sprite_asset[$ _sprite_name].get_sprite();
        var _index = _item_data.get_inventory_index();
        var _inventory_scale = _item_data.get_inventory_scale();
        
        // Use base scale for position, component scale for sprite size
        var _item_x = (_abs_x + (8 * scale)) * _base_scale_x;
        var _item_y = (_abs_y + (8 * scale)) * _base_scale_y;
        
        draw_sprite_ext(_sprite, _index, _item_x, _item_y, _scale_x * _inventory_scale * INVENTORY_ITEM_SCALE_MODIFIER, _scale_y * _inventory_scale * INVENTORY_ITEM_SCALE_MODIFIER, 0, c_white, 1);
        
        // Draw durability bar if applicable
        var _durability_data = _item_data.get_item_durability();
        if (_durability_data != undefined)
        {
            var _max_durability = _durability_data.get_amount();
            var _durability = _item.get_item_durability();
            
            if (_durability != undefined) && (_max_durability > 0)
            {
                var _ratio = _durability / _max_durability;
                
                var _bar_width = 12;
                var _bar_height = 2;
                var _bar_x = (_abs_x + 2) * _scale_x;
                var _bar_y = (_abs_y + 13) * _scale_y;
                
                // Background
                draw_sprite_ext(spr_Square, 0, _bar_x, _bar_y, _bar_width * _scale_x, _bar_height * _scale_y, 0, c_black, 0.5);
                
                // Durability fill
                var _colour = make_colour_rgb(lerp(255, 0, _ratio), lerp(0, 255, _ratio), 0);
                draw_sprite_ext(spr_Square, 0, _bar_x, _bar_y, _bar_width * _ratio * _scale_x, _bar_height * _scale_y, 0, _colour, 1);
            }
        }
        
        // Draw amount if > 1
        var _amount = _item.get_amount();
        if (_amount > 1)
        {
            var _text_x = (_abs_x + INVENTORY_AMOUNT_TEXT_X_OFFSET) * _scale_x;
            var _text_y = (_abs_y + INVENTORY_AMOUNT_TEXT_Y_OFFSET) * _scale_y;
            
            array_push(global.gui_deferred_text, {
                x: _text_x,
                y: _text_y,
                text: string(_amount),
                xscale: _scale_x * 0.5,
                yscale: _scale_y * 0.5,
                colour: c_white,
                alpha: 1
            });
        }
    }
}
