function render_tile(_buffer, _item_data, _page, _position, _uv, _surface_width, _surface_height, _name, _index, _x, _y, _xscale, _yscale, _rotation, _colour, _alpha)
{
    var _ = _page[$ _name];
    
    var _sprite = _position[_.sprite[0]];
    
    var _width  = _sprite.get_width();
    var _height = _sprite.get_height();
    
    var _v0 = _sprite.get_x() / _surface_width;
    var _v1 = _sprite.get_y() / _surface_height;
    
    var _v2 = _v0 + (_width  / _surface_width);
    var _v3 = _v1 + (_height / _surface_height);
    
    var _xoffset = -_xscale * _sprite.get_xoffset();
    var _yoffset = -_yscale * _sprite.get_yoffset();
    
    var _xw = (_xscale * _width)  + _xoffset;
    var _yh = (_yscale * _height) + _yoffset;
    
    static __cos = global.render_cos;
    
    var _cos = __cos[_rotation];
    var _sin = __cos[(_rotation + 90) % 360];
    
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
    
    var _number = _.number;
    
    var _animation_type = _item_data.get_animation_type();
    
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
