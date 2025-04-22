function render_tile(_buffer, _uv, _surface_width, _surface_height, _name, _index, _x, _y, _xscale, _yscale, _rotation, _colour, _alpha)
{
    var _ = global.carbasa_page[$ "item"][$ _name];
    
    var _sprite = global.carbasa_page_position[$ "item"][_.sprite[0]];
    
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
    
    var _cos =  dcos(_rotation);
    var _sin = -dsin(_rotation);
    
    var _ax = _x + (_xoffset * _cos) - (_yoffset * _sin);
    var _ay = _y + (_xoffset * _sin) + (_yoffset * _cos);
    
    var _bx = _x + (_xw * _cos) - (_yoffset * _sin);
    var _by = _y + (_xw * _sin) + (_yoffset * _cos);
    
    var _cx = _x + (_xoffset * _cos) - (_yh * _sin);
    var _cy = _y + (_xoffset * _sin) + (_yh * _cos);
    
    var _dx = _x + (_xw * _cos) - (_yh * _sin);
    var _dy = _y + (_xw * _sin) + (_yh * _cos);
    
    // Triangle 1
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _ax, _ay);
    vertex_texcoord(_buffer, _v0, _v1);
    vertex_float4(_buffer, _index, _.number, _.width, _.height);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _v2, _v1);
    vertex_float4(_buffer, _index, _.number, _.width, _.height);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _v0, _v3);
    vertex_float4(_buffer, _index, _.number, _.width, _.height);
    
    // Triangle 2
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _v2, _v1);
    vertex_float4(_buffer, _index, _.number, _.width, _.height);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _v0, _v3);
    vertex_float4(_buffer, _index, _.number, _.width, _.height);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _dx, _dy);
    vertex_texcoord(_buffer, _v2, _v3);
    vertex_float4(_buffer, _index, _.number, _.width, _.height);
}