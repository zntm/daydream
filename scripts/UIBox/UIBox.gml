/// @description UIBox - A styled container element
/// @param {String} _id Optional unique identifier

function UIBox(_id = "") : UIElement(_id) constructor
{
    // --- Box Styling ---
    background_colour = c_dkgray;
    background_alpha = 0.8;
    
    border_colour = c_white;
    border_alpha = 0.5;
    border_width = 0;
    
    corner_radius = 0;
    
    // --- Fluent Setters ---
    
    static set_background = function(_colour, _alpha = 1)
    {
        background_colour = _colour;
        background_alpha = _alpha;
        return self;
    }
    
    static set_border = function(_colour, _width = 1, _alpha = 1)
    {
        border_colour = _colour;
        border_width = _width;
        border_alpha = _alpha;
        return self;
    }
    
    static set_corner_radius = function(_radius)
    {
        corner_radius = _radius;
        return self;
    }
    
    // --- Rendering ---
    
    static draw_background = function()
    {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        var _w = _computed_width;
        var _h = _computed_height;
        
        // Draw background
        if (background_alpha > 0)
        {
            draw_set_colour(background_colour);
            draw_set_alpha(background_alpha);
            
            if (corner_radius > 0)
            {
                draw_roundrect_ext(_abs_x, _abs_y, _abs_x + _w, _abs_y + _h, corner_radius, corner_radius, false);
            }
            else
            {
                draw_rectangle(_abs_x, _abs_y, _abs_x + _w, _abs_y + _h, false);
            }
        }
        
        // Draw border
        if (border_width > 0 && border_alpha > 0)
        {
            draw_set_colour(border_colour);
            draw_set_alpha(border_alpha);
            
            if (corner_radius > 0)
            {
                draw_roundrect_ext(_abs_x, _abs_y, _abs_x + _w, _abs_y + _h, corner_radius, corner_radius, true);
            }
            else
            {
                draw_rectangle(_abs_x, _abs_y, _abs_x + _w, _abs_y + _h, true);
            }
        }
        
        draw_set_alpha(1);
        draw_set_colour(c_white);
    }

    static draw_self_content = function()
    {
        draw_background();
    }
}
