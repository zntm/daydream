/// @description Base UIElement class for all UI components
/// @param {String} _id Optional unique identifier for the element

enum UI_SIZE_MODE {
    FIXED,
    FIT_CONTENT,
    FILL_PARENT
}

enum UI_LAYOUT {
    BLOCK,
    FLEX_ROW,
    FLEX_COLUMN
}

enum UI_ALIGN {
    START,
    CENTER,
    END,
    SPACE_BETWEEN,
    SPACE_AROUND
}

enum UI_STATE {
    NORMAL,
    HOVER,
    PRESSED,
    FOCUSED,
    DISABLED
}

function UIElement(_id = "") constructor
{
    id = _id;
    
    // --- Hierarchy ---
    parent = undefined;
    children = [];
    
    // --- Box Model (in logical units) ---
    x = 0;
    y = 0;
    width = 0;
    height = 0;
    
    width_mode = UI_SIZE_MODE.FIT_CONTENT;
    height_mode = UI_SIZE_MODE.FIT_CONTENT;
    
    min_width = 0;
    min_height = 0;
    max_width = infinity;
    max_height = infinity;
    
    // Padding (inside the border)
    padding_left = 0;
    padding_right = 0;
    padding_top = 0;
    padding_bottom = 0;
    
    // Margin (outside the border)
    margin_left = 0;
    margin_right = 0;
    margin_top = 0;
    margin_bottom = 0;
    
    // Anchoring (for absolute positioning within parent or screen)
    anchor_h = UI_ALIGN.START; // START, CENTER, END
    anchor_v = UI_ALIGN.START; // START, CENTER, END
    is_anchored = false;
    
    // --- Layout ---
    layout = UI_LAYOUT.BLOCK;
    justify_content = UI_ALIGN.START; // Main axis alignment
    align_items = UI_ALIGN.START;     // Cross axis alignment
    gap = 0; // Gap between children
    
    flex_grow = 0; // How much this element should grow to fill space
    flex_shrink = 1; // How much this element should shrink
    
    // --- Visibility & Interaction ---
    visible = true;
    enabled = true;
    focusable = false;
    
    state = UI_STATE.NORMAL;
    
    // --- Callbacks ---
    on_click = undefined;
    on_press = undefined;
    on_release = undefined;
    on_hover_enter = undefined;
    on_hover_exit = undefined;
    on_focus = undefined;
    on_blur = undefined;
    on_update = undefined;
    
    // --- Calculated Values (set during layout) ---
    _computed_x = 0;
    _computed_y = 0;
    _computed_width = 0;
    _computed_height = 0;
    
    // --- Fluent Setters ---
    
    static set_id = function(_id) { id = _id; return self; }
    
    static set_size = function(_width, _height)
    {
        width = _width;
        height = _height;
        width_mode = UI_SIZE_MODE.FIXED;
        height_mode = UI_SIZE_MODE.FIXED;
        return self;
    }
    
    static set_width = function(_width, _mode = UI_SIZE_MODE.FIXED)
    {
        width = _width;
        width_mode = _mode;
        return self;
    }
    
    static set_height = function(_height, _mode = UI_SIZE_MODE.FIXED)
    {
        height = _height;
        height_mode = _mode;
        return self;
    }
    
    static set_min_size = function(_min_width, _min_height)
    {
        min_width = _min_width;
        min_height = _min_height;
        return self;
    }
    
    static set_max_size = function(_max_width, _max_height)
    {
        max_width = _max_width;
        max_height = _max_height;
        return self;
    }
    
    static set_padding = function(_all_or_top, _right = undefined, _bottom = undefined, _left = undefined)
    {
        if (_right == undefined)
        {
            padding_left = _all_or_top;
            padding_right = _all_or_top;
            padding_top = _all_or_top;
            padding_bottom = _all_or_top;
        }
        else if (_bottom == undefined)
        {
            padding_top = _all_or_top;
            padding_bottom = _all_or_top;
            padding_left = _right;
            padding_right = _right;
        }
        else
        {
            padding_top = _all_or_top;
            padding_right = _right;
            padding_bottom = _bottom ?? _all_or_top;
            padding_left = _left ?? _right;
        }
        return self;
    }
    
    static set_margin = function(_all_or_top, _right = undefined, _bottom = undefined, _left = undefined)
    {
        if (_right == undefined)
        {
            margin_left = _all_or_top;
            margin_right = _all_or_top;
            margin_top = _all_or_top;
            margin_bottom = _all_or_top;
        }
        else if (_bottom == undefined)
        {
            margin_top = _all_or_top;
            margin_bottom = _all_or_top;
            margin_left = _right;
            margin_right = _right;
        }
        else
        {
            margin_top = _all_or_top;
            margin_right = _right;
            margin_bottom = _bottom ?? _all_or_top;
            margin_left = _left ?? _right;
        }
        return self;
    }
    
    static set_layout = function(_layout, _gap = 0)
    {
        layout = _layout;
        gap = _gap;
        return self;
    }
    
    static set_justify = function(_justify) { justify_content = _justify; return self; }
    static set_align = function(_align) { align_items = _align; return self; }
    
    static set_anchor = function(_h_align, _v_align)
    {
        anchor_h = _h_align;
        anchor_v = _v_align;
        is_anchored = true;
        return self;
    }
    
    static set_flex = function(_grow, _shrink = 1)
    {
        flex_grow = _grow;
        flex_shrink = _shrink;
        return self;
    }
    
    static set_visible = function(_visible) { visible = _visible; return self; }
    static set_enabled = function(_enabled) { enabled = _enabled; return self; }
    static set_focusable = function(_focusable) { focusable = _focusable; return self; }
    
    static set_on_click = function(_callback) { on_click = _callback; focusable = true; return self; }
    static set_on_press = function(_callback) { on_press = _callback; focusable = true; return self; }
    static set_on_release = function(_callback) { on_release = _callback; focusable = true; return self; }
    static set_on_hover_enter = function(_callback) { on_hover_enter = _callback; return self; }
    static set_on_hover_exit = function(_callback) { on_hover_exit = _callback; return self; }
    static set_on_focus = function(_callback) { on_focus = _callback; return self; }
    static set_on_blur = function(_callback) { on_blur = _callback; return self; }
    static set_on_update = function(_callback) { on_update = _callback; return self; }
    
    // --- Hierarchy ---
    
    static add_child = function(_child)
    {
        _child.parent = self;
        array_push(children, _child);
        return self;
    }
    
    static add_children = function(_children_array)
    {
        var _len = array_length(_children_array);
        for (var i = 0; i < _len; ++i)
        {
            add_child(_children_array[i]);
        }
        return self;
    }
    
    static remove_child = function(_child)
    {
        var _index = array_get_index(children, _child);
        if (_index >= 0)
        {
            _child.parent = undefined;
            array_delete(children, _index, 1);
        }
        return self;
    }
    
    static clear_children = function()
    {
        var _len = array_length(children);
        for (var i = 0; i < _len; ++i)
        {
            children[i].parent = undefined;
        }
        children = [];
        return self;
    }
    
    // --- Layout Calculation ---
    
    static get_content_width = function()
    {
        // If we have children, calculate size based on them
        var _child_count = array_length(children);
        if (_child_count > 0)
        {
            var _max_w = 0;
            var _sum_w = 0;
            
            for (var i = 0; i < _child_count; ++i)
            {
                var _child = children[i];
                if (!_child.visible || _child.is_anchored) continue;
                
                // For children, we need their anticipated content size + margins
                // This mimics a "first pass" measurement
                var _child_w = (_child.width_mode == UI_SIZE_MODE.FIXED) ? _child.width : _child.get_content_width() + _child.padding_left + _child.padding_right;
                _child_w += _child.margin_left + _child.margin_right;
                
                _max_w = max(_max_w, _child_w);
                _sum_w += _child_w;
            }
            
            if (layout == UI_LAYOUT.FLEX_ROW)
            {
                var _visible_children = 0;
                 for (var i = 0; i < _child_count; ++i) if (children[i].visible && !children[i].is_anchored) _visible_children++;
                return _sum_w + max(0, (_visible_children - 1) * gap);
            }
            else
            {
                return _max_w;
            }
        }
        return 0;
    }
    
    static get_content_height = function()
    {
        // If we have children, calculate size based on them
        var _child_count = array_length(children);
        if (_child_count > 0)
        {
            var _max_h = 0;
            var _sum_h = 0;
            
            for (var i = 0; i < _child_count; ++i)
            {
                var _child = children[i];
                if (!_child.visible || _child.is_anchored) continue;
                
                var _child_h = (_child.height_mode == UI_SIZE_MODE.FIXED) ? _child.height : _child.get_content_height() + _child.padding_top + _child.padding_bottom;
                _child_h += _child.margin_top + _child.margin_bottom;
                
                _max_h = max(_max_h, _child_h);
                _sum_h += _child_h;
            }
            
            if (layout == UI_LAYOUT.FLEX_COLUMN)
            {
                var _visible_children = 0;
                 for (var i = 0; i < _child_count; ++i) if (children[i].visible && !children[i].is_anchored) _visible_children++;
                return _sum_h + max(0, (_visible_children - 1) * gap);
            }
            else
            {
               return _max_h;
            }
        }
        return 0;
    }
    
    static calculate_layout = function(_available_width, _available_height)
    {
        // 1. Determine size
        switch (width_mode)
        {
            case UI_SIZE_MODE.FIXED:
                _computed_width = width;
                break;
            case UI_SIZE_MODE.FIT_CONTENT:
                _computed_width = get_content_width() + padding_left + padding_right;
                break;
            case UI_SIZE_MODE.FILL_PARENT:
                _computed_width = _available_width - margin_left - margin_right;
                break;
        }
        
        switch (height_mode)
        {
            case UI_SIZE_MODE.FIXED:
                _computed_height = height;
                break;
            case UI_SIZE_MODE.FIT_CONTENT:
                _computed_height = get_content_height() + padding_top + padding_bottom;
                break;
            case UI_SIZE_MODE.FILL_PARENT:
                _computed_height = _available_height - margin_top - margin_bottom;
                break;
        }
        
        // Apply min/max constraints
        _computed_width = clamp(_computed_width, min_width, max_width);
        _computed_height = clamp(_computed_height, min_height, max_height);
        
        // 2. Handle Anchoring (overrides normal flow position)
        if (is_anchored)
        {
            // Horizontal Anchor
            switch (anchor_h)
            {
                case UI_ALIGN.START:  _computed_x = margin_left; break;
                case UI_ALIGN.CENTER: _computed_x = (_available_width - _computed_width) / 2; break;
                case UI_ALIGN.END:    _computed_x = _available_width - _computed_width - margin_right; break;
            }
            
            // Vertical Anchor
            switch (anchor_v)
            {
                case UI_ALIGN.START:  _computed_y = margin_top; break;
                case UI_ALIGN.CENTER: _computed_y = (_available_height - _computed_height) / 2; break;
                case UI_ALIGN.END:    _computed_y = _available_height - _computed_height - margin_bottom; break;
            }
        }
        
        // Layout children
        var _inner_width = _computed_width - padding_left - padding_right;
        var _inner_height = _computed_height - padding_top - padding_bottom;
        
        var _child_count = array_length(children);
        if (_child_count == 0) return;
        
        // Calculate children sizes first, then position
        var _total_fixed_size = 0;
        var _total_flex_grow = 0;
        
        for (var i = 0; i < _child_count; ++i)
        {
            var _child = children[i];
            if (!_child.visible) continue;
            
            // If child is anchored, it doesn't affect flow, but we still calc its layout
            if (_child.is_anchored)
            {
                _child.calculate_layout(_inner_width, _inner_height);
                continue; 
            }
            
            _child.calculate_layout(_inner_width, _inner_height);
            
            if (layout == UI_LAYOUT.FLEX_ROW)
            {
                _total_fixed_size += _child._computed_width + _child.margin_left + _child.margin_right;
                if (i > 0) _total_fixed_size += gap;
            }
            else if (layout == UI_LAYOUT.FLEX_COLUMN)
            {
                _total_fixed_size += _child._computed_height + _child.margin_top + _child.margin_bottom;
                if (i > 0) _total_fixed_size += gap;
            }
            
            _total_flex_grow += _child.flex_grow;
        }
        
        // Distribute remaining space based on flex_grow
        var _remaining_space = (layout == UI_LAYOUT.FLEX_ROW) ? (_inner_width - _total_fixed_size) : (_inner_height - _total_fixed_size);
        _remaining_space = max(0, _remaining_space);
        
        // Position children
        var _cursor_x = padding_left;
        var _cursor_y = padding_top;
        
        for (var i = 0; i < _child_count; ++i)
        {
            var _child = children[i];
            if (!_child.visible) continue;
            
            if (_child.is_anchored) continue; // Skip anchored children in flow
            
            // Apply flex grow
            if (_total_flex_grow > 0 && _child.flex_grow > 0)
            {
                var _extra = (_remaining_space * _child.flex_grow) / _total_flex_grow;
                if (layout == UI_LAYOUT.FLEX_ROW)
                {
                    _child._computed_width += _extra;
                }
                else if (layout == UI_LAYOUT.FLEX_COLUMN)
                {
                    _child._computed_height += _extra;
                }
            }
            
            _child._computed_x = _cursor_x + _child.margin_left;
            _child._computed_y = _cursor_y + _child.margin_top;
            
            // Cross-axis alignment
            if (layout == UI_LAYOUT.FLEX_ROW)
            {
                switch (align_items)
                {
                    case UI_ALIGN.CENTER:
                        _child._computed_y = padding_top + (_inner_height - _child._computed_height) / 2;
                        break;
                    case UI_ALIGN.END:
                        _child._computed_y = padding_top + _inner_height - _child._computed_height - _child.margin_bottom;
                        break;
                }
            }
            else if (layout == UI_LAYOUT.FLEX_COLUMN)
            {
                switch (align_items)
                {
                    case UI_ALIGN.CENTER:
                        _child._computed_x = padding_left + (_inner_width - _child._computed_width) / 2;
                        break;
                    case UI_ALIGN.END:
                        _child._computed_x = padding_left + _inner_width - _child._computed_width - _child.margin_right;
                        break;
                }
            }
            
            // Advance cursor
            if (layout == UI_LAYOUT.FLEX_ROW)
            {
                _cursor_x += _child._computed_width + _child.margin_left + _child.margin_right + gap;
            }
            else if (layout == UI_LAYOUT.FLEX_COLUMN)
            {
                _cursor_y += _child._computed_height + _child.margin_top + _child.margin_bottom + gap;
            }
            else // BLOCK
            {
                _cursor_y += _child._computed_height + _child.margin_top + _child.margin_bottom;
            }
        }
    }
    
    // --- Absolute Position ---
    
    static get_absolute_x = function()
    {
        if (parent != undefined)
        {
            return parent.get_absolute_x() + _computed_x;
        }
        return _computed_x;
    }
    
    static get_absolute_y = function()
    {
        if (parent != undefined)
        {
            return parent.get_absolute_y() + _computed_y;
        }
        return _computed_y;
    }
    
    // --- Input Handling ---
    
    static point_in_bounds = function(_x, _y)
    {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        return (_x >= _abs_x) && (_x < _abs_x + _computed_width) && (_y >= _abs_y) && (_y < _abs_y + _computed_height);
    }
    
    static handle_input = function(_mouse_x, _mouse_y, _mouse_pressed, _mouse_held, _mouse_released)
    {
        if (!visible || !enabled) return undefined;
        
        var _hovered = point_in_bounds(_mouse_x, _mouse_y);
        var _previous_state = state;
        
        // Handle hover
        if (_hovered)
        {
            if (_previous_state == UI_STATE.NORMAL)
            {
                if (on_hover_enter != undefined) on_hover_enter(self);
            }
            
            if (_mouse_pressed)
            {
                state = UI_STATE.PRESSED;
                if (on_press != undefined) on_press(self);
            }
            else if (_mouse_released && _previous_state == UI_STATE.PRESSED)
            {
                if (global.ui_manager.focused_element == self) state = UI_STATE.FOCUSED;
                else state = UI_STATE.HOVER;
                
                if (on_click != undefined) on_click(self);
                if (on_release != undefined) on_release(self);
            }
            else if (!_mouse_held)
            {
                // Prioritize focus state if we are the focused element, 
                // so we don't lose the focus visual indicator (e.g. white border)
                if (global.ui_manager.focused_element == self)
                {
                    state = UI_STATE.FOCUSED;
                }
                else
                {
                    state = UI_STATE.HOVER;
                }
            }
        }
        else
        {
            if (_previous_state == UI_STATE.HOVER || _previous_state == UI_STATE.PRESSED)
            {
                if (on_hover_exit != undefined) on_hover_exit(self);
            }
            
            // Persist focus state if this is the focused element
            if (global.ui_manager.focused_element == self)
            {
                state = UI_STATE.FOCUSED;
            }
            else
            {
                state = UI_STATE.NORMAL;
            }
        }
        
        // Process children (in reverse order for proper z-ordering)
        var _child_count = array_length(children);
        for (var i = _child_count - 1; i >= 0; --i)
        {
            var _child = children[i];
            var _handled = _child.handle_input(_mouse_x, _mouse_y, _mouse_pressed, _mouse_held, _mouse_released);
            if (_handled != undefined) return _handled;
        }
        
        return (_hovered && focusable) ? self : undefined;
    }
    
    // --- Update & Draw ---
    
    static update = function()
    {
        if (!visible) return;
        
        if (on_update != undefined) on_update(self);
        
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; ++i)
        {
            children[i].update();
        }
    }
    
    static draw = function()
    {
        if (!visible) return;
        
        draw_self_content();
        
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; ++i)
        {
            children[i].draw();
        }
    }
    
    /// @description Override in subclasses to draw component-specific content
    static draw_self_content = function()
    {
        // Base implementation does nothing
    }
}
