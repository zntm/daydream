/// @description UIScrollView - A scrollable container for UI content
/// @param {String} _id Optional unique identifier

function UIScrollView(_id = "") : UIBox(_id) constructor
{
    // Scroll state
    scroll_x = 0;
    scroll_y = 0;
    scroll_target_x = 0;
    scroll_target_y = 0;
    
    // Scroll behaviour
    scroll_speed = 0.2; // Lerp factor
    scroll_wheel_amount = 40; // Pixels per wheel tick
    scroll_momentum = 0;
    scroll_friction = 0.9;
    
    // Content size (calculated from children)
    content_width = 0;
    content_height = 0;
    
    // Scrollbar styling
    scrollbar_width = 6;
    scrollbar_colour = make_colour_rgb(100, 100, 140);
    scrollbar_track_colour = make_colour_rgb(40, 40, 50);
    scrollbar_alpha = 0.8;
    show_scrollbar = true;
    
    // Scrollbar state
    scrollbar_hovered = false;
    scrollbar_dragging = false;
    scrollbar_drag_offset = 0;
    
    // Clipping
    clip_content = true;
    
    // --- Fluent Setters ---
    
    static set_scroll = function(_x, _y)
    {
        scroll_target_x = _x;
        scroll_target_y = _y;
        return self;
    }
    
    static set_scroll_speed = function(_speed)
    {
        scroll_speed = _speed;
        return self;
    }
    
    static set_scrollbar_style = function(_colour, _width = 6, _alpha = 0.8)
    {
        scrollbar_colour = _colour;
        scrollbar_width = _width;
        scrollbar_alpha = _alpha;
        return self;
    }
    
    static set_show_scrollbar = function(_show)
    {
        show_scrollbar = _show;
        return self;
    }
    
    static set_clip_content = function(_clip)
    {
        clip_content = _clip;
        return self;
    }
    
    // --- Content Size Calculation ---
    
    static get_content_width = function()
    {
        var _max_w = 0;
        var _child_count = array_length(children);
        
        for (var i = 0; i < _child_count; ++i)
        {
            var _child = children[i];
            if (!_child.visible) continue;
            
            var _child_right = _child._computed_x + _child._computed_width + _child.margin_right;
            _max_w = max(_max_w, _child_right);
        }
        
        return _max_w;
    }
    
    static get_content_height = function()
    {
        var _max_h = 0;
        var _child_count = array_length(children);
        
        for (var i = 0; i < _child_count; ++i)
        {
            var _child = children[i];
            if (!_child.visible) continue;
            
            var _child_bottom = _child._computed_y + _child._computed_height + _child.margin_bottom;
            _max_h = max(_max_h, _child_bottom);
        }
        
        return _max_h;
    }
    
    // --- Scroll Logic ---
    
    static clamp_scroll = function()
    {
        var _view_width = _computed_width - padding_left - padding_right;
        var _view_height = _computed_height - padding_top - padding_bottom;
        
        if (show_scrollbar && content_height > _view_height)
        {
            _view_width -= scrollbar_width;
        }
        
        var _max_scroll_x = max(0, content_width - _view_width);
        var _max_scroll_y = max(0, content_height - _view_height);
        
        scroll_target_x = clamp(scroll_target_x, 0, _max_scroll_x);
        scroll_target_y = clamp(scroll_target_y, 0, _max_scroll_y);
    }
    
    static scroll_to_child = function(_child)
    {
        var _view_height = _computed_height - padding_top - padding_bottom;
        
        var _child_top = _child._computed_y - padding_top;
        var _child_bottom = _child_top + _child._computed_height;
        
        if (_child_top < scroll_y)
        {
            scroll_target_y = _child_top;
        }
        else if (_child_bottom > scroll_y + _view_height)
        {
            scroll_target_y = _child_bottom - _view_height;
        }
        
        clamp_scroll();
        return self;
    }
    
    // --- Update Override ---
    
    static update = function()
    {
        if (!visible) return;
        
        // Calculate content size
        content_width = get_content_width();
        content_height = get_content_height();
        
        // Clamp scroll targets
        clamp_scroll();
        
        // Smooth scroll
        scroll_x = lerp(scroll_x, scroll_target_x, scroll_speed);
        scroll_y = lerp(scroll_y, scroll_target_y, scroll_speed);
        
        // Apply momentum
        if (abs(scroll_momentum) > 0.1)
        {
            scroll_target_y += scroll_momentum;
            scroll_momentum *= scroll_friction;
            clamp_scroll();
        }
        else
        {
            scroll_momentum = 0;
        }
        
        if (on_update != undefined) on_update(self);
        
        // Update children
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; ++i)
        {
            children[i].update();
        }
    }
    
    // --- Input Handling Override ---
    
    static handle_input = function(_mouse_x, _mouse_y, _mouse_pressed, _mouse_held, _mouse_released)
    {
        if (!visible || !enabled) return undefined;
        
        var _hovered = point_in_bounds(_mouse_x, _mouse_y);
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        // Handle scrollbar interaction
        if (show_scrollbar && content_height > _computed_height - padding_top - padding_bottom)
        {
            var _view_height = _computed_height - padding_top - padding_bottom;
            var _scrollbar_x = _abs_x + _computed_width - scrollbar_width - 2;
            var _scrollbar_track_height = _view_height;
            var _scrollbar_height = max(20, _scrollbar_track_height * (_view_height / content_height));
            var _scrollbar_y = _abs_y + padding_top + (scroll_y / max(1, content_height - _view_height)) * (_scrollbar_track_height - _scrollbar_height);
            
            var _in_scrollbar = (_mouse_x >= _scrollbar_x && _mouse_x <= _scrollbar_x + scrollbar_width &&
                                 _mouse_y >= _scrollbar_y && _mouse_y <= _scrollbar_y + _scrollbar_height);
            
            scrollbar_hovered = _in_scrollbar;
            
            if (_mouse_pressed && _in_scrollbar)
            {
                scrollbar_dragging = true;
                scrollbar_drag_offset = _mouse_y - _scrollbar_y;
            }
            
            if (scrollbar_dragging)
            {
                if (_mouse_held)
                {
                    var _new_y = _mouse_y - scrollbar_drag_offset - _abs_y - padding_top;
                    var _ratio = _new_y / (_scrollbar_track_height - _scrollbar_height);
                    scroll_target_y = _ratio * (content_height - _view_height);
                    clamp_scroll();
                    return self;
                }
                else
                {
                    scrollbar_dragging = false;
                }
            }
        }
        
        // Handle mouse wheel scrolling
        if (_hovered)
        {
            var _wheel = mouse_wheel_down() - mouse_wheel_up();
            if (_wheel != 0)
            {
                scroll_target_y += _wheel * scroll_wheel_amount;
                clamp_scroll();
            }
        }
        
        // Translate mouse position for children (account for scroll)
        var _translated_x = _mouse_x + scroll_x;
        var _translated_y = _mouse_y + scroll_y;
        
        // Process children with translated coordinates
        var _child_count = array_length(children);
        for (var i = _child_count - 1; i >= 0; --i)
        {
            var _child = children[i];
            var _handled = _child.handle_input(_translated_x, _translated_y, _mouse_pressed, _mouse_held, _mouse_released);
            if (_handled != undefined) return _handled;
        }
        
        return _hovered ? self : undefined;
    }
    
    // --- Draw Override ---
    
    static draw = function()
    {
        if (!visible) return;
        
        draw_self_content();
        
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        // Set up scissor clipping
        var _prev_scissor = undefined;
        if (clip_content)
        {
            _prev_scissor = gpu_get_scissor();
            
            var _clip_x = _abs_x + padding_left;
            var _clip_y = _abs_y + padding_top;
            var _clip_w = _computed_width - padding_left - padding_right;
            var _clip_h = _computed_height - padding_top - padding_bottom;
            
            if (show_scrollbar && content_height > _clip_h)
            {
                _clip_w -= scrollbar_width;
            }
            
            gpu_set_scissor(_clip_x, _clip_y, _clip_w, _clip_h);
        }
        
        // Draw children with scroll offset applied
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; ++i)
        {
            var _child = children[i];
            
            // Temporarily offset child position for scroll
            var _orig_x = _child._computed_x;
            var _orig_y = _child._computed_y;
            
            _child._computed_x -= scroll_x;
            _child._computed_y -= scroll_y;
            
            _child.draw();
            
            // Restore position
            _child._computed_x = _orig_x;
            _child._computed_y = _orig_y;
        }
        
        // Restore scissor
        if (clip_content && _prev_scissor != undefined)
        {
            if (array_length(_prev_scissor) >= 4)
            {
                gpu_set_scissor(_prev_scissor[0], _prev_scissor[1], _prev_scissor[2], _prev_scissor[3]);
            }
            else
            {
                gpu_set_scissor(0, 0, display_get_gui_width(), display_get_gui_height());
            }
        }
        
        // Draw scrollbar
        if (show_scrollbar && content_height > _computed_height - padding_top - padding_bottom)
        {
            var _view_height = _computed_height - padding_top - padding_bottom;
            var _scrollbar_x = _abs_x + _computed_width - scrollbar_width - 2;
            var _scrollbar_track_y = _abs_y + padding_top;
            var _scrollbar_track_height = _view_height;
            
            // Track
            draw_set_colour(scrollbar_track_colour);
            draw_set_alpha(scrollbar_alpha * 0.5);
            draw_roundrect_ext(_scrollbar_x, _scrollbar_track_y, 
                               _scrollbar_x + scrollbar_width, _scrollbar_track_y + _scrollbar_track_height,
                               scrollbar_width / 2, scrollbar_width / 2, false);
            
            // Handle
            var _scrollbar_height = max(20, _scrollbar_track_height * (_view_height / content_height));
            var _scrollbar_y = _scrollbar_track_y + (scroll_y / max(1, content_height - _view_height)) * (_scrollbar_track_height - _scrollbar_height);
            
            draw_set_colour(scrollbar_hovered || scrollbar_dragging ? c_white : scrollbar_colour);
            draw_set_alpha(scrollbar_alpha);
            draw_roundrect_ext(_scrollbar_x, _scrollbar_y,
                               _scrollbar_x + scrollbar_width, _scrollbar_y + _scrollbar_height,
                               scrollbar_width / 2, scrollbar_width / 2, false);
            
            draw_set_alpha(1);
            draw_set_colour(c_white);
        }
    }
}
