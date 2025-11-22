function chunk_vertex_tile_connected_part(_buffer, _x, _y, _w, _h, _cos, _sin, _u0, _v0, _u1, _v1, _width, _index, _colour, _alpha)
{
    var _wx = _w * _cos;
    var _wy = _w * _sin;
    var _hx = _h * _sin;
    var _hy = _h * _cos;
    
    var _ax = _x;
    var _ay = _y;
    
    var _bx = _x + _wx;
    var _by = _y + _wy;
    
    var _cx = _x + _hx;
    var _cy = _y + _hy;
    
    var _dx = _cx + _wx;
    var _dy = _cy + _wy;
    
    vertex_position(_buffer, _ax, _ay);
    vertex_texcoord(_buffer, _u0, _v0);
    vertex_colour(_buffer, _colour, _alpha);
    vertex_float4(_buffer, TILE_ANIMATION_TYPE.DEFAULT, _index, _width, 0);
    
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _u1, _v0);
    vertex_colour(_buffer, _colour, _alpha);
    vertex_float4(_buffer, TILE_ANIMATION_TYPE.DEFAULT, _index, _width, 0);
    
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _u0, _v1);
    vertex_colour(_buffer, _colour, _alpha);
    vertex_float4(_buffer, TILE_ANIMATION_TYPE.DEFAULT, _index, _width, 0);
    
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _u1, _v0);
    vertex_colour(_buffer, _colour, _alpha);
    vertex_float4(_buffer, TILE_ANIMATION_TYPE.DEFAULT, _index, _width, 0);
    
    vertex_position(_buffer, _dx, _dy);
    vertex_texcoord(_buffer, _u1, _v1);
    vertex_colour(_buffer, _colour, _alpha);
    vertex_float4(_buffer, TILE_ANIMATION_TYPE.DEFAULT, _index, _width, 0);
    
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _u0, _v1);
    vertex_colour(_buffer, _colour, _alpha);
    vertex_float4(_buffer, TILE_ANIMATION_TYPE.DEFAULT, _index, _width, 0);
}