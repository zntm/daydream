function chunk_vertex_tile(_buffer, _texel_width, _texel_height, _animation_type, _atla, _atla_sprite, _index, _x, _y, _xscale, _yscale, _rotation)
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
    
    vertex_position(_buffer, _ax, _ay);
    vertex_texcoord(_buffer, _u0, _v0);
    vertex_float3(_buffer, (_number << 24) | _animation_type, _index, _width * _texel_width);
    
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _u1, _v0);
    vertex_float3(_buffer, (_number << 24) | _animation_type, _index, _width * _texel_width);
    
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _u0, _v1);
    vertex_float3(_buffer, (_number << 24) | _animation_type, _index, _width * _texel_width);
    
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _u1, _v0);
    vertex_float3(_buffer, (_number << 24) | _animation_type, _index, _width * _texel_width);
    
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _u0, _v1);
    vertex_float3(_buffer, (_number << 24) | _animation_type, _index, _width * _texel_width);
    
    vertex_position(_buffer, _dx, _dy);
    vertex_texcoord(_buffer, _u1, _v1);
    vertex_float3(_buffer, (_number << 24) | _animation_type, _index, _width * _texel_width);
}