function render_connected_tile_part(_buffer, _animation_type, _surface_width, _surface_height, _cos, _sin, _sprite, _sprite_data, _index, _left, _top, _width, _height, _x, _y, _xscale, _yscale, _colour, _alpha)
{
    var _v0 = (_sprite_data.get_x() + _left) / _surface_width;
    var _v1 = (_sprite_data.get_y() + _top)  / _surface_height;
    var _v2 = _v0 + (_width  / _surface_width);
    var _v3 = _v1 + (_height / _surface_height);
    
    var _a = _xscale * _width;
    var _b = _yscale * _height;
    
    var _ax = _x;
    var _ay = _y;
    
    var _bx = _x + (_a * _cos);
    var _by = _y + (_a * _sin);
    
    var _cx = _ax - (_b * _sin);
    var _cy = _ay + (_b * _cos);
    
    var _dx = _bx - (_b * _sin);
    var _dy = _by + (_b * _cos);
    
    var _number = _sprite.number;
    
    var _w = _sprite.width;
    
    // Triangle 1
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _ax, _ay);
    vertex_texcoord(_buffer, _v0, _v1);
    vertex_float4(_buffer, _index, _number, _w, _animation_type);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _v2, _v1);
    vertex_float4(_buffer, _index, _number, _w, _animation_type);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _v0, _v3);
    vertex_float4(_buffer, _index, _number, _w, _animation_type);
    
    // Triangle 2
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _v2, _v1);
    vertex_float4(_buffer, _index, _number, _w, _animation_type);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _v0, _v3);
    vertex_float4(_buffer, _index, _number, _w, _animation_type);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _dx, _dy);
    vertex_texcoord(_buffer, _v2, _v3);
    vertex_float4(_buffer, _index, _number, _w, _animation_type);
}