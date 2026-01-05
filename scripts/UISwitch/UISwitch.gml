/// @description UISwitch - A toggle switch component for boolean settings
/// @param {String} _id Optional unique identifier
/// @param {Bool} _value Initial value

function UISwitch(_id = "", _value = false) : UIBox(_id) constructor
{
    value = _value;
    
    // Animation
    switch_progress = _value ? 1 : 0;
    animation_speed = 0.15;
    
    // Sizing
    switch_width = 40;
    switch_height = 20;
    knob_size = 16;
    knob_padding = 2;
    
    // Set fixed size
    width = switch_width;
    height = switch_height;
    width_mode = UI_SIZE_MODE.FIXED;
    height_mode = UI_SIZE_MODE.FIXED;
    
    // Styling
    track_on_colour = make_colour_rgb(80, 160, 80);
    track_off_colour = make_colour_rgb(60, 60, 80);
    knob_colour = c_white;
    
    // State
    focusable = true;
    
    // Callbacks
    on_change = undefined;
    
    // --- Fluent Setters ---
    
    static set_value = function(_value)
    {
        if (value != _value)
        {
            value = _value;
            if (on_change != undefined) on_change(self, value);
        }
        return self;
    }
    
    static get_value = function()
    {
        return value;
    }
    
    static toggle = function()
    {
        set_value(!value);
        return self;
    }
    
    static set_on_colour = function(_colour)
    {
        track_on_colour = _colour;
        return self;
    }
    
    static set_off_colour = function(_colour)
    {
        track_off_colour = _colour;
        return self;
    }
    
    static set_knob_colour = function(_colour)
    {
        knob_colour = _colour;
        return self;
    }
    
    static set_switch_size = function(_width, _height, _knob_size = undefined)
    {
        switch_width = _width;
        switch_height = _height;
        width = _width;
        height = _height;
        
        if (_knob_size != undefined)
        {
            knob_size = _knob_size;
        }
        else
        {
            knob_size = _height - (knob_padding * 2);
        }
        
        return self;
    }
    
    static set_on_change = function(_callback)
    {
        on_change = _callback;
        return self;
    }
    
    // --- Content Size ---
    
    static get_content_width = function()
    {
        return switch_width;
    }
    
    static get_content_height = function()
    {
        return switch_height;
    }
    
    // --- Update Override ---
    
    static update = function()
    {
        if (!visible) return;
        
        // Animate switch position
        var _target = value ? 1 : 0;
        switch_progress = lerp(switch_progress, _target, animation_speed);
        
        if (on_update != undefined) on_update(self);
        
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
        var _previous_state = state;
        
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
                toggle();
                if (global.ui_manager.focused_element == self) state = UI_STATE.FOCUSED;
                else state = UI_STATE.HOVER;
                
                if (on_click != undefined) on_click(self);
                if (on_release != undefined) on_release(self);
            }
            else if (!_mouse_held)
            {
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
            
            if (global.ui_manager.focused_element == self)
            {
                state = UI_STATE.FOCUSED;
            }
            else
            {
                state = UI_STATE.NORMAL;
            }
        }
        
        // Handle keyboard/gamepad activation when focused
        if (state == UI_STATE.FOCUSED)
        {
            if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || gamepad_button_check_pressed(0, gp_face1))
            {
                toggle();
            }
        }
        
        return (_hovered && focusable) ? self : undefined;
    }
    
    // --- Rendering ---
    
    static draw_self_content = function()
    {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _track_colour = merge_colour(track_off_colour, track_on_colour, switch_progress);
        
        // Draw track
        draw_set_colour(_track_colour);
        draw_set_alpha(enabled ? 1 : 0.5);
        draw_roundrect_ext(_abs_x, _abs_y, _abs_x + switch_width, _abs_y + switch_height,
                           switch_height / 2, switch_height / 2, false);
        
        // Draw border on hover/focus
        if (state == UI_STATE.HOVER || state == UI_STATE.FOCUSED || state == UI_STATE.PRESSED)
        {
            draw_set_colour(state == UI_STATE.FOCUSED ? c_white : c_ltgray);
            draw_set_alpha(0.5);
            draw_roundrect_ext(_abs_x, _abs_y, _abs_x + switch_width, _abs_y + switch_height,
                               switch_height / 2, switch_height / 2, true);
        }
        
        // Calculate knob position
        var _knob_min_x = _abs_x + knob_padding;
        var _knob_max_x = _abs_x + switch_width - knob_size - knob_padding;
        var _knob_x = lerp(_knob_min_x, _knob_max_x, switch_progress);
        var _knob_y = _abs_y + (switch_height - knob_size) / 2;
        
        // Draw knob
        draw_set_colour(knob_colour);
        draw_set_alpha(enabled ? 1 : 0.7);
        draw_circle(_knob_x + knob_size / 2, _knob_y + knob_size / 2, knob_size / 2, false);
        
        draw_set_alpha(1);
        draw_set_colour(c_white);
    }
}
