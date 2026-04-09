/* ui area element - container for layout with optional edge fading */
/* @param {real} _x x position */
/* @param {real} _y y position */
/* @param {real} _width area width */
/* @param {real} _height area height */
function UIArea(_x, _y, _width, _height) : UIElement(_x, _y, _width, _height) constructor 
{
    /* areas are transparent by default */
    background_color = undefined;
    
    
    /* layout defaults */
    layout = UI_LAYOUT.NONE;
    
    spacing = 0;
    
    
    /* edge fade (in pixels, 0 = no fade) */
    fade_top = 0;
    
    fade_right = 0;
    
    fade_bottom = 0;
    
    fade_left = 0;
    
    
    /* set fade from a tuple (top, left, bottom, right) */
    static set_fade = function(_value) 
    {
        if (is_array(_value)) 
        {
            var _len = array_length(_value);
            
            
            if (_len >= 4) 
            {
                fade_top = _value[0];
                fade_left = _value[1];
                fade_bottom = _value[2];
                fade_right = _value[3];
            } 
            else if (_len >= 2) 
            {
                /* (vertical, horizontal) shorthand */
                fade_top = _value[0];
                fade_bottom = _value[0];
                fade_left = _value[1];
                fade_right = _value[1];
            } 
            else if (_len >= 1) 
            {
                /* single value = all sides */
                fade_top = _value[0];
                fade_right = _value[0];
                fade_bottom = _value[0];
                fade_left = _value[0];
            }
        } 
        else 
        {
            /* single number = all sides */
            fade_top = _value;
            fade_right = _value;
            fade_bottom = _value;
            fade_left = _value;
        }
    }
    
    
    static draw_content = function() 
    {
        /* areas are invisible containers by default */
        /* but can have background if set */
    }
    
    
    /* override draw to add fade overlay after children */
    static draw = function() 
    {
        if !(visible) exit;
        
        
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        var _draw_width = ui_layout_resolve_scalar(width, 0);
        var _draw_height = ui_layout_resolve_scalar(height, 0);
        
        
        var _x1 = _abs_x * _base_scale.x;
        var _y1 = _abs_y * _base_scale.y;
        var _x2 = _x1 + (_draw_width * _base_scale.x);
        var _y2 = _y1 + (_draw_height * _base_scale.y);
        
        
        /* draw background if set */
        if (background_color != undefined) 
        {
            draw_set_alpha(background_alpha);
            
            draw_rectangle_colour(_x1, _y1, _x2, _y2, background_color, background_color, background_color, background_color, false);
            
            draw_set_alpha(1);
        }
        
        
        /* draw content */
        draw_content();
        
        
        /* execute custom draw callback if set */
        if (on_draw != undefined)
        {
            on_draw(_x1, _y1, _base_scale.x, _base_scale.y);
        }
        
        
        /* draw children */
        var _child_count = array_length(children);
        
        for (var i = _child_count - 1; i >= 0; --i)
        {
            var _child = children[i];

            if (is_struct(_child)) && struct_exists(_child, "draw")
            {
                _child.draw();
            }
        }
        
        
        /* draw fade overlays after children so they appear on top */
        var _has_fade = (fade_top > 0 || fade_right > 0 || fade_bottom > 0 || fade_left > 0);
        
        if (_has_fade) 
        {
            /* use the background color for fading, or black if no background */
            var _fade_col = background_color ?? c_black;
            
            
            /* top fade: fully opaque at top edge, transparent at fade_top pixels down */
            if (fade_top > 0) 
            {
                var _ft = fade_top * _base_scale.y;
                
                draw_primitive_begin(pr_trianglestrip);
                
                draw_vertex_colour(_x1, _y1, _fade_col, 1);
                draw_vertex_colour(_x2, _y1, _fade_col, 1);
                draw_vertex_colour(_x1, _y1 + _ft, _fade_col, 0);
                draw_vertex_colour(_x2, _y1 + _ft, _fade_col, 0);
                
                draw_primitive_end();
            }
            
            
            /* bottom fade: transparent at fade_bottom pixels up, fully opaque at bottom */
            if (fade_bottom > 0) 
            {
                var _fb = fade_bottom * _base_scale.y;
                
                draw_primitive_begin(pr_trianglestrip);
                
                draw_vertex_colour(_x1, _y2 - _fb, _fade_col, 0);
                draw_vertex_colour(_x2, _y2 - _fb, _fade_col, 0);
                draw_vertex_colour(_x1, _y2, _fade_col, 1);
                draw_vertex_colour(_x2, _y2, _fade_col, 1);
                
                draw_primitive_end();
            }
            
            
            /* left fade: fully opaque at left edge, transparent at fade_left pixels right */
            if (fade_left > 0) 
            {
                var _fl = fade_left * _base_scale.x;
                
                draw_primitive_begin(pr_trianglestrip);
                
                draw_vertex_colour(_x1, _y1, _fade_col, 1);
                draw_vertex_colour(_x1 + _fl, _y1, _fade_col, 0);
                draw_vertex_colour(_x1, _y2, _fade_col, 1);
                draw_vertex_colour(_x1 + _fl, _y2, _fade_col, 0);
                
                draw_primitive_end();
            }
            
            
            /* right fade: transparent at fade_right pixels left, fully opaque at right */
            if (fade_right > 0) 
            {
                var _fr = fade_right * _base_scale.x;
                
                draw_primitive_begin(pr_trianglestrip);
                
                draw_vertex_colour(_x2 - _fr, _y1, _fade_col, 0);
                draw_vertex_colour(_x2, _y1, _fade_col, 1);
                draw_vertex_colour(_x2 - _fr, _y2, _fade_col, 0);
                draw_vertex_colour(_x2, _y2, _fade_col, 1);
                
                draw_primitive_end();
            }
        }
    }
}
