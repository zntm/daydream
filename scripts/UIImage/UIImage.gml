<<<<<<< HEAD
/// @description UIImage - An image/sprite display component
/// @param {String} _id Optional unique identifier
/// @param {Asset.GMSprite} _sprite Sprite to display
/// @param {Real} _image_index Image index/frame

function UIImage(_id = "", _sprite = -1, _image_index = 0) : UIElement(_id) constructor
{
    sprite = _sprite;
    image_index_value = _image_index;
    
    // Display options
    image_colour = c_white;
    image_alpha = 1;
    image_angle = 0;
    
    // Scale mode: FIT, FILL, STRETCH, NONE
    scale_mode = "NONE";
    
    // Fixed scale (when scale_mode is NONE)
    image_xscale = 1;
    image_yscale = 1;
    
    // Animation
    animate = false;
    animation_speed = 1;
    animation_time = 0;
    
    // --- Fluent Setters ---
    
    static set_sprite = function(_sprite, _index = 0)
    {
        sprite = _sprite;
        image_index_value = _index;
        return self;
    }
    
    static set_image_index = function(_index)
    {
        image_index_value = _index;
        return self;
    }
    
    static set_image_colour = function(_colour, _alpha = 1)
    {
        image_colour = _colour;
        image_alpha = _alpha;
        return self;
    }
    
    static set_image_angle = function(_angle)
    {
        image_angle = _angle;
        return self;
    }
    
    static set_scale_mode = function(_mode)
    {
        scale_mode = _mode; // "FIT", "FILL", "STRETCH", "NONE"
        return self;
    }
    
    static set_image_scale = function(_xscale, _yscale = undefined)
    {
        image_xscale = _xscale;
        image_yscale = (_yscale != undefined) ? _yscale : _xscale;
        return self;
    }
    
    static set_animate = function(_animate, _speed = 1)
    {
        animate = _animate;
        animation_speed = _speed;
        return self;
    }
    
    // --- Content Size ---
    
    static get_content_width = function()
    {
        if (sprite == -1 || !sprite_exists(sprite)) return 0;
        return sprite_get_width(sprite) * image_xscale;
    }
    
    static get_content_height = function()
    {
        if (sprite == -1 || !sprite_exists(sprite)) return 0;
        return sprite_get_height(sprite) * image_yscale;
    }
    
    // --- Update Override ---
    
    static update = function()
    {
        if (!visible) return;
        
        // Handle animation
        if (animate && sprite != -1 && sprite_exists(sprite))
        {
            animation_time += animation_speed * global.delta_time * 60; // Adjusted for delta time
            var _frame_count = sprite_get_number(sprite);
            if (_frame_count > 0)
            {
                image_index_value = animation_time mod _frame_count;
            }
        }
        
        if (on_update != undefined) on_update(self);
        
        var _child_count = array_length(children);
        for (var i = 0; i < _child_count; ++i)
        {
            children[i].update();
        }
    }
    
    // --- Rendering ---
    
    static draw_self_content = function()
    {
        if (sprite == -1 || !sprite_exists(sprite)) return;
        
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _sprite_w = sprite_get_width(sprite);
        var _sprite_h = sprite_get_height(sprite);
        var _xoff = sprite_get_xoffset(sprite);
        var _yoff = sprite_get_yoffset(sprite);
        
        // Calculate scale based on mode
        var _scale_x = image_xscale;
        var _scale_y = image_yscale;
        
        switch (scale_mode)
        {
            case "FIT":
                // Scale to fit within bounds, maintaining aspect ratio
                var _ratio_x = _computed_width / _sprite_w;
                var _ratio_y = _computed_height / _sprite_h;
                var _ratio = min(_ratio_x, _ratio_y);
                _scale_x = _ratio;
                _scale_y = _ratio;
                break;
                
            case "FILL":
                // Scale to fill bounds, maintaining aspect ratio (may crop)
                var _ratio_x = _computed_width / _sprite_w;
                var _ratio_y = _computed_height / _sprite_h;
                var _ratio = max(_ratio_x, _ratio_y);
                _scale_x = _ratio;
                _scale_y = _ratio;
                break;
                
            case "STRETCH":
                // Stretch to fill bounds exactly
                _scale_x = _computed_width / _sprite_w;
                _scale_y = _computed_height / _sprite_h;
                break;
                
            case "NONE":
            default:
                // Use fixed scale
                _scale_x = image_xscale;
                _scale_y = image_yscale;
                break;
        }
        
        // Calculate draw position (center in bounds for FIT/FILL)
        var _draw_x = _abs_x + _xoff * _scale_x;
        var _draw_y = _abs_y + _yoff * _scale_y;
        
        if (scale_mode == "FIT" || scale_mode == "FILL")
        {
            var _final_w = _sprite_w * _scale_x;
            var _final_h = _sprite_h * _scale_y;
            _draw_x = _abs_x + (_computed_width - _final_w) / 2 + _xoff * _scale_x;
            _draw_y = _abs_y + (_computed_height - _final_h) / 2 + _yoff * _scale_y;
        }
        
        draw_sprite_ext(sprite, image_index_value, _draw_x, _draw_y, _scale_x, _scale_y, image_angle, image_colour, image_alpha);
=======
/// @desc UI Image Element - displays sprite or surface
/// @param {Real} _x X position
/// @param {Real} _y Y position
/// @param {Asset.GMSprite|Id.Surface} _source Image source
function UIImage(_x, _y, _source) : UIElement(_x, _y, 0, 0) constructor {
    is_surface = false;
    source = _source;
    image_index = 0;
    image_xscale = 1;
    image_yscale = 1;
    image_angle = 0;
    colour = c_white;
    alpha = 1;
    
    /// @desc Set the image source
    /// @param {Asset.GMSprite|Id.Surface|String|Struct} _source New source
    static set_source = function(_source) {
        // Handle $sprite(name) definition
        if (is_struct(_source) && _source[$ "is_sprite_def"]) {
            is_surface = false;
            var _name = _source.sprite_name;
            var _asset = asset_get_index(_name);
            if (_asset != -1 && asset_get_type(_name) == asset_sprite) {
                source = _asset;
            } else {
                show_debug_message($"[UIImage] Warning: Could not resolve sprite '{_name}'");
                source = undefined;
            }
        }
        // Handle $surface(name) definition
        else if (is_struct(_source) && _source[$ "is_surface_def"]) {
            is_surface = true;
            // Surface name is stored - actual surface ID resolved at runtime via binding
            source = _source.surface_name;
        }
        // Handle string name (legacy)
        else if (is_string(_source)) {
            is_surface = false;
            var _asset = asset_get_index(_source);
            if (_asset != -1 && asset_get_type(_source) == asset_sprite) {
                source = _asset;
            } else {
                show_debug_message($"[UIImage] Warning: Could not resolve sprite asset '{_source}'");
                source = undefined;
            }
        }
        // Handle direct sprite/surface asset
        else {
            source = _source;
        }
        
        // Update dimensions
        if (source != undefined) {
            if (is_surface && surface_exists(source)) {
                width = surface_get_width(source);
                height = surface_get_height(source);
            } else if (!is_surface && sprite_exists(source)) {
                width = sprite_get_width(source);
                height = sprite_get_height(source);
            }
        }
        
        return self;
    }
    
    static draw_content = function() {
        if (source == undefined) return;
        
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        // Use base_scale for uniform pixel scaling to match positions
        var _pixel_scale_x = _base_scale.x;
        var _pixel_scale_y = _base_scale.y;
        
        if (is_surface) {
            if (surface_exists(source)) {
                var _draw_x = _abs_x * _base_scale.x;
                var _draw_y = _abs_y * _base_scale.y;
                draw_surface_ext(source, _draw_x, _draw_y, 
                    image_xscale * _pixel_scale_x, 
                    image_yscale * _pixel_scale_y, 
                    image_angle, colour, alpha);
            }
        } else if (sprite_exists(source)) {
            // Get sprite origin for correct positioning
            var _ox = sprite_get_xoffset(source);
            var _oy = sprite_get_yoffset(source);
            
            // Calculate draw position accounting for origin offset
            // The position in .ui is the top-left corner, but draw_sprite_ext draws from origin
            var _draw_x = (_abs_x * _base_scale.x) + (_ox * _pixel_scale_x * image_xscale);
            var _draw_y = (_abs_y * _base_scale.y) + (_oy * _pixel_scale_y * image_yscale);
            
            draw_sprite_ext(source, image_index, _draw_x, _draw_y,
                image_xscale * _pixel_scale_x,
                image_yscale * _pixel_scale_y,
                image_angle, colour, alpha);
        }
>>>>>>> region
    }
}
