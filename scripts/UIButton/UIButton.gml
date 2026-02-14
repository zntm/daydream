/// @description UIButton - Interactive button component
/// @param {String} _id Optional unique identifier
/// @param {String} _text Button label text

function UIButton(_id = "", _text = "") : UIBox(_id) constructor
{
    text = _text;
    text_colour = c_white;
    text_scale = 1;
    
    // State-based styling
    normal_colour = make_colour_rgb(60, 60, 80);
    hover_colour = make_colour_rgb(80, 80, 120);
    pressed_colour = make_colour_rgb(40, 40, 60);
    disabled_colour = make_colour_rgb(40, 40, 40);
    
    normal_border = make_colour_rgb(100, 100, 140);
    hover_border = make_colour_rgb(140, 140, 200);
    
    // Make buttons focusable by default
    focusable = true;
    
    // Default padding
    padding_left = 12;
    padding_right = 12;
    padding_top = 8;
    padding_bottom = 8;
    
    // Default border
    border_width = 1;
    border_colour = normal_border;
    corner_radius = 4;
    
    // --- Fluent Setters ---
    
    static set_button_text = function(_text)
    {
        text = _text;
        return self;
    }
    
    static set_text_colour = function(_colour)
    {
        text_colour = _colour;
        return self;
    }
    
    static set_text_scale = function(_scale)
    {
        text_scale = _scale;
        return self;
    }
    
    static set_normal_colour = function(_bg, _border = undefined)
    {
        normal_colour = _bg;
        if (_border != undefined) normal_border = _border;
        return self;
    }
    
    static set_hover_colour = function(_bg, _border = undefined)
    {
        hover_colour = _bg;
        if (_border != undefined) hover_border = _border;
        return self;
    }
    
    static set_pressed_colour = function(_bg)
    {
        pressed_colour = _bg;
        return self;
    }
    
    static set_disabled_colour = function(_bg)
    {
        disabled_colour = _bg;
        return self;
    }
    
    // --- Content Size ---
    
    static get_content_width = function()
    {
        return string_length(text) * 6 * text_scale;
    }
    
    static get_content_height = function()
    {
        return 8 * text_scale;
    }
    
    // --- Rendering ---
    
    static draw_self_content = function()
    {
        // Update colours based on state
        if (!enabled)
        {
            background_colour = disabled_colour;
            border_colour = disabled_colour;
        }
        else
        {
            // Sync visual state with input for focused buttons
            var _is_pressed = (state == UI_STATE.PRESSED) || 
                              (state == UI_STATE.FOCUSED && (keyboard_check(vk_enter) || keyboard_check(vk_space) || gamepad_button_check(0, gp_face1)));
            
            if (_is_pressed)
            {
                background_colour = pressed_colour;
                border_colour = hover_border;
            }
            else
            {
                switch (state)
                {
                    case UI_STATE.NORMAL:
                        background_colour = normal_colour;
                        border_colour = normal_border;
                        break;
                    case UI_STATE.HOVER:
                        background_colour = hover_colour;
                        border_colour = hover_border;
                        break;
                    case UI_STATE.FOCUSED:
                        background_colour = hover_colour; // Same bg as hover
                        border_colour = c_white; // Distinct bright border for focus
                        break;
                }
            }
        }
        
        // Draw box background
        draw_background();
        
        // Draw text
        if (text != "")
        {
            var _abs_x = get_absolute_x() + _computed_width / 2;
            var _abs_y = get_absolute_y() + _computed_height / 2;
            
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            
            // Draw shadow
            draw_set_colour(c_black);
            draw_set_alpha(0.3);
            render_text(_abs_x, _abs_y + text_scale, text, text_scale, text_scale);
            
            // Draw main text
            draw_set_colour(enabled ? text_colour : c_gray);
            draw_set_alpha(1);
            render_text(_abs_x, _abs_y, text, text_scale, text_scale);
            
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_colour(c_white);
        }
    }
}
