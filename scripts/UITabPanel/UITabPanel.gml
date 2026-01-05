/// @description UITabPanel - A container that enables tabs with a slider animation
/// @param {String} _id Optional unique identifier

function UITabPanel(_id = "") : UIBox(_id) constructor
{
    // Tab management
    tabs = []; // Array of {name, content} structs
    active_index = 0;
    target_index = 0;
    
    // Animation
    slide_progress = 0;
    slide_speed = 0.15;
    
    // Tab bar styling
    tab_bar_height = 32;
    tab_bar_colour = make_colour_rgb(30, 30, 45);
    tab_active_colour = make_colour_rgb(60, 100, 160);
    tab_inactive_colour = make_colour_rgb(40, 40, 55);
    
    // Internal panel for scrolling content
    _content_container = new UIElement("content_container")
        .set_layout(UI_LAYOUT.FLEX_ROW, 0);
    
    add_child(_content_container);
    
    // --- Tab Management ---
    
    static add_tab = function(_name, _content)
    {
        array_push(tabs, { name: _name, content: _content });
        _content_container.add_child(_content);
        
        // Set content to fill the available space
        _content.width_mode = UI_SIZE_MODE.FIXED;
        _content.height_mode = UI_SIZE_MODE.FIXED;
        
        return self;
    }
    
    static set_active_tab = function(_index)
    {
        if (_index < 0 || _index >= array_length(tabs)) return self;
        target_index = _index;
        return self;
    }
    
    static enable_tab = function(_index)
    {
        set_active_tab(_index);
        return self;
    }
    
    static get_active_tab = function()
    {
        return active_index;
    }
    
    static next_tab = function()
    {
        set_active_tab((target_index + 1) mod array_length(tabs));
        return self;
    }
    
    static previous_tab = function()
    {
        var _len = array_length(tabs);
        set_active_tab((target_index - 1 + _len) mod _len);
        return self;
    }
    
    // --- Layout Override ---
    
    static calculate_layout = function(_available_width, _available_height)
    {
        // Calculate own size first
        switch (width_mode)
        {
            case UI_SIZE_MODE.FIXED: _computed_width = width; break;
            case UI_SIZE_MODE.FIT_CONTENT: _computed_width = _available_width - margin_left - margin_right; break;
            case UI_SIZE_MODE.FILL_PARENT: _computed_width = _available_width - margin_left - margin_right; break;
        }
        
        switch (height_mode)
        {
            case UI_SIZE_MODE.FIXED: _computed_height = height; break;
            case UI_SIZE_MODE.FIT_CONTENT: _computed_height = _available_height - margin_top - margin_bottom; break;
            case UI_SIZE_MODE.FILL_PARENT: _computed_height = _available_height - margin_top - margin_bottom; break;
        }
        
        _computed_width = clamp(_computed_width, min_width, max_width);
        _computed_height = clamp(_computed_height, min_height, max_height);
        
        // Content area dimensions (below tab bar)
        var _content_width = _computed_width - padding_left - padding_right;
        var _content_height = _computed_height - padding_top - padding_bottom - tab_bar_height;
        
        // Position content container
        _content_container._computed_x = padding_left;
        _content_container._computed_y = padding_top + tab_bar_height;
        _content_container._computed_width = _content_width * array_length(tabs);
        _content_container._computed_height = _content_height;
        
        // Layout each tab's content
        var _tab_count = array_length(tabs);
        for (var i = 0; i < _tab_count; ++i)
        {
            var _tab_content = tabs[i].content;
            _tab_content.width = _content_width;
            _tab_content.height = _content_height;
            _tab_content._computed_x = i * _content_width;
            _tab_content._computed_y = 0;
            _tab_content._computed_width = _content_width;
            _tab_content._computed_height = _content_height;
            _tab_content.calculate_layout(_content_width, _content_height);
        }
    }
    
    // --- Update Override ---
    
    static update = function()
    {
        if (!visible) return;
        
        // Animate slide
        if (active_index != target_index)
        {
            slide_progress = lerp(slide_progress, target_index, slide_speed);
            if (abs(slide_progress - target_index) < 0.01)
            {
                slide_progress = target_index;
                active_index = target_index;
            }
        }
        
        // Update content positioning logic to match visual slide
        // This ensures input handling works correctly on the sliding content
        // We only modify the X positions of the children of the content container
        var _content_width = _computed_width - padding_left - padding_right;
        var _offset_x = -slide_progress * _content_width;
        
        var _tab_count = array_length(tabs);
        for (var i = 0; i < _tab_count; ++i)
        {
            var _tab_content = tabs[i].content;
            _tab_content._computed_x = i * _content_width + _offset_x;
        }
        
        // Update children
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; ++i)
        {
            children[i].update();
        }
    }
    
    // --- Rendering ---
    
    static draw_self_content = function()
    {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        var _w = _computed_width;
        var _h = _computed_height;
        
        // Draw box background
        draw_background();
        
        // Draw tab bar
        var _tab_count = array_length(tabs);
        if (_tab_count == 0) return;
        
        var _tab_width = (_w - padding_left - padding_right) / _tab_count;
        var _bar_x = _abs_x + padding_left;
        var _bar_y = _abs_y + padding_top;
        
        // Tab bar background
        draw_set_colour(tab_bar_colour);
        draw_set_alpha(1);
        draw_rectangle(_bar_x, _bar_y, _bar_x + (_w - padding_left - padding_right), _bar_y + tab_bar_height, false);
        
        // Draw tabs
        for (var i = 0; i < _tab_count; ++i)
        {
            var _tab_x = _bar_x + i * _tab_width;
            
            // Highlight active tab
            if (i == round(slide_progress))
            {
                draw_set_colour(tab_active_colour);
            }
            else
            {
                draw_set_colour(tab_inactive_colour);
            }
            draw_rectangle(_tab_x + 2, _bar_y + 2, _tab_x + _tab_width - 2, _bar_y + tab_bar_height - 2, false);
            
            // Tab text
            draw_set_colour(c_white);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            render_text(_tab_x + _tab_width / 2, _bar_y + tab_bar_height / 2, tabs[i].name, 1, 1);
        }
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        
        // Draw active indicator
        var _indicator_x = _bar_x + slide_progress * _tab_width;
        draw_set_colour(c_white);
        draw_rectangle(_indicator_x + 4, _bar_y + tab_bar_height - 3, _indicator_x + _tab_width - 4, _bar_y + tab_bar_height - 1, false);
    }
    
    // --- Input Handling ---

    static handle_input = function(_mouse_x, _mouse_y, _mouse_pressed, _mouse_held, _mouse_released)
    {
        if (!visible || !enabled) return undefined;
        
        // Let basic box handling happen (hovers etc)
        // We manually call the "super" logic or simplified logic here if we can't easily call super
        var _hovered = point_in_bounds(_mouse_x, _mouse_y);
        
        // Handle Tab Bar Interaction
        if (_hovered && _mouse_pressed)
        {
             var _abs_x = get_absolute_x();
             var _abs_y = get_absolute_y();
             
             // Check if within tab bar area
             var _bar_x = _abs_x + padding_left;
             var _bar_y = _abs_y + padding_top;
             var _bar_w = _computed_width - padding_left - padding_right;
             
             if (_mouse_x >= _bar_x && _mouse_x < _bar_x + _bar_w && 
                 _mouse_y >= _bar_y && _mouse_y < _bar_y + tab_bar_height)
             {
                 // Calculate index
                 var _tab_count = array_length(tabs);
                 if (_tab_count > 0)
                 {
                     var _tab_width = _bar_w / _tab_count;
                     var _rel_x = _mouse_x - _bar_x;
                     var _index = floor(_rel_x / _tab_width);
                     
                     if (_index >= 0 && _index < _tab_count)
                     {
                         // Lock interaction during transition to prevent state desync
                         if (active_index == target_index)
                         {
                             set_active_tab(_index);
                             sfx_play("phantasia:sfx/menu/button/select", global.settings.audio_ui);
                         }
                         return self; // Consumed click
                     }
                 }
             }
        }
        
        // Pass to children (content container)
        // We need to pass input to the container so the content inside the active tab works
        if (_content_container != undefined)
        {
             var _handled = _content_container.handle_input(_mouse_x, _mouse_y, _mouse_pressed, _mouse_held, _mouse_released);
             if (_handled != undefined) return _handled;
        }

        return _hovered ? self : undefined;
    }

    // --- Draw Override (with clipping for slide) ---
    
    static draw = function()
    {
        if (!visible) return;
        
        draw_self_content();
        
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        var _content_y = _abs_y + padding_top + tab_bar_height;
        var _content_width = _computed_width - padding_left - padding_right;
        var _content_height = _computed_height - padding_top - padding_bottom - tab_bar_height;
        
        // Scissor Calculation with Scale support
        // We need to convert logical coordinates to screen coordinates
        var _scale_x = global.gui_width / 960; // Helper or global constant? Assuming 960 ref.
        var _scale_y = global.gui_height / 540;
        
        var _scissor_x = (_abs_x + padding_left) * _scale_x;
        var _scissor_y = _content_y * _scale_y;
        var _scissor_w = _content_width * _scale_x;
        var _scissor_h = _content_height * _scale_y;
        
        // Set up clipping (using GPU scissor)
        var _prev_scissor = gpu_get_scissor();
        gpu_set_scissor(_scissor_x, _scissor_y, _scissor_w, _scissor_h);
        
        var _tab_count = array_length(tabs);
        for (var i = 0; i < _tab_count; ++i)
        {
            var _tab_content = tabs[i].content;
            
            // Calculate visible position (absolute check for optimization)
            var _tab_abs_x = _tab_content.get_absolute_x();
            
            // Only draw if visible in the viewport logic
            // Simple overlap check with the content box
            var _box_left = _abs_x + padding_left;
            var _box_right = _box_left + _content_width;
            
            if (_tab_abs_x + _content_width > _box_left && _tab_abs_x < _box_right)
            {
                _tab_content.draw();
            }
        }
        
        // Restore scissor
        if (is_struct(_prev_scissor))
        {
             gpu_set_scissor(_prev_scissor.x, _prev_scissor.y, _prev_scissor.w, _prev_scissor.h);
        }
        else if (is_array(_prev_scissor) && array_length(_prev_scissor) >= 4)
        {
            gpu_set_scissor(_prev_scissor[0], _prev_scissor[1], _prev_scissor[2], _prev_scissor[3]);
        }
        else
        {
            // Reset to full window/GUI area if no previous scissor
            gpu_set_scissor(0, 0, display_get_gui_width(), display_get_gui_height());
        }
    }
}
