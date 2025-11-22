function chunk_vertex_foliage(_buffer, _texel_width, _texel_height, _animation_type, _atla, _atla_sprite, _chunk_index, _index, _x, _y, _xscale, _yscale, _rotation, _colour, _alpha)
{
    var _atla_value = _atla.___value;
    
    var _uvs = _atla_sprite.___uvs;
    
    var _u0 = _uvs[0];
    var _v0 = _uvs[1];
    var _u1 = _uvs[2];
    var _v1 = _uvs[3];
    
    var _width  = (_atla_value >> 22) & 2047;
    var _height = (_atla_value >> 33) & 2047;
    
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
    
    var _ax = _x + _a - _d;
    var _ay = _y + _b + _c;
    
    var _bx = _x + _e - _d;
    var _by = _y + _f + _c;
    
    var _cx = _x + _a - _h;
    var _cy = _y + _b + _g;
    
    var _dx = _x + _e - _h;
    var _dy = _y + _f + _g;
    
    var _number = (_atla_value >> 44) & 2047;
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _ax, _ay);
    vertex_texcoord(_buffer, _u0, _v0);
    vertex_float4(_buffer, (_chunk_index << 16) | TILE_ANIMATION_TYPE.FOLIAGE, _index, _width * _texel_width, _number);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _u1, _v0);
    vertex_float4(_buffer, (_chunk_index << 16) | TILE_ANIMATION_TYPE.FOLIAGE, _index, _width * _texel_width, _number);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _u0, _v1);
    vertex_float4(_buffer, TILE_ANIMATION_TYPE.DEFAULT, _index, _width * _texel_width, _number);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _u1, _v0);
    vertex_float4(_buffer, (_chunk_index << 16) | TILE_ANIMATION_TYPE.FOLIAGE, _index, _width * _texel_width, _number);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _u0, _v1);
    vertex_float4(_buffer, TILE_ANIMATION_TYPE.DEFAULT, _index, _width * _texel_width, _number);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _dx, _dy);
    vertex_texcoord(_buffer, _u1, _v1);
    vertex_float4(_buffer, TILE_ANIMATION_TYPE.DEFAULT, _index, _width * _texel_width, _number);
}