/// @desc UI Bar Element - progress/health bar display with custom nine-slice rendering
/// @param {Real} _x X position
/// @param {Real} _y Y position
/// @param {Real} _width Bar width (in logical units, stretched via nine-slice)
/// @param {Real} _height Bar height (in logical units)
/// @param {Real} _min Minimum value
/// @param {Real} _max Maximum value
/// @param {Real} _value Current value
function UIBar(_x, _y, _width, _height, _min, _max, _value) : UIElement(_x, _y, _width, _height) constructor {
    min_value = _min;
    max_value = _max;
    value = clamp(_value, _min, _max);
    
    // Sprite-based rendering (takes priority)
    sprite_empty = undefined;  // Sprite for empty bar background
    sprite_fill = undefined;   // Sprite for filled portion
    
    // Nine-slice margins (in sprite pixels, before scaling)
    // These define how much of the left/right edges are preserved
    slice_left = 1;   // Left edge pixels to preserve
    slice_right = 4;  // Right edge pixels to preserve
    
    // Color-based fallback styling
    background_color = #1a1a2a;
    fill_color = #4aff4a;
    border_color = #3a3a4a;
    
    // Animation
    display_value = _value;
    smooth = true;
    smooth_speed = 0.15;
    
    // Edge fade (for color mode)
    edge_fade = false;
    edge_fade_width = 4;
    
    /// @desc Set the empty sprite by name or asset
    static set_sprite_empty = function(_source) {
        if (is_string(_source)) {
            var _asset = asset_get_index(_source);
            if (_asset != -1 && asset_get_type(_source) == asset_sprite) {
                sprite_empty = _asset;
            } else {
                show_debug_message($"[UIBar] Warning: Could not resolve empty sprite '{_source}'");
            }
        } else if (sprite_exists(_source)) {
            sprite_empty = _source;
        }
        return self;
    }
    
    /// @desc Set the fill sprite by name or asset
    static set_sprite_fill = function(_source) {
        if (is_string(_source)) {
            var _asset = asset_get_index(_source);
            if (_asset != -1 && asset_get_type(_source) == asset_sprite) {
                sprite_fill = _asset;
            } else {
                show_debug_message($"[UIBar] Warning: Could not resolve fill sprite '{_source}'");
            }
        } else if (sprite_exists(_source)) {
            sprite_fill = _source;
        }
        return self;
    }
    
    /// @desc Set the left slice margin
    static set_slice_left = function(_value) {
        if (is_real(_value)) slice_left = _value;
        return self;
    }
    
    /// @desc Set the right slice margin
    static set_slice_right = function(_value) {
        if (is_real(_value)) slice_right = _value;
        return self;
    }
    
    static update = function() {
        if (!visible) return;
        
        // Smooth animation
        if (smooth) {
            display_value = lerp(display_value, value, smooth_speed);
        } else {
            display_value = value;
        }
        
        update_bindings();
    }
    
    /// @desc Draw a sprite with custom nine-slice stretching
    /// @param {Asset.GMSprite} _sprite Sprite to draw
    /// @param {Real} _dx Draw X position
    /// @param {Real} _dy Draw Y position
    /// @param {Real} _target_width Target width to stretch to
    /// @param {Real} _target_height Target height to stretch to
    /// @param {Real} _scale Uniform pixel scale (1 = original, 2 = 2x pixels, etc.)
    static draw_nine_slice_bar = function(_sprite, _dx, _dy, _target_width, _target_height, _scale) {
        if (!sprite_exists(_sprite)) return;
        
        var _sw = sprite_get_width(_sprite);
        var _sh = sprite_get_height(_sprite);
        
        // Get sprite origin offset
        var _ox = sprite_get_xoffset(_sprite);
        var _oy = sprite_get_yoffset(_sprite);
        
        // Nine-slice margins (scaled)
        var _left = slice_left * _scale;
        var _right = slice_right * _scale;
        var _mid_src_w = _sw - slice_left - slice_right; // Source middle width in sprite pixels
        
        // Target dimensions
        var _mid_target_w = _target_width - _left - _right; // How much to stretch the middle
        
        // Avoid negative middle widths
        if (_mid_target_w < 0) {
            // Just draw stretched if too small
            draw_sprite_stretched(_sprite, 0, _dx, _dy, _target_width, _target_height);
            return;
        }
        
        // Draw left edge (scaled uniformly, no stretch)
        draw_sprite_part_ext(_sprite, 0, 
            0, 0, slice_left, _sh,  // Source rect
            _dx, _dy, _scale, _target_height / _sh,  // Draw position and scale
            c_white, 1);
        
        // Draw middle (stretched horizontally)
        if (_mid_src_w > 0 && _mid_target_w > 0) {
            draw_sprite_part_ext(_sprite, 0,
                slice_left, 0, _mid_src_w, _sh,  // Source rect
                _dx + _left, _dy, _mid_target_w / _mid_src_w, _target_height / _sh,  // Stretched
                c_white, 1);
        }
        
        // Draw right edge (scaled uniformly, no stretch)
        draw_sprite_part_ext(_sprite, 0,
            _sw - slice_right, 0, slice_right, _sh,  // Source rect
            _dx + _target_width - _right, _dy, _scale, _target_height / _sh,  // Draw position and scale
            c_white, 1);
    }
    
    static draw_content = function() {
        var _base_scale = ui_get_base_scale();
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        
        var _x1 = _abs_x * _base_scale.x;
        var _y1 = _abs_y * _base_scale.y;
        var _draw_width = width * _base_scale.x;
        var _draw_height = height * _base_scale.y;
        
        // Use the vertical base scale as the uniform pixel scale for sprite edges
        var _pixel_scale = _base_scale.y;
        
        // Calculate fill percentage
        var _t = (display_value - min_value) / (max_value - min_value);
        _t = clamp(_t, 0, 1);
        
        // Sprite-based rendering with custom nine-slice
        if (sprite_empty != undefined && sprite_exists(sprite_empty)) {
            // Draw empty bar (background)
            draw_nine_slice_bar(sprite_empty, _x1, _y1, _draw_width, _draw_height, _pixel_scale);
            
            // Draw fill bar with clipped width
            if (sprite_fill != undefined && sprite_exists(sprite_fill) && _t > 0) {
                var _fill_width = _draw_width * _t;
                // Need at least the left + right edges worth of width
                var _min_width = (slice_left + slice_right) * _pixel_scale;
                if (_fill_width >= _min_width) {
                    draw_nine_slice_bar(sprite_fill, _x1, _y1, _fill_width, _draw_height, _pixel_scale);
                } else if (_fill_width > 0) {
                    // Very small fill - just draw left portion
                    var _sh = sprite_get_height(sprite_fill);
                    draw_sprite_part_ext(sprite_fill, 0,
                        0, 0, min(sprite_get_width(sprite_fill), _fill_width / _pixel_scale), _sh,
                        _x1, _y1, _pixel_scale, _draw_height / _sh,
                        c_white, 1);
                }
            }
        } else {
            // Fallback: Color-based rendering
            var _x2 = _x1 + _draw_width;
            var _y2 = _y1 + _draw_height;
            
            // Draw background
            draw_rectangle_colour(_x1, _y1, _x2, _y2,
                background_color, background_color, background_color, background_color, false);
            
            // Draw fill
            var _fill_x2 = lerp(_x1, _x2, _t);
            if (_fill_x2 > _x1) {
                if (edge_fade) {
                    var _fade_start = _fill_x2 - (edge_fade_width * _base_scale.x);
                    if (_fade_start > _x1) {
                        draw_rectangle_colour(_x1, _y1, _fade_start, _y2,
                            fill_color, fill_color, fill_color, fill_color, false);
                        draw_rectangle_colour(_fade_start, _y1, _fill_x2, _y2,
                            fill_color, background_color, background_color, fill_color, false);
                    } else {
                        draw_rectangle_colour(_x1, _y1, _fill_x2, _y2,
                            fill_color, fill_color, fill_color, fill_color, false);
                    }
                } else {
                    draw_rectangle_colour(_x1, _y1, _fill_x2, _y2,
                        fill_color, fill_color, fill_color, fill_color, false);
                }
            }
            
            // Draw border
            draw_rectangle_colour(_x1, _y1, _x2, _y2,
                border_color, border_color, border_color, border_color, true);
        }
    }
    
    /// @desc Set the current value
    static set_value = function(_value) {
        if (!is_real(_value)) return self;
        value = clamp(_value, min_value, max_value);
        return self;
    }
    
    /// @desc Set the max value
    static set_max = function(_max) {
        if (!is_real(_max)) return self;
        max_value = _max;
        value = clamp(value, min_value, max_value);
        return self;
    }
}
