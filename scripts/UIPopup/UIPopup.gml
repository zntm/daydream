/* ui popup element - modal dialog container */
/* @param {real} _x x position */
/* @param {real} _y y position */
/* @param {real} _width popup width */
/* @param {real} _height popup height */
function UIPopup(_x, _y, _width, _height) : UIElement(_x, _y, _width, _height) constructor 
{
    /* visual styling */
    background_color = #1a1a2e;
    
    border_color = #4a4a5e;
    
    overlay_color = c_black;
    
    overlay_alpha = 0.5;
    
    
    /* animation */
    alpha = 0;
    
    target_alpha = 0;
    
    fade_speed = 0.15;
    
    
    /* positioning */
    center_on_screen = true;
    
    
    static update = function() 
    {
        /* fade animation */
        alpha = lerp(alpha, target_alpha, fade_speed);
        
        
        if (alpha < 0.01 && target_alpha == 0) 
        {
            visible = false;
        }
        
        
        if !(visible) exit;
        
        
        /* center on screen if needed */
        if (center_on_screen) 
        {
            var _root_w = (variable_global_exists("gui_root") && (global.gui_root != undefined)) ? global.gui_root.width : 960;
            var _root_h = (variable_global_exists("gui_root") && (global.gui_root != undefined)) ? global.gui_root.height : 540;

            x = (_root_w - width) / 2;
            y = (_root_h - height) / 2;
        }
        
        
        update_bindings();
        
        
        /* update children */
        var _child_count = array_length(children);
        
        for (var i = _child_count - 1; i >= 0; --i) 
        {
            children[i].update();
        }

        var _mx = ui_get_mouse_x();
        var _my = ui_get_mouse_y();
        var _left = get_absolute_x();
        var _top = get_absolute_y();
        var _right = _left + width;
        var _bottom = _top + height;
        var _inside_popup = (_mx >= _left && _mx <= _right && _my >= _top && _my <= _bottom);

        if !(_inside_popup)
        {
            global.ui_hover_consumed = true;

            if !(global.ui_input_consumed) && (mouse_check_button_pressed(mb_left))
            {
                global.ui_input_consumed = true;
            }
        }
    }
    
    
    static draw = function() 
    {
        if !(visible) && (alpha < 0.01) exit;
        
        
        var _base_scale = ui_get_base_scale();
        var _base_scale_x = _base_scale.x;
        var _base_scale_y = _base_scale.y;
        
        
        /* draw overlay */
        draw_set_alpha(overlay_alpha * alpha);
        
        draw_rectangle_colour(0, 0, global.window_width, global.window_height, overlay_color, overlay_color, overlay_color, overlay_color, false);
        
        draw_set_alpha(1);
        
        
        /* draw popup */
        draw_set_alpha(alpha);
        
        
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        
        var _x1 = _abs_x * _base_scale_x;
        var _y1 = _abs_y * _base_scale_y;
        var _x2 = _x1 + (width * _base_scale_x);
        var _y2 = _y1 + (height * _base_scale_y);
        
        
        /* draw background */
        if (background_color != undefined)
        {
            draw_rectangle_colour(_x1, _y1, _x2, _y2, background_color, background_color, background_color, background_color, false);
        }
        
        
        /* draw border */
        if (border_color != undefined)
        {
            draw_rectangle_colour(_x1, _y1, _x2, _y2, border_color, border_color, border_color, border_color, true);
        }
        
        
        draw_set_alpha(1);
        
        
        /* draw content */
        draw_content();
        
        
        /* execute custom draw callback if set */
        if (on_draw != undefined)
        {
            on_draw(_x1, _y1, _base_scale_x, _base_scale_y);
        }
        
        
        /* draw children */
        var _child_count = array_length(children);
        
        for (var i = _child_count - 1; i >= 0; --i) 
        {
            children[i].draw();
        }
    }
    
    
    /* show the popup */
    static show = function() 
    {
        visible = true;
        
        target_alpha = 1;
        
        emit_event("on_show");
        
        return self;
    }
    
    
    /* hide the popup */
    static hide = function() 
    {
        target_alpha = 0;
        
        emit_event("on_hide");
        
        return self;
    }
}
