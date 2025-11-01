function render_tile(_buffer, _name, _data, _animation_type, _position, _uv, _surface_width, _surface_height, _index, _x, _y, _xscale, _yscale, _rotation, _colour, _alpha)
{
    var _width  = atla_get_width("item", _name);
    var _height = atla_get_height("item", _name);
    
    var _v0 = _data.get_x() / _surface_width;
    var _v1 = _data.get_y() / _surface_height;
    
    var _v2 = _v0 + (_width  / _surface_width);
    var _v3 = _v1 + (_height / _surface_height);
    
    var _xoffset = -_xscale * atla_get_xoffset("item", _name);
    var _yoffset = -_yscale * atla_get_yoffset("item", _name);
    
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
    
    var _number = atla_get_number("item", _name);
    
    // Triangle 1
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _ax, _ay);
    vertex_texcoord(_buffer, _v0, _v1);
    vertex_float4(_buffer, _index, _number, _width, _animation_type);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _v2, _v1);
    vertex_float4(_buffer, _index, _number, _width, _animation_type);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _v0, _v3);
    vertex_float4(_buffer, _index, _number, _width, _animation_type);
    
    // Triangle 2
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _v2, _v1);
    vertex_float4(_buffer, _index, _number, _width, _animation_type);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _v0, _v3);
    vertex_float4(_buffer, _index, _number, _width, _animation_type);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _dx, _dy);
    vertex_texcoord(_buffer, _v2, _v3);
    vertex_float4(_buffer, _index, _number, _width, _animation_type);
}
