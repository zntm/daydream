function UIDropdown(_x, _y, _width, _height) : UIElement(_x, _y, _width, _height) constructor
{
    options = [];
    selected = 0;
    text = "";
    colour = c_white;
    text_scale = 1;

    is_hovered = false;
    is_pressed = false;

    normal_color  = #3a3a4a;
    hover_color   = #4a4a5a;
    pressed_color = #2a2a3a;
    border_color  = #5a5a6a;

    static update = function()
    {
        if (!visible) return;

        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();

        var _gui_scale = global.gui_scale;
        var _base_scale_x = _gui_scale * (global.gui_width / 960);
        var _base_scale_y = _gui_scale * (global.gui_height / 540);

        var _mx = (window_mouse_get_x() / global.window_width) * global.gui_width;
        var _my = (window_mouse_get_y() / global.window_height) * global.gui_height;

        var _left   = _abs_x * _base_scale_x;
        var _top    = _abs_y * _base_scale_y;
        var _right  = _left + (width * _base_scale_x);
        var _bottom = _top  + (height * _base_scale_y);

        is_hovered = (_mx >= _left && _mx <= _right && _my >= _top && _my <= _bottom);

        if (is_hovered)
        {
            if (mouse_check_button_pressed(mb_left))
            {
                is_pressed = true;
            }

            if (mouse_check_button_released(mb_left) && is_pressed)
            {
                is_pressed = false;

                var _count = array_length(options);

                if (_count > 0)
                {
                    selected = (selected + 1) % _count;
                    text = options[selected];

                    emit_event("on_change", { value: selected, text: text });
                }

                sfx_play("phantasia:sfx/ui/click", global.settings.audio_sfx);
            }
        }
        else
        {
            if (mouse_check_button_released(mb_left))
            {
                is_pressed = false;
            }
        }

        update_bindings();

        var _child_count = array_length(children);

        for (var i = _child_count - 1; i >= 0; --i)
        {
            children[i].update();
        }
    }

    static draw_content = function()
    {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();

        var _gui_scale = global.gui_scale;
        var _base_scale_x = _gui_scale * (global.gui_width / 960);
        var _base_scale_y = _gui_scale * (global.gui_height / 540);

        var _x1 = _abs_x * _base_scale_x;
        var _y1 = _abs_y * _base_scale_y;
        var _x2 = _x1 + (width  * _base_scale_x);
        var _y2 = _y1 + (height * _base_scale_y);

        var _bg = normal_color;

        if (is_pressed)
        {
            _bg = pressed_color;
        }
        else if (is_hovered)
        {
            _bg = hover_color;
        }

        draw_rectangle_colour(_x1, _y1, _x2, _y2, _bg, _bg, _bg, _bg, false);
        draw_rectangle_colour(_x1, _y1, _x2, _y2, border_color, border_color, border_color, border_color, true);

        var _display = text;

        if (_display == "" && array_length(options) > 0)
        {
            _display = options[clamp(selected, 0, array_length(options) - 1)];
        }

        if (_display != "")
        {
            var _cx = (_x1 + _x2) / 2;
            var _cy = (_y1 + _y2) / 2;

            var _prev_halign = draw_get_halign();
            var _prev_valign = draw_get_valign();

            draw_set_align(fa_center, fa_middle);

            render_text(
                _cx, _cy,
                _display,
                _base_scale_x * text_scale,
                _base_scale_y * text_scale,
                0,
                colour,
                1
            );

            draw_set_align(_prev_halign, _prev_valign);
        }

        var _arrow_x = _x2 - (8 * _base_scale_x);
        var _arrow_y = (_y1 + _y2) / 2;
        var _arrow_size = 3 * _base_scale_x;

        draw_triangle(
            _arrow_x - _arrow_size, _arrow_y - _arrow_size,
            _arrow_x + _arrow_size, _arrow_y - _arrow_size,
            _arrow_x, _arrow_y + _arrow_size,
            false
        );
    }
}
