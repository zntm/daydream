/// @desc UI Scroll Area Element - scrollable container with vertical scrollbar
/// @param {Real} _x X position
/// @param {Real} _y Y position
/// @param {Real} _width Area width
/// @param {Real} _height Visible area height
function UIScrollArea(_x, _y, _width, _height) : UIElement(_x, _y, _width, _height) constructor {
    // Scroll state
    scroll_offset = 0;       // Current Y scroll offset in pixels
    content_height = 0;      // Total height of children (auto-calculated)
    scroll_speed = 16;       // Pixels per scroll tick
    
    // Scrollbar styling
    scrollbar_width = 6;
    scrollbar_color = #2a2a3a;
    scrollbar_handle_color = #6a6a8a;
    scrollbar_handle_hover_color = #8a8aff;
    
    // Layout defaults
    layout = UI_LAYOUT.NONE;
    spacing = 0;
    
    // Interaction state
    is_scrollbar_dragging = false;
    is_scrollbar_hovered = false;
    scrollbar_drag_offset = 0;
    
    /// @desc Recalculate content height from children
    static recalculate_content_height = function() {
        var _child_count = array_length(children);
        
        if (_child_count == 0) {
            content_height = 0;
            
            return;
        }
        
        var _max_y = 0;
        
        for (var i = 0; i < _child_count; ++i) {
            var _child = children[i];
            
            if (!_child.visible) continue;
            
            var _child_bottom = _child.y + _child.height;
            _max_y = max(_max_y, _child_bottom);
        }
        
        content_height = _max_y;
    }
    
    /// @desc Get maximum scroll offset
    static get_max_scroll = function() {
        return max(0, content_height - height);
    }
    
    /// @desc Get scrollbar track dimensions
    static get_scrollbar_rect = function(_base_scale) {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _track_x = (_abs_x + width - scrollbar_width) * _base_scale.x;
        var _track_y = _abs_y * _base_scale.y;
        var _track_w = scrollbar_width * _base_scale.x;
        var _track_h = height * _base_scale.y;
        
        return { x: _track_x, y: _track_y, w: _track_w, h: _track_h };
    }
    
    /// @desc Get scrollbar thumb dimensions
    static get_thumb_rect = function(_base_scale) {
        var _track = get_scrollbar_rect(_base_scale);
        var _max_scroll = get_max_scroll();
        
        if (content_height <= 0 || content_height <= height) {
            // Thumb fills entire track (no scrolling needed)
            return { x: _track.x, y: _track.y, w: _track.w, h: _track.h };
        }
        
        var _thumb_ratio = min(1, height / content_height);
        var _thumb_h = max(10 * _base_scale.y, _track.h * _thumb_ratio);
        var _scroll_ratio = (_max_scroll > 0) ? (scroll_offset / _max_scroll) : 0;
        var _thumb_y = _track.y + (_track.h - _thumb_h) * _scroll_ratio;
        
        return { x: _track.x, y: _thumb_y, w: _track.w, h: _thumb_h };
    }
    
    static update = function() {
        if (!visible) return;
        
        recalculate_content_height();
        
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _mx = (window_mouse_get_x() / global.window_width) * global.gui_width;
        var _my = (window_mouse_get_y() / global.window_height) * global.gui_height;
        
        var _left = _abs_x * _base_scale.x;
        var _top = _abs_y * _base_scale.y;
        var _right = _left + (width * _base_scale.x);
        var _bottom = _top + (height * _base_scale.y);
        
        var _is_hovering = (_mx >= _left && _mx <= _right && _my >= _top && _my <= _bottom);
        
        var _max_scroll = get_max_scroll();
        
        // Mouse wheel scrolling
        if (_is_hovering && _max_scroll > 0) {
            var _wheel = mouse_wheel_down() - mouse_wheel_up();
            
            if (_wheel != 0) {
                scroll_offset = clamp(scroll_offset + _wheel * scroll_speed, 0, _max_scroll);
            }
        }
        
        // Scrollbar thumb dragging
        var _thumb = get_thumb_rect(_base_scale);
        var _track = get_scrollbar_rect(_base_scale);
        
        is_scrollbar_hovered = (_mx >= _thumb.x && _mx <= _thumb.x + _thumb.w &&
                                _my >= _thumb.y && _my <= _thumb.y + _thumb.h);
        
        if (mouse_check_button_pressed(mb_left)) {
            if (is_scrollbar_hovered) {
                is_scrollbar_dragging = true;
                scrollbar_drag_offset = _my - _thumb.y;
            }
            // Click on track (jump to position)
            else if (_mx >= _track.x && _mx <= _track.x + _track.w &&
                     _my >= _track.y && _my <= _track.y + _track.h) {
                var _click_ratio = (_my - _track.y) / _track.h;
                
                scroll_offset = clamp(_click_ratio * _max_scroll, 0, _max_scroll);
            }
        }
        
        if (mouse_check_button_released(mb_left)) {
            is_scrollbar_dragging = false;
        }
        
        if (is_scrollbar_dragging && _max_scroll > 0) {
            var _new_thumb_y = _my - scrollbar_drag_offset;
            var _scroll_range = _track.h - _thumb.h;
            
            if (_scroll_range > 0) {
                var _ratio = clamp((_new_thumb_y - _track.y) / _scroll_range, 0, 1);
                
                scroll_offset = _ratio * _max_scroll;
            }
        }
        
        scroll_offset = clamp(scroll_offset, 0, _max_scroll);
        
        update_bindings();
        
        // Update children
        var _child_count = array_length(children);
        
        for (var i = 0; i < _child_count; ++i) {
            children[i].update();
        }
    }
    
    /// @desc Override draw to clip children and draw scrollbar
    static draw = function() {
        if (!visible) return;
        
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _x1 = _abs_x * _base_scale.x;
        var _y1 = _abs_y * _base_scale.y;
        var _x2 = _x1 + (width * _base_scale.x);
        var _y2 = _y1 + (height * _base_scale.y);
        
        /* Draw background if set */
        if (background_color != undefined) {
            draw_set_alpha(background_alpha);
            draw_rectangle_colour(_x1, _y1, _x2, _y2,
                background_color, background_color, background_color, background_color, false);
            draw_set_alpha(1);
        }
        
        /* Draw content */
        draw_content();
        
        /* Set scissor clipping to area bounds */
        gpu_set_scissor(_x1, _y1, _x2 - _x1, _y2 - _y1);
        
        /* Draw children with scroll offset applied */
        var _child_count = array_length(children);
        
        for (var i = 0; i < _child_count; ++i) {
            var _child = children[i];
            
            /* Temporarily offset child for scrolling */
            var _saved_y = _child.y;
            
            _child.y = _saved_y - scroll_offset;
            _child.draw();
            _child.y = _saved_y;
        }
        
        /* Restore scissor */
        gpu_set_scissor(0, 0, global.gui_width, global.gui_height);
        
        /* Draw scrollbar if content overflows */
        if (content_height > height) {
            var _track = get_scrollbar_rect(_base_scale);
            var _thumb = get_thumb_rect(_base_scale);
            
            // Track
            draw_rectangle_colour(
                _track.x, _track.y,
                _track.x + _track.w, _track.y + _track.h,
                scrollbar_color, scrollbar_color, scrollbar_color, scrollbar_color, false
            );
            
            // Thumb
            var _handle_col = (is_scrollbar_hovered || is_scrollbar_dragging)
                ? scrollbar_handle_hover_color
                : scrollbar_handle_color;
            
            draw_rectangle_colour(
                _thumb.x, _thumb.y,
                _thumb.x + _thumb.w, _thumb.y + _thumb.h,
                _handle_col, _handle_col, _handle_col, _handle_col, false
            );
        }
    }
}
