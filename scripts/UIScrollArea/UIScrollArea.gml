/* ui scroll area element - scrollable container with vertical scrollbar */
/* @param {real} _x x position */
/* @param {real} _y y position */
/* @param {real} _width area width */
/* @param {real} _height visible area height */
function UIScrollArea(_x, _y, _width, _height) : UIElement(_x, _y, _width, _height) constructor 
{
    /* scroll state */
    scroll_offset = 0;       /* current y scroll offset in pixels */
    
    content_width = 0;       /* total width of children (auto-calculated) */
    
    content_height = 0;      /* total height of children (auto-calculated) */
    
    scroll_speed = 16;       /* pixels per scroll tick */
    
    scroll_axis = "vertical";
    
    
    /* scrollbar styling */
    scrollbar_width = 6;
    
    scrollbar_color = #2a2a3a;
    
    scrollbar_handle_color = #6a6a8a;
    
    scrollbar_handle_hover_color = #8a8aff;
    
    
    /* layout defaults */
    layout = UI_LAYOUT.NONE;
    
    spacing = 0;
    
    
    /* interaction state */
    is_scrollbar_dragging = false;
    
    is_scrollbar_hovered = false;
    
    scrollbar_drag_offset = 0;
    
    
    /* recalculate content bounds from children */
    static recalculate_content_size = function() 
    {
        var _child_count = array_length(children);
        
        
        if (_child_count == 0) 
        {
            content_width = 0;
            content_height = 0;
            
            exit;
        }
        
        
        var _max_x = 0;
        var _max_y = 0;
        
        
        for (var i = _child_count - 1; i >= 0; --i) 
        {
            var _child = children[i];
            
            
            if !(is_struct(_child)) continue;
            
            if !(_child.visible) continue;
            
            
            var _child_right = _child.x + _child.width;
            var _child_bottom = _child.y + _child.height;
            
            _max_x = max(_max_x, _child_right);
            _max_y = max(_max_y, _child_bottom);
        }
        
        content_width = _max_x;
        content_height = _max_y;
    }
    
    
    /* get maximum scroll offset */
    static get_max_scroll = function() 
    {
        if (scroll_axis == "horizontal")
        {
            return max(0, content_width - width);
        }

        return max(0, content_height - height);
    }
    
    
    /* get scrollbar track dimensions */
    static get_scrollbar_rect = function(_base_scale) 
    {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        

        if (scroll_axis == "horizontal")
        {
            return {
                x: _abs_x,
                y: _abs_y + height - scrollbar_width,
                w: width,
                h: scrollbar_width
            }
        }

        return {
            x: _abs_x + width - scrollbar_width,
            y: _abs_y,
            w: scrollbar_width,
            h: height
        }
    }
    
    
    /* get scrollbar thumb dimensions */
    static get_thumb_rect = function(_base_scale) 
    {
        var _track = get_scrollbar_rect(_base_scale);
        var _max_scroll = get_max_scroll();
        
        
        var _content_size = (scroll_axis == "horizontal") ? content_width : content_height;
        var _viewport_size = (scroll_axis == "horizontal") ? width : height;

        if (_content_size <= 0 || _content_size <= _viewport_size) 
        {
            /* thumb fills entire track (no scrolling needed) */
            return { x: _track.x, y: _track.y, w: _track.w, h: _track.h }
        }
        
        
        var _thumb_ratio = min(1, _viewport_size / _content_size);
        
        var _scroll_ratio = (_max_scroll > 0) ? (scroll_offset / _max_scroll) : 0;

        if (scroll_axis == "horizontal")
        {
            var _thumb_w = max(10, _track.w * _thumb_ratio);
            var _thumb_x = _track.x + (_track.w - _thumb_w) * _scroll_ratio;

            return { x: _thumb_x, y: _track.y, w: _thumb_w, h: _track.h }
        }

        var _thumb_h = max(10, _track.h * _thumb_ratio);
        var _thumb_y = _track.y + (_track.h - _thumb_h) * _scroll_ratio;

        return { x: _track.x, y: _thumb_y, w: _track.w, h: _thumb_h }
    }
    
    
    static update = function() 
    {
        if !(visible) exit;
        
        
        /* update children first */
        var _child_count = array_length(children);
        
        for (var i = _child_count - 1; i >= 0; --i) 
        {
            children[i].update();
        }
        
        
        recalculate_content_size();
        
        
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_interaction_x();
        var _abs_y = get_interaction_y();
        
        
        var _mx = ui_get_mouse_x();
        var _my = ui_get_mouse_y();
        
        
        var _left = _abs_x;
        var _top = _abs_y;
        var _right = _left + width;
        var _bottom = _top + height;
        
        
        var _is_hovering = (_mx >= _left && _mx <= _right && _my >= _top && _my <= _bottom);
        var _max_scroll = get_max_scroll();
        
        
        /* mouse wheel scrolling */
        if (_is_hovering && _max_scroll > 0) 
        {
            var _wheel = mouse_wheel_down() - mouse_wheel_up();
            
            
            if (_wheel != 0) 
            {
                scroll_offset = clamp(scroll_offset + _wheel * scroll_speed, 0, _max_scroll);
            }
        }
        
        
        /* scrollbar thumb dragging */
        var _thumb = get_thumb_rect(_base_scale);
        var _track = get_scrollbar_rect(_base_scale);
        
        
        is_scrollbar_hovered = (_mx >= _thumb.x && _mx <= _thumb.x + _thumb.w && _my >= _thumb.y && _my <= _thumb.y + _thumb.h);
        
        
        if !(global.ui_input_consumed) && (mouse_check_button_pressed(mb_left)) 
        {
            if (is_scrollbar_hovered) 
            {
                is_scrollbar_dragging = true;
                
                scrollbar_drag_offset = (scroll_axis == "horizontal") ? (_mx - _thumb.x) : (_my - _thumb.y);
                
                global.ui_input_consumed = true;
                
                sfx_play("phantasia:sfx/menu/button/select");
            } 
            else if (_mx >= _track.x && _mx <= _track.x + _track.w && _my >= _track.y && _my <= _track.y + _track.h) 
            {
                /* click on track (jump to position) */
                var _click_ratio = (scroll_axis == "horizontal")
                    ? ((_mx - _track.x) / max(_track.w, 0.0001))
                    : ((_my - _track.y) / max(_track.h, 0.0001));
                
                scroll_offset = clamp(_click_ratio * _max_scroll, 0, _max_scroll);
                
                global.ui_input_consumed = true;
                
                sfx_play("phantasia:sfx/menu/button/select");
            }
        }
        
        
        if (mouse_check_button_released(mb_left)) 
        {
            is_scrollbar_dragging = false;
        }
        
        
        if (is_scrollbar_dragging && _max_scroll > 0) 
        {
            if (scroll_axis == "horizontal")
            {
                var _new_thumb_x = _mx - scrollbar_drag_offset;
                var _scroll_range = _track.w - _thumb.w;

                if (_scroll_range > 0)
                {
                    var _ratio = clamp((_new_thumb_x - _track.x) / _scroll_range, 0, 1);
                    
                    scroll_offset = _ratio * _max_scroll;
                }
            }
            else
            {
                var _new_thumb_y = _my - scrollbar_drag_offset;
                var _scroll_range = _track.h - _thumb.h;
                
                if (_scroll_range > 0) 
                {
                    var _ratio = clamp((_new_thumb_y - _track.y) / _scroll_range, 0, 1);
                    
                    scroll_offset = _ratio * _max_scroll;
                }
            }
        }
        
        
        scroll_offset = clamp(scroll_offset, 0, _max_scroll);
        
        
        update_bindings();
    }
    
    
    /* override draw to clip children and draw scrollbar */
    static draw = function() 
    {
        if !(visible) exit;
        
        
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        
        var _x1 = _abs_x * _base_scale.x;
        var _y1 = _abs_y * _base_scale.y;
        var _x2 = _x1 + (width * _base_scale.x);
        var _y2 = _y1 + (height * _base_scale.y);
        
        
        /* draw background if set */
        if (background_color != undefined) 
        {
            draw_set_alpha(background_alpha);
            
            draw_rectangle_colour(_x1, _y1, _x2, _y2, background_color, background_color, background_color, background_color, false);
            
            draw_set_alpha(1);
        }
        
        
        /* draw content */
        draw_content();
        
        
        /* execute custom draw callback if set */
        if (on_draw != undefined)
        {
            on_draw(_x1, _y1, _base_scale.x, _base_scale.y);
        }
        
        
        /* set scissor clipping to area bounds */
        gpu_set_scissor(_x1, _y1, _x2 - _x1, _y2 - _y1);
        
        
        /* draw children with scroll offset applied */
        var _child_count = array_length(children);
        
        for (var i = _child_count - 1; i >= 0; --i) 
        {
            var _child = children[i];
            
            
            /* temporarily offset child for scrolling */
            var _saved_x = _child.x;
            var _saved_y = _child.y;
            
            if (scroll_axis == "horizontal")
            {
                _child.x = _saved_x - scroll_offset;
            }
            else
            {
                _child.y = _saved_y - scroll_offset;
            }
            
            _child.draw();
            
            _child.x = _saved_x;
            _child.y = _saved_y;
        }
        
        
        /* restore scissor */
        gpu_set_scissor(0, 0, global.window_width, global.window_height);
        
        
        /* draw scrollbar if content overflows */
        var _overflow = (scroll_axis == "horizontal") ? (content_width > width) : (content_height > height);
        
        if (_overflow) 
        {
            var _track = get_scrollbar_rect(_base_scale);
            var _thumb = get_thumb_rect(_base_scale);
            
            
            /* track */
            draw_rectangle_colour(_track.x * _base_scale.x, _track.y * _base_scale.y, (_track.x + _track.w) * _base_scale.x, (_track.y + _track.h) * _base_scale.y, scrollbar_color, scrollbar_color, scrollbar_color, scrollbar_color, false);
            
            
            /* thumb */
            var _handle_col = (is_scrollbar_hovered || is_scrollbar_dragging) ? scrollbar_handle_hover_color : scrollbar_handle_color;
            
            
            draw_rectangle_colour(_thumb.x * _base_scale.x, _thumb.y * _base_scale.y, (_thumb.x + _thumb.w) * _base_scale.x, (_thumb.y + _thumb.h) * _base_scale.y, _handle_col, _handle_col, _handle_col, _handle_col, false);
        }
    }
}
