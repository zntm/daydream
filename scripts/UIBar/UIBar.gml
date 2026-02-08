/// @desc UI Bar Element - progress/health bar display
/// @param {Real} _x X position
/// @param {Real} _y Y position
/// @param {Real} _width Bar width
/// @param {Real} _height Bar height
/// @param {Real} _min Minimum value
/// @param {Real} _max Maximum value
/// @param {Real} _value Current value
function UIBar(_x, _y, _width, _height, _min, _max, _value) : UIElement(_x, _y, _width, _height) constructor {
    min_value = _min;
    max_value = _max;
    value = clamp(_value, _min, _max);
    
    // Visual styling
    background_color = #1a1a2a;
    fill_color = #4aff4a;
    border_color = #3a3a4a;
    
    // Animation
    display_value = _value;
    smooth = true;
    smooth_speed = 0.15;
    
    // Edge fade (for HP bar effects)
    edge_fade = false;
    edge_fade_width = 4;
    
    static update = function() {
        if (!visible) return;
        
        // Smooth animation
        if (smooth) {
            display_value = lerp(display_value, value, smooth_speed);
        } else {
            display_value = value;
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
        var _y2 = _y1 + (height * _base_scale_y);
        
        // Draw background
        draw_rectangle_colour(_x1, _y1, _x2, _y2,
            background_color, background_color, background_color, background_color, false);
        
        // Calculate fill width
        var _t = (display_value - min_value) / (max_value - min_value);
        _t = clamp(_t, 0, 1);
        var _fill_x2 = lerp(_x1, _x2, _t);
        
        // Draw fill
        if (_fill_x2 > _x1) {
            if (edge_fade) {
                // Draw with edge fade gradient
                var _fade_start = _fill_x2 - (edge_fade_width * _base_scale_x);
                if (_fade_start > _x1) {
                    draw_rectangle_colour(_x1, _y1, _fade_start, _y2,
                        fill_color, fill_color, fill_color, fill_color, false);
                    draw_rectangle_colour(_fade_start, _y1, _fill_x2, _y2,
                        fill_color, background_color, background_color, fill_color, false);
                } else {
                    draw_rectangle_colour(_x1, _y1, _fill_x2, _y2,
                        fill_color, fill_color, fill_color, fill_color, false);
                }
            } else {
                draw_rectangle_colour(_x1, _y1, _fill_x2, _y2,
                    fill_color, fill_color, fill_color, fill_color, false);
            }
        }
        
        // Draw border
        draw_rectangle_colour(_x1, _y1, _x2, _y2,
            border_color, border_color, border_color, border_color, true);
    }
    
    /// @desc Set the current value
    static set_value = function(_value) {
        value = clamp(_value, min_value, max_value);
        return self;
    }
    
    /// @desc Set the max value
    static set_max = function(_max) {
        max_value = _max;
        value = clamp(value, min_value, max_value);
        return self;
    }
}
