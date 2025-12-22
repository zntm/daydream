function chunk_vertex_liquid(_buffer, _texel_width, _texel_height, _animation_type, _atla, _atla_sprite, _index, _x, _y, _xscale, _yscale, _rotation, _level = 8, _left_level = 0, _right_level = 0)
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
    
    // UV coordinates - remap if rotated 90° clockwise in atlas
    var _u_tl, _v_tl, _u_tr, _v_tr, _u_bl, _v_bl, _u_br, _v_br;
    
    if (_is_rotated)
    {
        // Rotated 90° CW in atlas
        // Liquid level affects V coords (now becomes U in rotated space)
        var _u_crop_left = lerp(_uvs[0], _uvs[2], 1 - _left_ratio);
        var _u_crop_right = lerp(_uvs[0], _uvs[2], 1 - _right_ratio);
        
        _u_tl = _u_crop_left;  _v_tl = _uvs[3];
        _u_tr = _u_crop_right; _v_tr = _uvs[1];
        _u_bl = _uvs[2];       _v_bl = _uvs[3];
        _u_br = _uvs[2];       _v_br = _uvs[1];
    }
    else
    {
        // Crop the bottom of the UV based on level (keeping top constant)
        var _v1_cropped_left = lerp(_uvs[1], _uvs[3], _left_ratio);
        var _v1_cropped_right = lerp(_uvs[1], _uvs[3], _right_ratio);
        
        _u_tl = _uvs[0]; _v_tl = _uvs[1];
        _u_tr = _uvs[2]; _v_tr = _uvs[1];
        _u_bl = _uvs[0]; _v_bl = _v1_cropped_left;
        _u_br = _uvs[2]; _v_br = _v1_cropped_right;
    }
    
    // Adjust heights for cropped portions
    var _height_cropped_left = _height * _left_ratio;
    var _height_cropped_right = _height * _right_ratio;
    
    // Get stored offsets (original, not transformed)
    var _stored_xoffset = ((_atla_value >> 0)  & 2047) - 1024;
    var _stored_yoffset = ((_atla_value >> 11) & 2047) - 1024;
    
    // Transform offsets for rotated sprites
    var _xoffset, _yoffset;
    if (_is_rotated)
    {
        _xoffset = -_xscale * _stored_yoffset;
        _yoffset = -_yscale * (_height - _stored_xoffset);
    }
    else
    {
        _xoffset = -_xscale * _stored_xoffset;
        _yoffset = -_yscale * _stored_yoffset;
    }
    
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
    
    var _number = (_atla_value >> 44) & 2047;
    
    // Pack: float1 = (number << 24) | animation_type, float2 = (index * 256) + width
    var _packed_anim = (_number << 24) | _animation_type;
    var _packed_index_width = (_index * 256) + _width;
    
    // Triangle 1: top-left, top-right, bottom-left
    vertex_position(_buffer, _ax, _ay);
    vertex_texcoord(_buffer, _u_tl, _v_tl);
    vertex_float2(_buffer, _packed_anim, _packed_index_width);
    
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _u_tr, _v_tr);
    vertex_float2(_buffer, _packed_anim, _packed_index_width);
    
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _u_bl, _v_bl);
    vertex_float2(_buffer, _packed_anim, _packed_index_width);
    
    // Triangle 2: top-right, bottom-left, bottom-right
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _u_tr, _v_tr);
    vertex_float2(_buffer, _packed_anim, _packed_index_width);
    
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _u_bl, _v_bl);
    vertex_float2(_buffer, _packed_anim, _packed_index_width);
    
    vertex_position(_buffer, _dx, _dy);
    vertex_texcoord(_buffer, _u_br, _v_br);
    vertex_float2(_buffer, _packed_anim, _packed_index_width);
}
