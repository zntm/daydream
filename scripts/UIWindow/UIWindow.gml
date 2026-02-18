/// @desc UI Window Element - movable/resizable container
/// @param {Real} _x X position
/// @param {Real} _y Y position
/// @param {Real} _width Window width
/// @param {Real} _height Window height
/// @param {String} _title Window title
function UIWindow(_x, _y, _width, _height, _title = "") : UIElement(_x, _y, _width, _height) constructor {
    title = _title;
    movable = true;
    resizable = false;
    closeable = false;
    
    // Window styling
    title_height = 24;
    background_color = #1a1a2e;
    title_color = #2a2a3e;
    border_color = #3a3a4e;
    title_text_color = c_white;
    
    // Dragging state
    is_dragging = false;
    drag_offset_x = 0;
    drag_offset_y = 0;
    
    // Fade animation
    alpha = 1;
    target_alpha = 1;
    fade_speed = 0.1;
    
    static update = function() {
        if (!visible) return;
        
        // Fade animation
        alpha = lerp(alpha, target_alpha, fade_speed);
        
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _gui_scale = global.gui_scale;
        var _base_scale_x = _gui_scale * (global.gui_width / 960);
        var _base_scale_y = _gui_scale * (global.gui_height / 540);
        
        var _mx = (window_mouse_get_x() / global.window_width) * global.gui_width;
        var _my = (window_mouse_get_y() / global.window_height) * global.gui_height;
        
        // Handle dragging
        if (movable) {
            var _title_left = _abs_x * _base_scale_x;
            var _title_top = _abs_y * _base_scale_y;
            var _title_right = _title_left + (width * _base_scale_x);
            var _title_bottom = _title_top + (title_height * _base_scale_y);
            
            if (mouse_check_button_pressed(mb_left)) {
                if (_mx >= _title_left && _mx <= _title_right && 
                    _my >= _title_top && _my <= _title_bottom) {
                    is_dragging = true;
                    drag_offset_x = _mx - _title_left;
                    drag_offset_y = _my - _title_top;
                }
            }
            
            if (mouse_check_button_released(mb_left)) {
                is_dragging = false;
            }
            
            if (is_dragging) {
                x = (_mx - drag_offset_x) / _base_scale_x;
                y = (_my - drag_offset_y) / _base_scale_y;
            }
        }
        
        // Update bindings
        update_bindings();
        
        // Update children
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; i++) {
            children[i].update();
        }
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
        
        draw_set_alpha(alpha);
        
        // Draw background
        draw_rectangle_colour(_x1, _y1, _x2, _y2, 
            background_color, background_color, background_color, background_color, false);
        
        // Draw title bar
        var _title_y2 = _y1 + (title_height * _base_scale_y);
        draw_rectangle_colour(_x1, _y1, _x2, _title_y2,
            title_color, title_color, title_color, title_color, false);
        
        // Draw border
        draw_rectangle_colour(_x1, _y1, _x2, _y2,
            border_color, border_color, border_color, border_color, true);
        
        // Draw title text
        if (title != "") {
            var _prev_halign = draw_get_halign();
            var _prev_valign = draw_get_valign();
            draw_set_align(fa_center, fa_middle);
            
            render_text(
                (_x1 + _x2) / 2,
                (_y1 + _title_y2) / 2,
                title,
                _base_scale_x * 0.8,
                _base_scale_y * 0.8,
                0,
                title_text_color,
                alpha
            );
            
            draw_set_align(_prev_halign, _prev_valign);
        }
        
        draw_set_alpha(1);
    }
    
    /// @desc Show the window with fade animation
    static show = function() {
        visible = true;
        target_alpha = 1;
        return self;
    }
    
    /// @desc Hide the window with fade animation
    static hide = function() {
        target_alpha = 0;
        // After fade completes, set visible = false
        return self;
    }
}
