function chunk_vertex_strip_quad(
    _buffer,
    _has_vertices,
    _ax, _ay, _u_tl, _v_tl, _packed_anim_tl,
    _bx, _by, _u_tr, _v_tr, _packed_anim_tr,
    _cx, _cy, _u_bl, _v_bl, _packed_anim_bl,
    _dx, _dy, _u_br, _v_br, _packed_anim_br,
    _packed_index_width
)
{
    gml_pragma("forceinline");

    static __last_x = 0;
    static __last_y = 0;
    static __last_u = 0;
    static __last_v = 0;
    static __last_packed_anim = 0;
    static __last_packed_index_width = 0;

    if (_has_vertices)
    {
        // Bridge quads with degenerates so the whole buffer can be submitted as one strip.
        vertex_position(_buffer, __last_x, __last_y);
        vertex_texcoord(_buffer, __last_u, __last_v);
        vertex_float2(_buffer, __last_packed_anim, __last_packed_index_width);

        vertex_position(_buffer, _ax, _ay);
        vertex_texcoord(_buffer, _u_tl, _v_tl);
        vertex_float2(_buffer, _packed_anim_tl, _packed_index_width);
    }

    vertex_position(_buffer, _ax, _ay);
    vertex_texcoord(_buffer, _u_tl, _v_tl);
    vertex_float2(_buffer, _packed_anim_tl, _packed_index_width);

    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _u_tr, _v_tr);
    vertex_float2(_buffer, _packed_anim_tr, _packed_index_width);

    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _u_bl, _v_bl);
    vertex_float2(_buffer, _packed_anim_bl, _packed_index_width);

    vertex_position(_buffer, _dx, _dy);
    vertex_texcoord(_buffer, _u_br, _v_br);
    vertex_float2(_buffer, _packed_anim_br, _packed_index_width);

    __last_x = _dx;
    __last_y = _dy;
    __last_u = _u_br;
    __last_v = _v_br;
    __last_packed_anim = _packed_anim_br;
    __last_packed_index_width = _packed_index_width;

    return true;
}

function chunk_vertex_tile_connected_part(_buffer, _x, _y, _w, _h, _cos, _sin, _u0, _v0, _u1, _v1, _width, _index, _has_vertices = false)
{
    var _wx = _w * _cos;
    var _wy = _w * _sin;
    var _hx = _h * _sin;
    var _hy = _h * _cos;

    var _bx = _x + _wx;
    var _by = _y + _wy;

    var _cx = _x + _hx;
    var _cy = _y + _hy;

    var _dx = _cx + _wx;
    var _dy = _cy + _wy;

    // Pack: float1 = animation metadata, float2 = frame_index | (width << 8) | (frame_count << 16)
    var _packed_index_width = (_index << 8) | _width;

    return chunk_vertex_strip_quad(
        _buffer,
        _has_vertices,
        _x,   _y,   _u0, _v0, TILE_ANIMATION_TYPE.DEFAULT,
        _bx,  _by,  _u1, _v0, TILE_ANIMATION_TYPE.DEFAULT,
        _cx,  _cy,  _u0, _v1, TILE_ANIMATION_TYPE.DEFAULT,
        _dx,  _dy,  _u1, _v1, TILE_ANIMATION_TYPE.DEFAULT,
        _packed_index_width
    );
}
