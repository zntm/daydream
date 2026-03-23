function chunk_vertex_foliage(_buffer, _texel_width, _texel_height, _animation_type, _atla, _atla_sprite, _chunk_index, _index, _x, _y, _xscale, _yscale, _rotation, _has_vertices = false)
{
    var _atla_value = _atla.___value;

    var _uvs = _atla_sprite.___uvs;

    var _u0 = _uvs[0];
    var _v0 = _uvs[1];
    var _u1 = _uvs[2];
    var _v1 = _uvs[3];

    var _is_rotated = _atla_value & (1 << 55);

    var _width  = (_atla_value >> 22) & 2047;
    var _height = (_atla_value >> 33) & 2047;

    var _u_tl, _v_tl, _u_tr, _v_tr, _u_bl, _v_bl, _u_br, _v_br, _packed_index_width;

    if (_is_rotated)
    {
        _u_tl = _u0; _v_tl = _v1;
        _u_tr = _u0; _v_tr = _v0;
        _u_bl = _u1; _v_bl = _v1;
        _u_br = _u1; _v_br = _v0;

        _packed_index_width = (_index << 8) | _height;
    }
    else
    {
        _u_tl = _u0; _v_tl = _v0;
        _u_tr = _u1; _v_tr = _v0;
        _u_bl = _u0; _v_bl = _v1;
        _u_br = _u1; _v_br = _v1;

        _packed_index_width = (_index << 8) | _width;
    }

    var _xoffset = -_xscale * (((_atla_value >> 0)  & 2047) - 1024);
    var _yoffset = -_yscale * (((_atla_value >> 11) & 2047) - 1024);

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

    var _packed_anim_foliage = (_number << 24) | (_chunk_index << 16) | TILE_ANIMATION_TYPE.FOLIAGE;
    var _packed_anim_default = (_number << 24) | TILE_ANIMATION_TYPE.DEFAULT;

    return chunk_vertex_strip_quad(
        _buffer,
        _has_vertices,
        _ax, _ay, _u_tl, _v_tl, _packed_anim_foliage,
        _bx, _by, _u_tr, _v_tr, _packed_anim_foliage,
        _cx, _cy, _u_bl, _v_bl, _packed_anim_default,
        _dx, _dy, _u_br, _v_br, _packed_anim_default,
        _packed_index_width
    );
}
