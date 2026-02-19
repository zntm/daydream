/// @desc UI Area Element - container for layout with optional edge fading
/// @param {Real} _x X position
/// @param {Real} _y Y position
/// @param {Real} _width Area width
/// @param {Real} _height Area height
function UIArea(_x, _y, _width, _height) : UIElement(_x, _y, _width, _height) constructor {
    // Areas are transparent by default
    background_color = undefined;
    
    // Layout defaults
    layout = UI_LAYOUT.NONE;
    spacing = 0;
    
    // Edge fade (in pixels, 0 = no fade)
    fade_top = 0;
    fade_right = 0;
    fade_bottom = 0;
    fade_left = 0;
    
    /// @desc Set fade from a tuple (top, left, bottom, right)
    static set_fade = function(_value) {
        if (is_array(_value)) {
            var _len = array_length(_value);
            
            if (_len >= 4) {
                fade_top = _value[0];
                fade_left = _value[1];
                fade_bottom = _value[2];
                fade_right = _value[3];
            } else if (_len >= 2) {
                // (vertical, horizontal) shorthand
                fade_top = _value[0];
                fade_bottom = _value[0];
                fade_left = _value[1];
                fade_right = _value[1];
            } else if (_len >= 1) {
                // Single value = all sides
                fade_top = _value[0];
                fade_right = _value[0];
                fade_bottom = _value[0];
                fade_left = _value[0];
            }
        } else {
            // Single number = all sides
            fade_top = _value;
            fade_right = _value;
            fade_bottom = _value;
            fade_left = _value;
        }
    }
    
    static draw_content = function() {
        // Areas are invisible containers by default
        // But can have background if set
    }
    
    /// @desc Override draw to add fade overlay after children
    static draw = function() {
        if (!visible) exit;
        
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _x1 = _abs_x * _base_scale.x;
        var _y1 = _abs_y * _base_scale.y;
        var _x2 = _x1 + (width * _base_scale.x);
        var _y2 = _y1 + (height * _base_scale.y);
        
        /* Draw background if set */
        if (background_color != undefined) {
            draw_set_alpha(background_alpha);
            draw_rectangle_colour(_x1, _y1, _x2, _y2,
                background_color, background_color, background_color, background_color, false);
            draw_set_alpha(1);
        }
        
        /* Draw content */
        draw_content();
        
        /* Draw children */
        var _child_count = array_length(children);
        
        for (var i = 0; i < _child_count; ++i) {
            children[i].draw();
        }
        
        /* Draw fade overlays AFTER children so they appear on top */
        var _has_fade = (fade_top > 0 || fade_right > 0 || fade_bottom > 0 || fade_left > 0);
        
        if (_has_fade) {
            /* Use the background color for fading, or black if no background */
            var _fade_col = background_color ?? c_black;
            
            /* Top fade: fully opaque at top edge, transparent at fade_top pixels down */
            if (fade_top > 0) {
                var _ft = fade_top * _base_scale.y;
                
                draw_primitive_begin(pr_trianglestrip);
                // Top-left corner (opaque)
                draw_vertex_colour(_x1, _y1, _fade_col, 1);
                // Top-right corner (opaque)
                draw_vertex_colour(_x2, _y1, _fade_col, 1);
                // Bottom-left of fade strip (transparent)
                draw_vertex_colour(_x1, _y1 + _ft, _fade_col, 0);
                // Bottom-right of fade strip (transparent)
                draw_vertex_colour(_x2, _y1 + _ft, _fade_col, 0);
                draw_primitive_end();
            }
            
            /* Bottom fade: transparent at fade_bottom pixels up, fully opaque at bottom */
            if (fade_bottom > 0) {
                var _fb = fade_bottom * _base_scale.y;
                
                draw_primitive_begin(pr_trianglestrip);
                // Top-left of fade strip (transparent)
                draw_vertex_colour(_x1, _y2 - _fb, _fade_col, 0);
                // Top-right of fade strip (transparent)
                draw_vertex_colour(_x2, _y2 - _fb, _fade_col, 0);
                // Bottom-left corner (opaque)
                draw_vertex_colour(_x1, _y2, _fade_col, 1);
                // Bottom-right corner (opaque)
                draw_vertex_colour(_x2, _y2, _fade_col, 1);
                draw_primitive_end();
            }
            
            /* Left fade: fully opaque at left edge, transparent at fade_left pixels right */
            if (fade_left > 0) {
                var _fl = fade_left * _base_scale.x;
                
                draw_primitive_begin(pr_trianglestrip);
                // Top-left corner (opaque)
                draw_vertex_colour(_x1, _y1, _fade_col, 1);
                // Top at fade_left (transparent)
                draw_vertex_colour(_x1 + _fl, _y1, _fade_col, 0);
                // Bottom-left corner (opaque)
                draw_vertex_colour(_x1, _y2, _fade_col, 1);
                // Bottom at fade_left (transparent)
                draw_vertex_colour(_x1 + _fl, _y2, _fade_col, 0);
                draw_primitive_end();
            }
            
            /* Right fade: transparent at fade_right pixels left, fully opaque at right */
            if (fade_right > 0) {
                var _fr = fade_right * _base_scale.x;
                
                draw_primitive_begin(pr_trianglestrip);
                // Top at fade start (transparent)
                draw_vertex_colour(_x2 - _fr, _y1, _fade_col, 0);
                // Top-right corner (opaque)
                draw_vertex_colour(_x2, _y1, _fade_col, 1);
                // Bottom at fade start (transparent)
                draw_vertex_colour(_x2 - _fr, _y2, _fade_col, 0);
                // Bottom-right corner (opaque)
                draw_vertex_colour(_x2, _y2, _fade_col, 1);
                draw_primitive_end();
            }
        }
    }
}
