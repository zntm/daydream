function chunk_vertex_liquid(_buffer, _texel_width, _texel_height, _animation_type, _atla, _atla_sprite, _wave_index_left, _wave_index_right, _index, _x, _y, _xscale, _yscale, _rotation, _level = 8, _left_level = 0, _right_level = 0, _has_liquid_above = false, _has_liquid_below = false, _has_vertices = false)
{
    var _atla_value = _atla.___value;

    var _uvs = _atla_sprite.___uvs;

    // Check if the atla entry is rotated
    var _is_rotated = _atla.is_rotated();

    // Get stored dimensions (already swapped if rotated)
    var _width  = (_atla_value >> 22) & 2047;
    var _height = (_atla_value >> 33) & 2047;

    // Calculate level ratios (1-8 -> 0.125 to 1.0)
    var _level_ratio = clamp(_level, 1, 8) / 8;

    // Calculate edge level ratios for connectivity
    var _left_ratio = _left_level > 0 ? ((_level_ratio + clamp(_left_level, 1, 8) / 8) / 2) : _level_ratio;
    var _right_ratio = _right_level > 0 ? ((_level_ratio + clamp(_right_level, 1, 8) / 8) / 2) : _level_ratio;

    // Interior liquid should sample away from the top highlight line.
    var _top_crop_ratio = _has_liquid_above ? 0.2 : 0.0;
    // Bottom cropping when same liquid is below (crop/stretch bottom ~20%)
    var _bottom_crop_ratio = _has_liquid_below ? 0.8 : 1.0;

    // UV coordinates - remap if rotated 90° clockwise in atlas
    var _u_tl, _v_tl, _u_tr, _v_tr, _u_bl, _v_bl, _u_br, _v_br;

    if (_is_rotated)
    {
        // Rotated 90° CW in atlas
        // Liquid level affects V coords (now becomes U in rotated space)
        // Bottom crop in rotated space
        var _u_top = lerp(_uvs[0], _uvs[2], _top_crop_ratio);
        var _u_bottom = lerp(_uvs[0], _uvs[2], _bottom_crop_ratio);
        var _u_surface_left = lerp(_u_top, _u_bottom, 1 - _left_ratio);
        var _u_surface_right = lerp(_u_top, _u_bottom, 1 - _right_ratio);

        _u_tl = _u_surface_left;  _v_tl = _uvs[3];
        _u_tr = _u_surface_right; _v_tr = _uvs[1];
        _u_bl = _u_bottom;     _v_bl = _uvs[3];
        _u_br = _u_bottom;     _v_br = _uvs[1];
    }
    else
    {
        // Crop the bottom if liquid is below (to hide seam)
        var _v_top = lerp(_uvs[1], _uvs[3], _top_crop_ratio);
        var _v_bottom = lerp(_uvs[1], _uvs[3], _bottom_crop_ratio);
        var _v_surface_left = lerp(_v_top, _v_bottom, 1 - _left_ratio);
        var _v_surface_right = lerp(_v_top, _v_bottom, 1 - _right_ratio);

        _u_tl = _uvs[0]; _v_tl = _v_surface_left;
        _u_tr = _uvs[2]; _v_tr = _v_surface_right;
        _u_bl = _uvs[0]; _v_bl = _v_bottom;
        _u_br = _uvs[2]; _v_br = _v_bottom;
    }

    // Adjust heights for cropped portions
    var _height_cropped_left = _height * _left_ratio;
    var _height_cropped_right = _height * _right_ratio;

    // Get stored offsets (original, not transformed)
    var _xoffset = -_xscale * (((_atla_value >> 0)  & 2047) - 1024);
    var _yoffset = -_yscale * (((_atla_value >> 11) & 2047) - 1024);

    // Adjust y offsets to move sprite down when cropped (liquid settles to bottom)
    var _yoffset_cropped_left = _yoffset + (_height * (1 - _left_ratio) * _yscale);
    var _yoffset_cropped_right = _yoffset + (_height * (1 - _right_ratio) * _yscale);

    var _xw = (_xscale * _width) + _xoffset;
    var _yh_left = (_yscale * _height_cropped_left) + _yoffset_cropped_left;
    var _yh_right = (_yscale * _height_cropped_right) + _yoffset_cropped_right;

    var _cos =  dcos(_rotation);
    var _sin = -dsin(_rotation);

    // Left edge calculations
    var _a = _xoffset * _cos;
    var _b = _xoffset * _sin;
    var _c_left = _yoffset_cropped_left * _cos;
    var _d_left = _yoffset_cropped_left * _sin;

    // Right edge calculations
    var _c_right = _yoffset_cropped_right * _cos;
    var _d_right = _yoffset_cropped_right * _sin;

    var _e = _xw * _cos;
    var _f = _xw * _sin;
    var _g_left = _yh_left * _cos;
    var _h_left = _yh_left * _sin;
    var _g_right = _yh_right * _cos;
    var _h_right = _yh_right * _sin;

    var _i = _x + _a;
    var _j = _y + _b;

    var _k = _x + _e;
    var _l = _y + _f;

    // Top-left vertex (uses left edge level)
    var _ax = _i - _d_left;
    var _ay = _j + _c_left;

    // Top-right vertex (uses right edge level)
    var _bx = _k - _d_right;
    var _by = _l + _c_right;

    // Bottom-left vertex (uses left edge level)
    var _cx = _i - _h_left;
    var _cy = _j + _g_left;

    // Bottom-right vertex (uses right edge level)
    var _dx = _k - _h_right;
    var _dy = _l + _g_right;

    /* _number omitted from wave packing — only used by INCREMENT shader branch,
       including it pushes the value past 2^24 where float32 loses precision
       on the low bits, corrupting animation_type (5 → 4 = FOLIAGE) */
    var _packed_anim_wave_left = (_wave_index_left << 16) | _animation_type;
    var _packed_anim_wave_right = (_wave_index_right << 16) | _animation_type;
    var _packed_anim_default = TILE_ANIMATION_TYPE.DEFAULT;
    var _packed_index_width;

    if (_is_rotated)
    {
        _packed_index_width = (_index << 8) | _height;
    }
    else
    {
        _packed_index_width = (_index << 8) | _width;
    }

    return chunk_vertex_strip_quad(
        _buffer,
        _has_vertices,
        _ax, _ay, _u_tl, _v_tl, _packed_anim_wave_left,
        _bx, _by, _u_tr, _v_tr, _packed_anim_wave_right,
        _cx, _cy, _u_bl, _v_bl, _packed_anim_default,
        _dx, _dy, _u_br, _v_br, _packed_anim_default,
        _packed_index_width
    );
}
