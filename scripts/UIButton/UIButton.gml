/* UI Button Element - interactive button with click events
   @param {Real} _x X position
   @param {Real} _y Y position
   @param {Real} _width Button width
   @param {Real} _height Button height
   @param {String} _text Button text */
function UIButton(_x, _y, _width, _height, _text = "") : UIElement(_x, _y, _width, _height) constructor
{
    text = _text;
    colour = c_white;
    text_scale = 1;
    
    /* Button states */
    is_hovered = false;
    is_pressed = false;
    is_disabled = false;
    
    /* Visual styling */
    normal_color = #3a3a4a;
    hover_color = #4a4a5a;
    pressed_color = #2a2a3a;
    disabled_color = #2a2a2a;
    border_color = #5a5a6a;
    
    static update = function()
    {
        if (!visible || is_disabled) exit;
        
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _base_scale = ui_get_base_scale();
        var _base_scale_x = _base_scale.x;
        var _base_scale_y = _base_scale.y;
        
        var _mx = (window_mouse_get_x() / global.window_width) * global.gui_width;
        var _my = (window_mouse_get_y() / global.window_height) * global.gui_height;
        
        var _left = _abs_x * _base_scale_x;
        var _top = _abs_y * _base_scale_y;
        var _right = _left + (width * _base_scale_x);
        var _bottom = _top + (height * _base_scale_y);
        
        var _was_hovered = is_hovered;
        is_hovered = (_mx >= _left && _mx <= _right && _my >= _top && _my <= _bottom);
        
        if (is_hovered)
        {
            if (mouse_check_button_pressed(mb_left))
            {
                is_pressed = true;
                emit_event("on_select_press");
            }
            
            if (mouse_check_button_released(mb_left) && is_pressed)
            {
                is_pressed = false;
                emit_event("on_select_release");
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
        
        /* Update bindings */
        update_bindings();
        
        /* Update children */
        var _child_count = array_length(children);
        
        for (var i = 0; i < _child_count; ++i)
        {
            children[i].update();
        }
    }
    
    static draw_content = function()
    {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _base_scale = ui_get_base_scale();
        var _base_scale_x = _base_scale.x;
        var _base_scale_y = _base_scale.y;
        
        var _x1 = _abs_x * _base_scale_x;
        var _y1 = _abs_y * _base_scale_y;
        var _x2 = _x1 + (width * _base_scale_x);
        var _y2 = _y1 + (height * _base_scale_y);
        
        /* Determine background color */
        var _bg_color = normal_color;
        
        if (is_disabled)
        {
            _bg_color = disabled_color;
        }
        else if (is_pressed)
        {
            _bg_color = pressed_color;
        }
        else if (is_hovered)
        {
            _bg_color = hover_color;
        }
        
        /* Draw background */
        draw_rectangle_colour(_x1, _y1, _x2, _y2, _bg_color, _bg_color, _bg_color, _bg_color, false);
        
        /* Draw border */
        draw_rectangle_colour(_x1, _y1, _x2, _y2, border_color, border_color, border_color, border_color, true);
        
        /* Draw text centered */
        if (text != "")
        {
            var _cx = (_x1 + _x2) / 2;
            var _cy = (_y1 + _y2) / 2;
            
            var _prev_halign = draw_get_halign();
            var _prev_valign = draw_get_valign();
            
            draw_set_align(fa_center, fa_middle);
            
            render_text(
                _cx, _cy,
                text,
                _base_scale_x * text_scale,
                _base_scale_y * text_scale,
                0,
                colour,
                1
            );
            
            draw_set_align(_prev_halign, _prev_valign);
        }
    }
}
