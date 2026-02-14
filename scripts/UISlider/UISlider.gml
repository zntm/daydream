/// @description UISlider - A draggable slider component
/// @param {String} _id Optional unique identifier
/// @param {Real} _min Minimum value
/// @param {Real} _max Maximum value
/// @param {Real} _value Initial value

function UISlider(_id = "", _min = 0, _max = 100, _value = 50) : UIBox(_id) constructor
{
    value = _value;
    min_value = _min;
    max_value = _max;
    step = 1;
    
    // Slider dimensions
    track_height = 4;
    handle_width = 12;
    handle_height = 16;
    
    // Styling
    track_colour = make_colour_rgb(40, 40, 50);
    fill_colour = make_colour_rgb(100, 140, 200);
    handle_colour = c_white;
    
    // State
    dragging = false;
    
    // Callbacks
    on_value_change = undefined;
    
    // Make focusable
    focusable = true;
    
    // Default sizing
    width = 150;
    height = 24;
    width_mode = UI_SIZE_MODE.FIXED;
    height_mode = UI_SIZE_MODE.FIXED;
    
    // --- Fluent Setters ---
    
    static set_value = function(_value)
    {
        var _old_value = value;
        value = clamp(_value, min_value, max_value);
        if (step > 0)
        {
            value = round(value / step) * step;
        }
        if (value != _old_value && on_value_change != undefined)
        {
            on_value_change(self, value);
        }
        return self;
    }
    
    static set_range = function(_min, _max)
    {
        min_value = _min;
        max_value = _max;
        value = clamp(value, min_value, max_value);
        return self;
    }
    
    static set_step = function(_step)
    {
        step = _step;
        return self;
    }
    
    static set_track_style = function(_track_colour, _fill_colour)
    {
        track_colour = _track_colour;
        fill_colour = _fill_colour;
        return self;
    }
    
    static set_handle_style = function(_colour, _width = 12, _height = 16)
    {
        handle_colour = _colour;
        handle_width = _width;
        handle_height = _height;
        return self;
    }
    
    static set_on_value_change = function(_callback)
    {
        on_value_change = _callback;
        return self;
    }
    
    // --- Input Handling Override ---
    
    static handle_input = function(_mouse_x, _mouse_y, _mouse_pressed, _mouse_held, _mouse_released)
    {
        if (!visible || !enabled) return undefined;
        
        var _hovered = point_in_bounds(_mouse_x, _mouse_y);
        var _abs_x = get_absolute_x();
        var _track_width = _computed_width - handle_width;
        
        if (_mouse_pressed && _hovered)
        {
            dragging = true;
            state = UI_STATE.PRESSED;
        }
        
        if (dragging)
        {
            if (_mouse_held)
            {
                var _rel_x = _mouse_x - _abs_x - (handle_width / 2);
                var _ratio = clamp(_rel_x / _track_width, 0, 1);
                set_value(lerp(min_value, max_value, _ratio));
            }
            else
            {
                dragging = false;
                state = _hovered ? UI_STATE.HOVER : UI_STATE.NORMAL;
            }
        }
        else
        {
            if (_hovered)
            {
                state = UI_STATE.HOVER;
            }
            else
            {
                state = UI_STATE.NORMAL;
            }
        }
        
        // Handle keyboard input when focused
        if (state == UI_STATE.FOCUSED)
        {
            var _multiplier = keyboard_check(vk_shift) ? 5 : 1;
            
            if (keyboard_check_pressed(vk_right))
            {
                set_value(value + step * _multiplier);
                return self; // Consume input
            }
            if (keyboard_check_pressed(vk_left))
            {
                set_value(value - step * _multiplier);
                return self; // Consume input
            }
        }
        
        return (_hovered && focusable) ? self : undefined;
    }
    
    // --- Rendering ---
    
    static draw_self_content = function()
    {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        var _w = _computed_width;
        var _h = _computed_height;
        
        var _track_y = _abs_y + (_h - track_height) / 2;
        var _track_width = _w - handle_width;
        var _ratio = (value - min_value) / (max_value - min_value);
        
        // Draw track background
        draw_set_colour(track_colour);
        draw_set_alpha(1);
        draw_rectangle(_abs_x + handle_width / 2, _track_y, _abs_x + _w - handle_width / 2, _track_y + track_height, false);
        
        // Draw fill
        draw_set_colour(fill_colour);
        draw_rectangle(_abs_x + handle_width / 2, _track_y, _abs_x + handle_width / 2 + _track_width * _ratio, _track_y + track_height, false);
        
        // Draw handle
        var _handle_x = _abs_x + (_track_width * _ratio);
        var _handle_y = _abs_y + (_h - handle_height) / 2;
        
        // Handle colour based on state
        if (state == UI_STATE.PRESSED || dragging)
        {
            draw_set_colour(fill_colour);
        }
        else if (state == UI_STATE.HOVER || state == UI_STATE.FOCUSED)
        {
            draw_set_colour(c_ltgray);
        }
        else
        {
            draw_set_colour(handle_colour);
        }
        
        draw_roundrect_ext(_handle_x, _handle_y, _handle_x + handle_width, _handle_y + handle_height, 2, 2, false);
        
        // Draw border when focused
        if (state == UI_STATE.FOCUSED)
        {
            draw_set_colour(fill_colour);
            draw_set_alpha(0.5);
            draw_roundrect_ext(_handle_x - 1, _handle_y - 1, _handle_x + handle_width + 1, _handle_y + handle_height + 1, 2, 2, true);
        }
        
        draw_set_alpha(1);
        draw_set_colour(c_white);
    }
}
