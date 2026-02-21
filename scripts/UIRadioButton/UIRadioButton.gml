/* ui radio button element - exclusive selection option */
/* @param {real} _x x position */
/* @param {real} _y y position */
/* @param {string} _text label text */
function UIRadioButton(_x, _y, _text = "") : UIElement(_x, _y, 100, 20) constructor 
{
    text = _text;
    
    value = ""; /* the value this button represents */
    
    group = ""; /* radio group name */
    
    selected = false;
    
    
    /* visual styling */
    circle_size = 8;
    
    circle_color = #3a3a4a;
    
    selected_color = #4a8aff;
    
    text_color = c_white;
    
    
    /* hover state */
    is_hovered = false;
    
    
    static update = function() 
    {
        if !(visible) exit;
        
        
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        
        var _base_scale = ui_get_base_scale();
        var _base_scale_x = _base_scale.x;
        var _base_scale_y = _base_scale.y;
        
        
        var _mx = (window_mouse_get_x() / global.window_width) * global.gui_width;
        var _my = (window_mouse_get_y() / global.window_height) * global.gui_height;
        
        
        var _left = _abs_x * _base_scale_x;
        var _top = _abs_y * _base_scale_y;
        var _right = _left + (width * _base_scale_x);
        var _bottom = _top + (height * _base_scale_y);
        
        
        is_hovered = (_mx >= _left && _mx <= _right && _my >= _top && _my <= _bottom);
        
        
        if (is_hovered) && !(global.ui_input_consumed) && (mouse_check_button_pressed(mb_left)) 
        {
            if !(selected) 
            {
                selected = true;
                
                global.ui_input_consumed = true;
                
                emit_event("on_select", { value: value, group: group });
                
                sfx_play("phantasia:sfx/menu/button/select");
            }
        }
        
        
        update_bindings();
    }
    
    
    static draw_content = function() 
    {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        
        var _base_scale = ui_get_base_scale();
        var _base_scale_x = _base_scale.x;
        var _base_scale_y = _base_scale.y;
        
        
        var _circle_x = (_abs_x + circle_size) * _base_scale_x;
        var _circle_y = (_abs_y + height / 2) * _base_scale_y;
        var _radius = circle_size * _base_scale_x;
        
        
        /* draw outer circle */
        draw_circle_colour(_circle_x, _circle_y, _radius, circle_color, circle_color, false);
        
        
        /* draw selected indicator */
        if (selected) 
        {
            draw_circle_colour(_circle_x, _circle_y, _radius * 0.6, selected_color, selected_color, false);
        }
        
        
        /* draw text */
        if (text != "") 
        {
            var _text_x = (_abs_x + circle_size * 2 + 8) * _base_scale_x;
            var _text_y = _circle_y;
            
            var _prev_halign = draw_get_halign();
            var _prev_valign = draw_get_valign();
            
            draw_set_align(fa_left, fa_middle);
            
            
            draw_text_cuteify(
                _text_x, _text_y,
                text,
                _base_scale_x * 0.8,
                _base_scale_y * 0.8,
                0,
                text_color,
                1
            );
            
            
            draw_set_align(_prev_halign, _prev_valign);
        }
    }
    
    
    /* deselect this radio button (called when another in group is selected) */
    static deselect = function() 
    {
        selected = false;
        
        return self;
    }
}
