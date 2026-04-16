/// @description GUI Effect Icon component - displays a single effect with icon and timer
/// @param {Real} _x X position relative to parent
/// @param {Real} _y Y position relative to parent
/// @param {String} _effect_id Effect ID (e.g., "phantasia:poison")

function GUIEffectIcon(_x, _y, _effect_id) : UIElement(_x, _y, 16, 16) constructor
{
    effect_id = _effect_id;
    is_hovered = false;
    
    static get_effect_state = function()
    {
        var _player = control_game_ui_get_local_player();
        if (!instance_exists(_player)) return undefined;
        if (!variable_instance_exists(_player, "effects")) return undefined;

        return _player.effects[$ effect_id];
    }

    static update = function()
    {
        if !(visible) exit;

        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        var _mx = global.gui_mouse_x;
        var _my = global.gui_mouse_y;

        is_hovered = (_mx >= _abs_x) && (_mx <= _abs_x + width)
            && (_my >= _abs_y) && (_my <= _abs_y + height)
            && !(global.ui_hover_consumed ?? false);

        if (is_hovered)
        {
            global.ui_hover_consumed = true;
        }

        update_bindings();
    }
    
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
        
        var _effect_data = global.effect_data[$ effect_id];
        var _effect_instance = get_effect_state();
        
        if (_effect_data == undefined) exit;
        if (_effect_instance == undefined) exit;
        
        var _slot_colour = is_hovered ? merge_colour(c_white, c_aqua, 0.35) : c_white;
        var _slot_alpha = is_hovered ? 1 : 0.92;

        draw_sprite_ext(spr_Inventory_Slot, 0, _abs_x * _base_scale_x, _abs_y * _base_scale_y, _scale_x, _scale_y, 0, _slot_colour, _slot_alpha);
        
        var _icon = _effect_data.get_icon();
        var _sprite_asset = global.sprite_asset[$ _icon];
        
        if (_sprite_asset != undefined)
        {
            var _sprite = _sprite_asset.get_sprite();
            var _icon_x = (_abs_x + 8) * _base_scale_x;
            var _icon_y = (_abs_y + 8) * _base_scale_y;
            
            var _tint = _effect_data.is_negative() ? #ff8a8a : #c6ffd0;
            if (is_hovered)
            {
                _tint = merge_colour(_tint, c_white, 0.45);
            }
            
            draw_sprite_ext(_sprite, 0, _icon_x, _icon_y, _scale_x * 0.5, _scale_y * 0.5, 0, _tint, 1);
        }
        
        var _level = _effect_instance.level;
        if (_level > 1)
        {
            var _text_x = (_abs_x + 13) * _base_scale_x;
            var _text_y = (_abs_y + 3) * _base_scale_y;
            
            array_push(global.gui_deferred_text, {
                x: _text_x,
                y: _text_y,
                text: string(_level),
                xscale: _base_scale_x * 0.4,
                yscale: _base_scale_y * 0.4,
                colour: c_white,
                alpha: 1,
                halign: fa_right,
                valign: fa_top
            });
        }
        
        var _timer = _effect_instance.timer;
        var _max_timer = max(1, _effect_instance.duration_max ?? _timer);
        var _ratio = clamp(_timer / _max_timer, 0, 1);
        
        if (_timer > 0)
        {
            var _bar_width = 14;
            var _bar_height = 2;
            var _bar_x = (_abs_x + 1) * _base_scale_x;
            var _bar_y = (_abs_y + 13) * _base_scale_y;
            
            var _seconds = ceil(_timer / GAME_TICK);

            draw_sprite_ext(spr_Square, 0, _bar_x, _bar_y, _bar_width * _base_scale_x, _bar_height * _base_scale_y, 0, c_black, 0.45);

            if (_ratio > 0)
            {
                var _bar_colour = _effect_data.is_negative() ? #ff6b6b : #70f0a1;
                draw_sprite_ext(spr_Square, 0, _bar_x, _bar_y, (_bar_width * _ratio) * _base_scale_x, _bar_height * _base_scale_y, 0, _bar_colour, 1);
            }

            array_push(global.gui_deferred_text, {
                x: (_abs_x + 8) * _base_scale_x,
                y: (_abs_y + 18) * _base_scale_y,
                text: string(_seconds) + "s",
                xscale: _base_scale_x * 0.35,
                yscale: _base_scale_y * 0.35,
                colour: c_white,
                alpha: 1,
                halign: fa_center,
                valign: fa_bottom
            });
        }
        
        if (is_hovered)
        {
            var _name = loca_translate($"{_effect_data.get_namespace()}:effect.{_effect_data.get_id()}.name");
            var _desc = loca_translate($"{_effect_data.get_namespace()}:effect.{_effect_data.get_id()}.description");
            var _text = _name;

            if (_level > 1)
            {
                _text += " " + string(_level);
            }

            if (_desc != "")
            {
                _text += "\n" + _desc;
            }
            
            var _padding = 8 * _scale_x;
            var _text_scale = 0.5;
            var _text_w = cuteify_get_width(_text) * _text_scale * _scale_x;
            var _text_h = cuteify_get_height(_text) * _text_scale * _scale_y;

            var _tooltip_x = ((_abs_x + 8) * _base_scale_x) - ((_text_w + (_padding * 2)) / 2);
            var _tooltip_y = ((_abs_y - 4) * _base_scale_y) - (_text_h + (_padding * 2));

            draw_sprite_ext(spr_Inventory_Tooltip, 0, _tooltip_x - _padding, _tooltip_y - _padding, (_text_w + (_padding * 2)) / 14, (_text_h + (_padding * 2)) / 14, 0, c_white, 1);
            render_text(_tooltip_x, _tooltip_y, _text, _scale_x * _text_scale, _scale_y * _text_scale);
        }
    }
}
