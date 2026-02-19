/// @desc UI Slider Element - adjustable value slider
/// @param {Real} _x X position
/// @param {Real} _y Y position
/// @param {Real} _width Slider width
/// @param {Real} _min Minimum value
/// @param {Real} _max Maximum value
/// @param {Real} _value Initial value
function UISlider(_x, _y, _width, _min, _max, _value) : UIElement(_x, _y, _width, 16) constructor {
    min_value = _min;
    max_value = _max;
    value = clamp(_value, _min, _max);
    step = 0; // 0 = continuous
    
    // Visual styling
    track_color = #2a2a3a;
    fill_color = #4a8aff;
    handle_color = c_white;
    handle_size = 8;
    
    // Interaction state
    is_dragging = false;
    
    static update = function() {
        if (!visible) return;
        
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _gui_scale = global.gui_scale;
        var _base_scale_x = _gui_scale * (global.gui_width / 960);
        var _base_scale_y = _gui_scale * (global.gui_height / 540);
        
        var _mx = (window_mouse_get_x() / global.window_width) * global.gui_width;
        var _my = (window_mouse_get_y() / global.window_height) * global.gui_height;
        
        var _left = _abs_x * _base_scale_x;
        var _top = _abs_y * _base_scale_y;
        var _right = _left + (width * _base_scale_x);
        var _bottom = _top + (height * _base_scale_y);
        
        if (mouse_check_button_pressed(mb_left)) {
            if (_mx >= _left && _mx <= _right && _my >= _top && _my <= _bottom) {
                is_dragging = true;
            }
        }
        
        if (mouse_check_button_released(mb_left)) {
            if (is_dragging) {
                is_dragging = false;
                emit_event("on_change", { value: value });
            }
        }
        
        if (is_dragging) {
            var _t = clamp((_mx - _left) / (_right - _left), 0, 1);
            var _new_value = lerp(min_value, max_value, _t);
            
            if (step > 0) {
                _new_value = round(_new_value / step) * step;
            }
            
            value = clamp(_new_value, min_value, max_value);
            emit_event("on_drag", { value: value });
        }
        
        update_bindings();
    }
    
    static draw_content = function() {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _gui_scale = global.gui_scale;
        var _base_scale_x = _gui_scale * (global.gui_width / 960);
        var _base_scale_y = _gui_scale * (global.gui_height / 540);
        
        var _x1 = _abs_x * _base_scale_x;
        var _y1 = _abs_y * _base_scale_y;
        var _x2 = _x1 + (width * _base_scale_x);
        var _cy = _y1 + (height * _base_scale_y / 2);
        var _track_height = 4 * _base_scale_y;
        
        // Draw track
        draw_rectangle_colour(_x1, _cy - _track_height/2, _x2, _cy + _track_height/2,
            track_color, track_color, track_color, track_color, false);
        
        // Draw fill
        var _t = (value - min_value) / (max_value - min_value);
        var _fill_x = lerp(_x1, _x2, _t);
        draw_rectangle_colour(_x1, _cy - _track_height/2, _fill_x, _cy + _track_height/2,
            fill_color, fill_color, fill_color, fill_color, false);
        
        // Draw handle
        var _handle_r = handle_size * _base_scale_x;
        draw_circle_colour(_fill_x, _cy, _handle_r, handle_color, handle_color, false);
    }
}
