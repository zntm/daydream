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
    
    // Sprite-based configuration
    sprite_empty_config = undefined; // Struct { asset, slice_left, slice_top, slice_right, slice_bottom }
    sprite_fill_config = undefined;  // Struct { asset, slice_left, slice_top, slice_right, slice_bottom }
    
    // Color-based styling (only used if explicitly set, otherwise sprites-only)
    background_color = undefined;
    colour = #4aff4a;
    border_color = #3a3a4a;
    
    // Animation
    display_value = _value;
    smooth = true;
    smooth_speed = 0.15;
    
    /// @desc Resolve an asset name or handle to a sprite asset
    static resolve_sprite = function(_source) {
        if (is_string(_source)) {
            var _asset = asset_get_index(_source);
            if (_asset != -1 && asset_get_type(_source) == asset_sprite) {
                return _asset;
            }
            show_debug_message($"[UIBar] Warning: Could not resolve sprite '{_source}'");
            return undefined;
        } else if (sprite_exists(_source)) {
            return _source;
        }
        return undefined;
    }

    /// @desc Set the empty sprite configuration
    static set_sprite_empty = function(_source) {
        if (is_struct(_source) && _source[$ "is_sprite_def"]) {
            sprite_empty_config = {
                asset: resolve_sprite(_source.sprite_name),
                slice_left: _source.slice_left,
                slice_top: _source.slice_top,
                slice_right: _source.slice_right,
                slice_bottom: _source.slice_bottom
            }
        } else {
            sprite_empty_config = {
                asset: resolve_sprite(_source),
                slice_left: 0, slice_top: 0, slice_right: 0, slice_bottom: 0
            }
        }
        return self;
    }
    
    /// @desc Set the fill sprite configuration
    static set_sprite_fill = function(_source) {
        if (is_struct(_source) && _source[$ "is_sprite_def"]) {
            sprite_fill_config = {
                asset: resolve_sprite(_source.sprite_name),
                slice_left: _source.slice_left,
                slice_top: _source.slice_top,
                slice_right: _source.slice_right,
                slice_bottom: _source.slice_bottom
            }
        } else {
            sprite_fill_config = {
                asset: resolve_sprite(_source),
                slice_left: 0, slice_top: 0, slice_right: 0, slice_bottom: 0
            }
        }
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
    /// @param {Struct} _config Sprite config struct
    /// @param {Real} _dx Draw X position
    /// @param {Real} _dy Draw Y position
    /// @param {Real} _target_width Target width to stretch to
    /// @param {Real} _target_height Target height to stretch to
    /// @param {Real} _scale Uniform pixel scale
    static draw_nine_slice_bar = function(_config, _dx, _dy, _target_width, _target_height, _scale) {
        var _sprite = _config.asset;
        if (!sprite_exists(_sprite)) return;
        
        var _sw = sprite_get_width(_sprite);
        var _sh = sprite_get_height(_sprite);
        
        // Nine-slice margins (scaled)
        var _left = _config.slice_left * _scale;
        var _right = _config.slice_right * _scale;
        var _mid_src_w = _sw - _config.slice_left - _config.slice_right;
        
        // Target dimensions
        var _mid_target_w = _target_width - _left - _right;
        
        // Avoid negative middle widths
        if (_mid_target_w < 0) {
            draw_sprite_stretched(_sprite, 0, _dx, _dy, _target_width, _target_height);
            return;
        }
        
        // Draw left edge
        draw_sprite_part_ext(_sprite, 0, 
            0, 0, _config.slice_left, _sh,
            _dx, _dy, _scale, _target_height / _sh,
            c_white, 1);
        
        // Draw middle (stretched horizontally)
        if (_mid_src_w > 0 && _mid_target_w > 0) {
            draw_sprite_part_ext(_sprite, 0,
                _config.slice_left, 0, _mid_src_w, _sh,
                _dx + _left, _dy, _mid_target_w / _mid_src_w, _target_height / _sh,
                c_white, 1);
        }
        
        // Draw right edge
        draw_sprite_part_ext(_sprite, 0,
            _sw - _config.slice_right, 0, _config.slice_right, _sh,
            _dx + _target_width - _right, _dy, _scale, _target_height / _sh,
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
        var _pixel_scale = _base_scale.y;
        
        // Calculate fill percentage
        var _t = (display_value - min_value) / (max_value - min_value);
        _t = clamp(_t, 0, 1);
        
        // Sprite-based rendering
        if (sprite_empty_config != undefined && sprite_exists(sprite_empty_config.asset)) {
            // Draw empty bar (background)
            draw_nine_slice_bar(sprite_empty_config, _x1, _y1, _draw_width, _draw_height, _pixel_scale);
            
            // Draw fill bar with clipped width
            if (sprite_fill_config != undefined && sprite_exists(sprite_fill_config.asset) && _t > 0) {
                var _fill_width = _draw_width * _t;
                // Need at least the left + right edges worth of width
                var _min_width = (sprite_fill_config.slice_left + sprite_fill_config.slice_right) * _pixel_scale;
                if (_fill_width >= _min_width) {
                    draw_nine_slice_bar(sprite_fill_config, _x1, _y1, _fill_width, _draw_height, _pixel_scale);
                } else if (_fill_width > 0) {
                    // Very small fill - just draw left portion
                    var _sh = sprite_get_height(sprite_fill_config.asset);
                    draw_sprite_part_ext(sprite_fill_config.asset, 0,
                        0, 0, min(sprite_get_width(sprite_fill_config.asset), _fill_width / _pixel_scale), _sh,
                        _x1, _y1, _pixel_scale, _draw_height / _sh,
                        c_white, 1);
                }
            }
        }
        // Rectangle fallback
        else {
            if (background_color != undefined) {
                draw_set_color(background_color);
                draw_set_alpha(background_alpha);
                draw_rectangle(_x1, _y1, _x1 + _draw_width, _y1 + _draw_height, false);
            }
            
            if (colour != undefined && _t > 0) {
                draw_set_color(colour);
                draw_set_alpha(1); // Fill is usually opaque
                draw_rectangle(_x1, _y1, _x1 + (_draw_width * _t), _y1 + _draw_height, false);
            }
            
            if (border_color != undefined && border_width > 0) {
                draw_set_color(border_color);
                draw_set_alpha(1);
                draw_rectangle(_x1, _y1, _x1 + _draw_width, _y1 + _draw_height, true);
            }
            
            draw_set_alpha(1);
            draw_set_color(c_white);
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
    
    /// @desc Set whether smoothing is enabled
    static set_smooth = function(_smooth) {
        smooth = _smooth;
        if (!smooth) display_value = value;
        return self;
    }
}
