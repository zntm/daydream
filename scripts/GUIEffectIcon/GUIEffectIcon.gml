/// @description GUI Effect Icon component - displays a single effect with icon and timer
/// @param {Real} _x X position relative to parent
/// @param {Real} _y Y position relative to parent
/// @param {String} _effect_id Effect ID (e.g., "phantasia:poison")

function GUIEffectIcon(_x, _y, _effect_id) : UIElement(_x, _y, 16, 16) constructor
{
    effect_id = _effect_id;
    
    // Temp sprite for testing - use phantasia:item/stone
    static __temp_sprite = "phantasia:item/stone";
    
    static draw_content = function()
    {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _base_scale = ui_get_base_scale();
        var _base_scale_x = _base_scale.x;
        var _base_scale_y = _base_scale.y;
        
        // Apply element scale
        var _scale_x = _base_scale_x * scale;
        var _scale_y = _base_scale_y * scale;
        
        // Get effect data
        var _effect_data = global.effect_data[$ effect_id];
        var _effect_instance = obj_Player.effects[$ effect_id];
        
        if (_effect_instance == undefined) exit;
        
        // Draw background slot
        draw_sprite_ext(spr_Inventory_Slot, 0, _abs_x * _base_scale_x, _abs_y * _base_scale_y, _scale_x, _scale_y, 0, c_white, 1);
        
        // Draw effect icon
        var _icon = _effect_data.get_icon() ?? __temp_sprite;
        var _sprite_asset = global.sprite_asset[$ _icon];
        
        if (_sprite_asset != undefined)
        {
            var _sprite = _sprite_asset.get_sprite();
            var _icon_x = (_abs_x + 8) * _base_scale_x;
            var _icon_y = (_abs_y + 8) * _base_scale_y;
            
            // Tint based on positive/negative
            var _tint = c_white;
            if (_effect_data != undefined) && (_effect_data.is_negative())
            {
                _tint = c_red;
            }
            
            draw_sprite_ext(_sprite, 0, _icon_x, _icon_y, _scale_x * 0.5, _scale_y * 0.5, 0, _tint, 1);
        }
        
        // Draw level indicator if > 1
        var _level = _effect_instance.level;
        if (_level > 1)
        {
            var _text_x = (_abs_x + 14) * _scale_x;
            var _text_y = (_abs_y + 2) * _scale_y;
            
            array_push(global.gui_deferred_text, {
                x: _text_x,
                y: _text_y,
                text: string(_level),
                xscale: _scale_x * 0.4,
                yscale: _scale_y * 0.4,
                colour: c_white,
                alpha: 1
            });
        }
        
        // Draw timer bar
        var _timer = _effect_instance.timer;
        var _max_timer = _timer; // We don't store max, so show relative
        
        if (_timer > 0)
        {
            var _bar_width = 16;
            var _bar_height = 2;
            var _bar_x = (_abs_x + 1) * _base_scale_x;
            var _bar_y = (_abs_y + 16) * _base_scale_y;
            
            // Timer in seconds
            var _seconds = ceil(_timer / GAME_TICK);
            
            // Draw timer text
            array_push(global.gui_deferred_text, {
                x: (_abs_x + 8) * _base_scale_x,
                y: (_abs_y + 18) * _base_scale_y,
                text: string(_seconds) + "s",
                xscale: _scale_x * 0.35,
                yscale: _scale_y * 0.35,
                colour: c_white,
                alpha: 1,
                halign: fa_center,
                valign: fa_bottom
            });
        }
        
        // As per request, copying inventory tooltip placement logic (manual scaling)
        var _base_scale = ui_get_base_scale();
        var _gui_width = global.gui_width;
        var _gui_height = global.gui_height;
        
        var _gui_mouse_x = (window_mouse_get_x() / _window_width)  * _gui_width;
        var _gui_mouse_y = (window_mouse_get_y() / _window_height) * _gui_height;
        
        // Check hover
        var _draw_x = _abs_x * _base_scale_x;
        var _draw_y = _abs_y * _base_scale_y;
        var _draw_w = width * _scale_x;
        var _draw_h = height * _scale_y;
        
        if (point_in_rectangle(_gui_mouse_x, _gui_mouse_y, _draw_x, _draw_y, _draw_x + _draw_w, _draw_y + _draw_h))
        {
            var _name = loca_translate($"{_effect_data.get_namespace()}:effect.{_effect_data.get_id()}.name");
            var _desc = loca_translate($"{_effect_data.get_namespace()}:effect.{_effect_data.get_id()}.description");
            var _text = _name + "\n" + _desc;
            
            var _padding = 8 * _scale_x;
            var _text_scale = 0.5; // Tooltip text size
            
            // draw_set_font(fnt_Default);
            var _text_w = string_width(_text) * _text_scale * _scale_x;
            var _text_h = string_height(_text) * _text_scale * _scale_y;
            
            // Anchor TOP-LEFT (Grow Down-Right)
            // As requested by user ("move anchor to top left")
            
            var _offset_x = -2 * _base_scale_x;
            var _offset_y = -2 * _base_scale_y;
            
            var _tooltip_x = _gui_mouse_x + _offset_x - ((_text_w + (_padding * 2)) / 2);
            var _tooltip_y = _gui_mouse_y + _offset_y - ((_text_h + (_padding * 2)) / 2);
            
            // Background scaling: Sprite is 7x7. Target size / 7 = Scale.
            draw_sprite_ext(spr_Inventory_Tooltip, 0, _tooltip_x - _padding, _tooltip_y - _padding, (_text_w + (_padding * 2)) / 14, (_text_h + (_padding * 2)) / 14, 0, c_white, 1);
            
            // Draw text
            render_text(_tooltip_x, _tooltip_y, _text, _scale_x * _text_scale, _scale_y * _text_scale);
        }
    }
}
