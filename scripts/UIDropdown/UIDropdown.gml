/* UI dropdown element - expandable option selector */
/* @param {real} _x x position */
/* @param {real} _y y position */
/* @param {real} _width dropdown width */
/* @param {real} _height collapsed height (single row) */
function UIDropdown(_x, _y, _width, _height) : UIElement(_x, _y, _width, _height) constructor
{
    choices = []; /* array of display strings (aligned with obj_Menu_Dropdown) */
    
    choice_index = 0; /* currently selected option index */
    
    
    is_open = false; /* whether dropdown list is expanded */
    
    
    /* collapsed height (stored separately so height can expand) */
    collapsed_height = _height;
    
    option_height = _height; /* height of each option row */
    
    
    /* visual styling */
    dropdown_color = #2a2a3a;
    
    hover_color = #3a3a5a;
    
    text_color = c_white;
    
    arrow_color = #aaaaaa;
    
    border_color = #4a4a6a;
    
    
    /* interaction state */
    boolean = MENU_BUTTON_BOOL.IS_VISIBLE;
    
    hovered_option = -1;
    
    
    /* =============================================================================
       core methods
       ============================================================================= */
    
    /* set choices array */
    static set_choices = function(_value)
    {
        if (is_array(_value))
        {
            choices = _value;
        }
        
        return self;
    }
    
    
    /* set the selected index */
    static set_selected = function(_value)
    {
        choice_index = clamp(floor(_value), 0, max(0, array_length(choices) - 1));
        
        return self;
    }
    
    
    /* toggle the dropdown open/closed */
    static toggle_open = function()
    {
        is_open = !(is_open);
        
        
        if (is_open)
        {
            height = collapsed_height + array_length(choices) * option_height;
        }
        else
        {
            height = collapsed_height;
            
            hovered_option = -1;
        }
        
        
        /* reflow sibling layout if parent uses vertical/horizontal layout */
        if (parent != undefined)
        {
            if (struct_exists(parent, "layout_children"))
            {
                parent.layout_children();
            }
        }
    }
    
    
    static update = function()
    {
        if !(visible) exit;
        
        
        /* update children */
        var _child_count = array_length(children);
        
        for (var i = _child_count - 1; i >= 0; --i)
        {
            var _child = children[i];

            if (is_struct(_child)) && struct_exists(_child, "update")
            {
                _child.update();
            }
        }
        
        
        var _abs_x = get_interaction_x();
        var _abs_y = get_interaction_y();
        
        
        var _mx = ui_get_mouse_x();
        var _my = ui_get_mouse_y();
        
        
        var _left = _abs_x;
        var _top = _abs_y;
        
        var _right = _left + get_width();
        var _header_bottom = _top + collapsed_height;
        
        
        hovered_option = -1;
        
        
        var _is_header_hovered = (_mx >= _left && _mx <= _right && _my >= _top && _my <= _header_bottom);
        
        
        if (_is_header_hovered && !(global.ui_hover_consumed ?? false))
        {
            boolean |= MENU_BUTTON_BOOL.IS_HOVER;
            
            global.ui_hover_consumed = true;
        }
        else
        {
            if (boolean & MENU_BUTTON_BOOL.IS_HOVER)
            {
                boolean ^= MENU_BUTTON_BOOL.IS_HOVER;
            }
        }
        
        
        if !(global.ui_input_consumed) && (mouse_check_button_pressed(mb_left))
        {
            /* check if clicking the header (toggle area) */
            if (_is_header_hovered)
            {
                global.ui_input_consumed = true;
                
                toggle_open();
            }
            /* check if clicking an option */
            else if (is_open)
            {
                var _opt_count = array_length(choices);
                
                
                for (var i = _opt_count - 1; i >= 0; --i)
                {
                    var _opt_top = _header_bottom + (i * option_height);
                    var _opt_bottom = _opt_top + option_height;
                    
                    
                    if (_mx >= _left && _mx <= _right && _my >= _opt_top && _my <= _opt_bottom)
                    {
                        choice_index = i;
                        
                        global.ui_input_consumed = true;
                        
                        toggle_open(); /* close after selecting */
                        
                        emit_event("on_change", { value: choice_index, option: choices[i] });
                        
                        break;
                    }
                }
                
                
                /* if clicked outside dropdown area entirely, close it */
                var _full_bottom = _header_bottom + (_opt_count * option_height);
                
                
                if (_my < _top || _my > _full_bottom || _mx < _left || _mx > _right)
                {
                    toggle_open();
                }
            }
        }
        
        
        /* track hover for highlighting options */
        if (is_open)
        {
            var _opt_count = array_length(choices);
            
            
            for (var i = _opt_count - 1; i >= 0; --i)
            {
                var _opt_top = _header_bottom + (i * option_height);
                var _opt_bottom = _opt_top + option_height;
                
                
                if (_mx >= _left && _mx <= _right && _my >= _opt_top && _my <= _opt_bottom)
                {
                    hovered_option = i;
                    
                    break;
                }
            }
        }
        
        
        /* update bindings each frame */
        update_bindings();
    }
    
    
    static draw_content = function()
    {
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        
        var _x1 = _abs_x * _base_scale.x;
        var _y1 = _abs_y * _base_scale.y;
        
        var _x2 = _x1 + (get_width() * _base_scale.x);
        var _header_y2 = _y1 + (collapsed_height * _base_scale.y);
        
        
        /* draw header background */
        if (dropdown_color != undefined)
        {
            draw_rectangle_colour(_x1, _y1, _x2, _header_y2, dropdown_color, dropdown_color, dropdown_color, dropdown_color, false);
        }
        
        
        /* draw header border */
        if (border_color != undefined)
        {
            draw_rectangle_colour(_x1, _y1, _x2, _header_y2, border_color, border_color, border_color, border_color, true);
        }
        
        
        /* draw selected text */
        var _text_x = _x1 + (4 * _base_scale.x);
        var _text_y = _y1 + (collapsed_height * _base_scale.y / 2);
        
        var _selected_text = "";
        
        
        if (choice_index >= 0 && choice_index < array_length(choices))
        {
            _selected_text = string(choices[choice_index]);
        }
        
        
        var _prev_halign = draw_get_halign();
        var _prev_valign = draw_get_valign();
        
        draw_set_halign(fa_left);
        draw_set_valign(fa_middle);
        
        
        render_text(_text_x, _text_y, _selected_text, _base_scale.x * 0.8, _base_scale.y * 0.8, 0, text_color, 1);
        
        
        /* draw arrow indicator */
        var _arrow_x = _x2 - (12 * _base_scale.x);
        
        render_text(_arrow_x, _text_y, (is_open ? "^" : "v"), _base_scale.x * 0.8, _base_scale.y * 0.8, 0, arrow_color, 1);
        
        
        /* draw expanded options */
        if (is_open)
        {
            var _opt_count = array_length(choices);
            
            
            for (var i = 0; i < _opt_count; ++i)
            {
                var _opt_top = _header_y2 + (i * option_height * _base_scale.y);
                var _opt_bottom = _opt_top + (option_height * _base_scale.y);
                
                
                /* background (highlighted if hovered) */
                var _bg = (i == hovered_option) ? hover_color : dropdown_color;
                
                if (_bg != undefined)
                {
                    draw_rectangle_colour(_x1, _opt_top, _x2, _opt_bottom, _bg, _bg, _bg, _bg, false);
                }
                
                
                /* border */
                if (border_color != undefined)
                {
                    draw_rectangle_colour(_x1, _opt_top, _x2, _opt_bottom, border_color, border_color, border_color, border_color, true);
                }
                
                
                /* text */
                var _opt_text_y = _opt_top + (option_height * _base_scale.y / 2);
                
                render_text(_text_x, _opt_text_y, string(choices[i]), _base_scale.x * 0.8, _base_scale.y * 0.8, 0, text_color, 1);
            }
        }
        
        
        draw_set_halign(_prev_halign);
        draw_set_valign(_prev_valign);
    }
}
