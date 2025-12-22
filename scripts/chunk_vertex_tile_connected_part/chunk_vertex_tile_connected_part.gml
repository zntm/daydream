function chunk_vertex_tile_connected_part(_buffer, _x, _y, _w, _h, _cos, _sin, _u0, _v0, _u1, _v1, _width, _index)
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
    
    // Pack: float1 = animation_type (DEFAULT = 0), float2 = (index * 256) + width
    var _packed_index_width = (_index * 256) + _width;
    
    vertex_position(_buffer, _x, _y);
    vertex_texcoord(_buffer, _u0, _v0);
    vertex_float2(_buffer, TILE_ANIMATION_TYPE.DEFAULT, _packed_index_width);
    
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _u1, _v0);
    vertex_float2(_buffer, TILE_ANIMATION_TYPE.DEFAULT, _packed_index_width);
    
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _u0, _v1);
    vertex_float2(_buffer, TILE_ANIMATION_TYPE.DEFAULT, _packed_index_width);
    
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _u1, _v0);
    vertex_float2(_buffer, TILE_ANIMATION_TYPE.DEFAULT, _packed_index_width);
    
    vertex_position(_buffer, _dx, _dy);
    vertex_texcoord(_buffer, _u1, _v1);
    vertex_float2(_buffer, TILE_ANIMATION_TYPE.DEFAULT, _packed_index_width);
    
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _u0, _v1);
    vertex_float2(_buffer, TILE_ANIMATION_TYPE.DEFAULT, _packed_index_width);
}