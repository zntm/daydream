/// @desc UI Popup Element - modal dialog container
/// @param {Real} _x X position
/// @param {Real} _y Y position
/// @param {Real} _width Popup width
/// @param {Real} _height Popup height
function UIPopup(_x, _y, _width, _height) : UIElement(_x, _y, _width, _height) constructor {
    // Visual styling
    background_color = #1a1a2e;
    border_color = #4a4a5e;
    overlay_color = c_black;
    overlay_alpha = 0.5;
    
    // Animation
    alpha = 0;
    target_alpha = 0;
    fade_speed = 0.15;
    
    // Positioning
    center_on_screen = true;
    
    static update = function() {
        // Fade animation
        alpha = lerp(alpha, target_alpha, fade_speed);
        
        if (alpha < 0.01 && target_alpha == 0) {
            visible = false;
        }
        
        if (!visible) return;
        
        // Center on screen if needed
        if (center_on_screen) {
            x = (global.gui_width - width) / 2;
            y = (global.gui_height - height) / 2;
        }
        
        update_bindings();
        
        // Update children
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; i++) {
            children[i].update();
        }
    }
    
    static draw = function() {
        if (!visible && alpha < 0.01) return;
        
        var _gui_scale = global.gui_scale;
        var _base_scale_x = _gui_scale * (global.gui_height / global.resolution_height_reference);
        var _base_scale_y = _gui_scale * (global.gui_height / 540);
        
        // Draw overlay
        draw_set_alpha(overlay_alpha * alpha);
        draw_rectangle_colour(0, 0, global.gui_width * _base_scale_x, global.gui_height * _base_scale_y,
            overlay_color, overlay_color, overlay_color, overlay_color, false);
        draw_set_alpha(1);
        
        // Draw popup
        draw_set_alpha(alpha);
        
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _x1 = _abs_x * _base_scale_x;
        var _y1 = _abs_y * _base_scale_y;
        var _x2 = _x1 + (width * _base_scale_x);
        var _y2 = _y1 + (height * _base_scale_y);
        
        // Draw background
        draw_rectangle_colour(_x1, _y1, _x2, _y2,
            background_color, background_color, background_color, background_color, false);
        
        // Draw border
        draw_rectangle_colour(_x1, _y1, _x2, _y2,
            border_color, border_color, border_color, border_color, true);
        
        draw_set_alpha(1);
        
        // Draw content
        draw_content();
        
        // Draw children
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; i++) {
            children[i].draw();
        }
    }
    
    /// @desc Show the popup
    static show = function() {
        visible = true;
        target_alpha = 1;
        emit_event("on_show");
        return self;
    }
    
    /// @desc Hide the popup
    static hide = function() {
        target_alpha = 0;
        emit_event("on_hide");
        return self;
    }
}
