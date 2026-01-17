/// @description GUI Choice Panel component - displays selectable choices
/// @param {Real} _x X position relative to parent
/// @param {Real} _y Y position relative to parent
/// @param {Real} _width Panel width

function GUIChoicePanel(_x, _y, _width = 200) : GUIComponent(_x, _y, _width, 0) constructor
{
    choices = [];
    selected_index = 0;
    callback = undefined;
    choice_height = 10;
    padding = 8;
    
    last_mouse_x = -1;
    last_mouse_y = -1;
    
    /// @description Set the choices to display
    /// @param {Array<String>} _choices Array of choice strings
    /// @param {Function} _callback Function called with (index, choice_text) when selected
    static set_choices = function(_choices, _callback)
    {
        // Only reset selected_index if choices actually changed
        var _changed = (array_length(choices) != array_length(_choices));
        if (!_changed)
        {
            var _length = array_length(_choices);
            for (var i = 0; i < _length; ++i)
            {
                if (choices[i] != _choices[i])
                {
                    _changed = true;
                    break;
                }
            }
        }
        
        choices = _choices;
        callback = _callback;
        
        if (_changed)
        {
            selected_index = 0;
        }
        
        // Clamp selected_index to valid range
        selected_index = clamp(selected_index, 0, max(0, array_length(_choices) - 1));
        
        height = array_length(_choices) * choice_height + padding * 2;
        visible = true;
        return self;
    }
    
    /// @description Clear all choices and hide the panel
    static clear_choices = function()
    {
        choices = [];
        callback = undefined;
        selected_index = 0;
        height = 0;
        visible = false;
        return self;
    }
    
    static update = function()
    {
        if (!visible) || (array_length(choices) == 0) exit;
        
        var _choice_count = array_length(choices);
        
        // Mouse hover/click - use logical coordinates (unscaled)
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _window_width = global.window_width;
        var _window_height = global.window_height;
        var _gui_width = global.gui_width;
        var _gui_height = global.gui_height;
        
        // Convert mouse to logical GUI coordinates
        var _gui_scale = global.gui_scale * (_gui_width / 960);
        var _mouse_x = (window_mouse_get_x() / _window_width) * _gui_width / _gui_scale;
        var _mouse_y = (window_mouse_get_y() / _window_height) * _gui_height / _gui_scale;
        
        // Only update selection if mouse moved
        var _mouse_moved = (_mouse_x != last_mouse_x) || (_mouse_y != last_mouse_y);
        last_mouse_x = _mouse_x;
        last_mouse_y = _mouse_y;
        
        if (_mouse_moved)
        {
            for (var i = 0; i < _choice_count; ++i)
            {
                var _choice_y = _abs_y + padding + i * choice_height;
                
                if (_mouse_x >= _abs_x) && (_mouse_x <= _abs_x + width)
                && (_mouse_y >= _choice_y) && (_mouse_y <= _choice_y + choice_height)
                {
                    selected_index = i;
                    break;
                }
            }
        }
        
        // Handle click (always check)
        if (mouse_check_button_pressed(mb_left))
        {
            for (var i = 0; i < _choice_count; ++i)
            {
                var _choice_y = _abs_y + padding + i * choice_height;
                
                if (_mouse_x >= _abs_x) && (_mouse_x <= _abs_x + width)
                && (_mouse_y >= _choice_y) && (_mouse_y <= _choice_y + choice_height)
                {
                    select_choice(i);
                    exit;
                }
            }
        }
    }
    
    /// @description Select a choice by index
    /// @param {Real} _index Choice index
    static select_choice = function(_index)
    {
        if (_index < 0) || (_index >= array_length(choices)) exit;
        
        if (callback != undefined)
        {
            callback(_index, choices[_index]);
        }
        
        clear_choices();
    }
    
    static draw_content = function()
    {
        if (array_length(choices) == 0) exit;
        
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _gui_scale = global.gui_scale;
        var _base_scale_x = _gui_scale * (global.gui_width / 960);
        var _base_scale_y = _gui_scale * (global.gui_height / 540);
        
        var _scale_x = _base_scale_x * scale;
        var _scale_y = _base_scale_y * scale;
        
        var _panel_x = _abs_x * _scale_x;
        var _panel_y = _abs_y * _scale_y;
        var _panel_width = width * _scale_x;
        var _panel_height = height * _scale_y;
        
        // Draw background
        draw_set_alpha(0.85);
        draw_rectangle_colour(_panel_x, _panel_y, _panel_x + _panel_width, _panel_y + _panel_height, #1a1a2e, #1a1a2e, #16213e, #16213e, false);
        draw_set_alpha(1);
        
        // Draw border
        draw_rectangle_colour(_panel_x, _panel_y, _panel_x + _panel_width, _panel_y + _panel_height, #4a4e69, #4a4e69, #4a4e69, #4a4e69, true);
        
        // Draw choices
        var _choice_count = array_length(choices);
        
        for (var i = 0; i < _choice_count; ++i)
        {
            var _choice_y = _panel_y + (padding + i * choice_height) * _scale_y;
            var _is_selected = (i == selected_index);
            
            // Highlight selected
            if (_is_selected)
            {
                draw_set_alpha(0.4);
                draw_rectangle_colour(
                    _panel_x + 2 * _scale_x,
                    _choice_y,
                    _panel_x + _panel_width - 2 * _scale_x,
                    _choice_y + choice_height * _scale_y,
                    #4a4e69, #4a4e69, #4a4e69, #4a4e69,
                    false
                );
                draw_set_alpha(1);
            }
            
            // Draw choice text
            var _colour = _is_selected ? #ffd369 : c_white;
            var _text = $"{choices[i]}";
            
            draw_text_cuteify(
                (_panel_x + padding * _scale_x),
                _choice_y + (choice_height * _scale_y * 0.15), // Adjusted vertical centering
                _text,
                _scale_x * 0.2,
                _scale_y * 0.2,
                0,
                _colour,
                1
            );
        }
    }
}
