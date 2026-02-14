/// @desc UI Slot Element - inventory slot display with item rendering and interaction
/// Replaces legacy GUISlot with declarative UI system support
/// @param {Real} _x X position
/// @param {Real} _y Y position

function UISlot(_x, _y) : UIElement(_x, _y, 16, 16) constructor {
    // Inventory binding
    inventory_name = "base";
    slot_index = 0;
    
    // Visual configuration
    slot_sprite = spr_Inventory_Slot;
    highlight_sprite = spr_Inventory_Hotbar;
    
    // Allowed item tags (empty = accept all)
    tags = [];
    
    // Interaction mode: "survival" (move) or "creative" (copy)
    mode = "survival";
    
    // State
    is_hovered = false;
    is_selected = false;
    
    // Optional empty-slot icon
    icon_sprite = undefined;
    icon_index = 0;
    
    /// @desc Set the inventory name
    static set_inventory = function(_name) {
        inventory_name = _name;
        return self;
    }
    
    /// @desc Set the slot index
    static set_index = function(_idx) {
        slot_index = _idx;
        return self;
    }
    
    /// @desc Set allowed tags
    static set_tags = function(_tags) {
        if (is_array(_tags)) tags = _tags;
        return self;
    }
    
    /// @desc Set the background sprite
    static set_sprite_background = function(_spr) {
        if (is_string(_spr)) {
            var _asset = asset_get_index(_spr);
            if (_asset != -1) slot_sprite = _asset;
        } else if (sprite_exists(_spr)) {
            slot_sprite = _spr;
        }
        return self;
    }
    
    /// @desc Check if an item with given tags is allowed in this slot
    static accepts_item = function(_item_tags) {
        if (array_length(tags) == 0) return true;
        
        for (var i = 0; i < array_length(tags); i++) {
            for (var j = 0; j < array_length(_item_tags); j++) {
                if (tags[i] == _item_tags[j]) return true;
            }
        }
        return false;
    }
    
    static update = function() {
        if (!visible) return;
        
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _x1 = _abs_x * _base_scale.x;
        var _y1 = _abs_y * _base_scale.y;
        var _w  = width  * _base_scale.x;
        var _h  = height * _base_scale.y;
        
        // Mouse hit test
        var _mx = device_mouse_x_to_gui(0);
        var _my = device_mouse_y_to_gui(0);
        
        if (_mx >= _x1 && _mx <= _x1 + _w && _my >= _y1 && _my <= _y1 + _h) {
            is_hovered = true;
            
            if (mouse_check_button_pressed(mb_left)) {
                if (keyboard_check(vk_shift)) {
                    // Shift+Click: transfer item
                    var _inv = global.inventory;
                    var _source_list = _inv[$ inventory_name];
                    if (_source_list != undefined) {
                        var _item = _source_list[slot_index];
                        if (_item != INVENTORY_EMPTY) {
                            if (inventory_name == "base") {
                                if (array_length(_inv._container) > 0) {
                                    inventory_transfer(inventory_name, slot_index, "_container");
                                }
                            } else if (inventory_name == "_container") {
                                inventory_transfer(inventory_name, slot_index, "base");
                            }
                            sfx_play("phantasia:sfx/ui/click", global.settings.audio_sfx);
                            ui_event("inventory_changed");
                        }
                    }
                } else {
                    // Regular click: select hotbar slot
                    if (inventory_name == "base" && slot_index < 10) {
                        global.inventory_selected_hotbar = slot_index;
                        if (instance_exists(obj_Player)) obj_Player.selected_hotbar = slot_index;
                        sfx_play("phantasia:sfx/ui/click", global.settings.audio_sfx);
                    }
                    
                    emit_event("on_select_release");
                }
            }
        } else {
            is_hovered = false;
        }
        
        update_bindings();
    }
    
    static draw_content = function() {
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _x1 = _abs_x * _base_scale.x;
        var _y1 = _abs_y * _base_scale.y;
        var _sx = _base_scale.x;
        var _sy = _base_scale.y;
        
        // Draw slot background
        if (sprite_exists(slot_sprite)) {
            draw_sprite_ext(slot_sprite, 0, _x1, _y1, _sx, _sy, 0, c_white, 1);
        }
        
        // Draw selected highlight
        if (inventory_name == "base" && slot_index == global.inventory_selected_hotbar) {
            is_selected = true;
            if (sprite_exists(highlight_sprite)) {
                draw_sprite_ext(highlight_sprite, 0, _x1, _y1, _sx, _sy, 0, c_white, 1);
            }
        } else {
            is_selected = false;
        }
        
        // Get item at this slot
        var _inventory = global.inventory[$ inventory_name];
        if (_inventory == undefined) return;
        
        var _item = _inventory[slot_index];
        if (_item == INVENTORY_EMPTY) {
            // Draw empty-slot icon if configured
            if (icon_sprite != undefined) {
                var _spr = is_string(icon_sprite) ? asset_get_index(icon_sprite) : icon_sprite;
                if (_spr != -1 && sprite_exists(_spr)) {
                    draw_sprite_ext(_spr, icon_index, _x1, _y1, _sx, _sy, 0, c_white, 1);
                }
            }
            return;
        }
        
        // Resolve item data
        var _item_data = global.item_data[$ _item.get_id()];
        if (_item_data == undefined) return;
        
        // Draw item sprite
        var _sprite_name = _item_data.get_sprite();
        var _sprite_asset = global.sprite_asset[$ _sprite_name];
        if (_sprite_asset == undefined) return;
        
        var _sprite = _sprite_asset.get_sprite();
        var _index = _item_data.get_inventory_index();
        var _inv_scale = _item_data.get_inventory_scale();
        
        // Center the item in the slot
        var _item_x = (_abs_x + 8) * _sx;
        var _item_y = (_abs_y + 8) * _sy;
        
        draw_sprite_ext(_sprite, _index, _item_x, _item_y,
            _sx * _inv_scale * INVENTORY_ITEM_SCALE_MODIFIER,
            _sy * _inv_scale * INVENTORY_ITEM_SCALE_MODIFIER,
            0, c_white, 1);
        
        // Draw durability bar
        var _dur_data = _item_data.get_item_durability();
        if (_dur_data != undefined) {
            var _max_dur = _dur_data.get_amount();
            var _cur_dur = _item.get_item_durability();
            
            if (_cur_dur != undefined && _max_dur > 0) {
                var _ratio = _cur_dur / _max_dur;
                var _bar_w = 12;
                var _bar_h = 2;
                var _bar_x = (_abs_x + 2) * _sx;
                var _bar_y = (_abs_y + 13) * _sy;
                
                // Background
                draw_sprite_ext(spr_Square, 0, _bar_x, _bar_y, _bar_w * _sx, _bar_h * _sy, 0, c_black, 0.5);
                
                // Fill (red to green gradient)
                var _colour = make_colour_rgb(lerp(255, 0, _ratio), lerp(0, 255, _ratio), 0);
                draw_sprite_ext(spr_Square, 0, _bar_x, _bar_y, _bar_w * _ratio * _sx, _bar_h * _sy, 0, _colour, 1);
            }
        }
        
        // Draw stack count
        var _amount = _item.get_amount();
        if (_amount > 1) {
            var _text_x = (_abs_x + INVENTORY_AMOUNT_TEXT_X_OFFSET) * _sx;
            var _text_y = (_abs_y + INVENTORY_AMOUNT_TEXT_Y_OFFSET) * _sy;
            
            array_push(global.gui_deferred_text, {
                x: _text_x,
                y: _text_y,
                text: string(_amount),
                xscale: _sx * 0.5,
                yscale: _sy * 0.5,
                colour: c_white,
                alpha: 1
            });
        }
    }
}
