/// @desc UI Image Element - displays sprite or surface
/// @param {Real} _x X position
/// @param {Real} _y Y position
/// @param {Asset.GMSprite|Id.Surface} _source Image source
function UIImage(_x, _y, _source) : UIElement(_x, _y, 0, 0) constructor {
    source = _source;
    image_index = 0;
    image_xscale = 1;
    image_yscale = 1;
    image_angle = 0;
    colour = c_white;
    alpha = 1;
    
    // Source type
    is_surface = false;
    
    /// @desc Set the image source
    /// @param {Asset.GMSprite|Id.Surface} _source New source
    static set_source = function(_source) {
        source = _source;
        
        // Update dimensions
        if (source != undefined) {
            if (is_surface) {
                width = surface_get_width(source);
                height = surface_get_height(source);
            } else if (sprite_exists(source)) {
                width = sprite_get_width(source);
                height = sprite_get_height(source);
            }
        }
        
        return self;
    }
    
    static draw_content = function() {
        if (source == undefined) return;
        
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _gui_scale = global.gui_scale;
        var _base_scale_x = _gui_scale * (global.gui_width / 960);
        var _base_scale_y = _gui_scale * (global.gui_height / 540);
        
        var _draw_x = _abs_x * _base_scale_x;
        var _draw_y = _abs_y * _base_scale_y;
        
        if (is_surface) {
            if (surface_exists(source)) {
                draw_surface_ext(source, _draw_x, _draw_y, 
                    image_xscale * _base_scale_x, 
                    image_yscale * _base_scale_y, 
                    image_angle, colour, alpha);
            }
        } else if (sprite_exists(source)) {
            draw_sprite_ext(source, image_index, _draw_x, _draw_y,
                image_xscale * _base_scale_x,
                image_yscale * _base_scale_y,
                image_angle, colour, alpha);
        }
    }
}
