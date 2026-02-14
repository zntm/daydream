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
    }
}
