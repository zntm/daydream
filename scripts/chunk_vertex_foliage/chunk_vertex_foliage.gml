function chunk_vertex_foliage(_buffer, _texel_width, _texel_height, _animation_type, _atla, _atla_sprite, _chunk_index, _index, _x, _y, _xscale, _yscale, _rotation)
{
    var _atla_value = _atla.___value;
    
    var _uvs = _atla_sprite.___uvs;
    
    // Check if the atla entry is rotated
    var _is_rotated = _atla.is_rotated();
    
    // UV coordinates - remap if rotated 90° clockwise in atlas
    var _u_tl, _v_tl, _u_tr, _v_tr, _u_bl, _v_bl, _u_br, _v_br;
    
    if (_is_rotated)
    {
        // Rotated 90° CW in atlas: remap UVs
        _u_tl = _uvs[0]; _v_tl = _uvs[3];
        _u_tr = _uvs[0]; _v_tr = _uvs[1];
        _u_bl = _uvs[2]; _v_bl = _uvs[3];
        _u_br = _uvs[2]; _v_br = _uvs[1];
    }
    else
    {
        _u_tl = _uvs[0]; _v_tl = _uvs[1];
        _u_tr = _uvs[2]; _v_tr = _uvs[1];
        _u_bl = _uvs[0]; _v_bl = _uvs[3];
        _u_br = _uvs[2]; _v_br = _uvs[3];
    }
    
    // Get stored dimensions (already swapped if rotated)
    var _width  = (_atla_value >> 22) & 2047;
    var _height = (_atla_value >> 33) & 2047;
    
    // Get stored offsets (original, not transformed)
    var _stored_xoffset = ((_atla_value >> 0)  & 2047) - 1024;
    var _stored_yoffset = ((_atla_value >> 11) & 2047) - 1024;
    
    // Transform offsets for rotated sprites
    var _xoffset, _yoffset;
    if (_is_rotated)
    {
        // For 90° CW rotation: new_xoffset = old_yoffset, new_yoffset = original_width - old_xoffset
        // Original width is now stored as _height (since dimensions were swapped)
        _xoffset = -_xscale * _stored_yoffset;
        _yoffset = -_yscale * (_height - _stored_xoffset);
    }
    else
    {
        _xoffset = -_xscale * _stored_xoffset;
        _yoffset = -_yscale * _stored_yoffset;
    }
    
    var _xw = (_xscale * _width)  + _xoffset;
    var _yh = (_yscale * _height) + _yoffset;
    
    var _cos =  dcos(_rotation);
    var _sin = -dsin(_rotation);
    
    var _a = _xoffset * _cos;
    var _b = _xoffset * _sin;
    var _c = _yoffset * _cos;
    var _d = _yoffset * _sin;
    
    var _e = _xw * _cos;
    var _f = _xw * _sin;
    var _g = _yh * _cos;
    var _h = _yh * _sin;
    
    var _i = _x + _a;
    var _j = _y + _b;
    
    var _k = _x + _e;
    var _l = _y + _f;
    
    var _ax = _i - _d;
    var _ay = _j + _c;
    
    var _bx = _k - _d;
    var _by = _l + _c;
    
    var _cx = _i - _h;
    var _cy = _j + _g;
    
    var _dx = _k - _h;
    var _dy = _l + _g;
    
    var _number = (_atla_value >> 44) & 2047;
    
    // Pack: float1 = (number << 24) | (chunk_index << 16) | animation_type, float2 = (index * 256) + width
    var _packed_anim_foliage = (_number << 24) | (_chunk_index << 16) | TILE_ANIMATION_TYPE.FOLIAGE;
    var _packed_anim_default = (_number << 24) | TILE_ANIMATION_TYPE.DEFAULT;
    var _packed_index_width = (_index << 8) | _width;
    
    // Top vertices use FOLIAGE animation for skew, bottom use DEFAULT
    vertex_position(_buffer, _ax, _ay);
    vertex_texcoord(_buffer, _u_tl, _v_tl);
    vertex_float2(_buffer, _packed_anim_foliage, _packed_index_width);
    
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _u_tr, _v_tr);
    vertex_float2(_buffer, _packed_anim_foliage, _packed_index_width);
    
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _u_bl, _v_bl);
    vertex_float2(_buffer, _packed_anim_default, _packed_index_width);
    
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _u_tr, _v_tr);
    vertex_float2(_buffer, _packed_anim_foliage, _packed_index_width);
    
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _u_bl, _v_bl);
    vertex_float2(_buffer, _packed_anim_default, _packed_index_width);
    
    vertex_position(_buffer, _dx, _dy);
    vertex_texcoord(_buffer, _u_br, _v_br);
    vertex_float2(_buffer, _packed_anim_default, _packed_index_width);
}