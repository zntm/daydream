function render_connected_tile_part(_buffer, _uv, _surface_width, _surface_height, _cos, _sin, _name, _index, _left, _top, _width, _height, _x, _y, _xscale, _yscale, _rotation, _colour, _alpha)
{
    var _sprite = global.carbasa_page_position[$ "item"][global.carbasa_page[$ "item"][$ _name].sprite[_index]];
    
    var _v0 = (_sprite.get_x() + _left) / _surface_width;
    var _v1 = (_sprite.get_y() + _top)  / _surface_height;
    var _v2 = _v0 + (_width  / _surface_width);
    var _v3 = _v1 + (_height / _surface_height);
    
    var _a = _xscale * _width;
    var _b = _yscale * _height;
    
    var _ax = _x + (00 * _cos) - (00 * _sin);
    var _ay = _y + (00 * _sin) + (00 * _cos);
    
    var _bx = _x + (_a * _cos) - (00 * _sin);
    var _by = _y + (_a * _sin) + (00 * _cos);
    
    var _cx = _x + (00 * _cos) - (_b * _sin);
    var _cy = _y + (00 * _sin) + (_b * _cos);
    
    var _dx = _x + (_a * _cos) - (_b * _sin);
    var _dy = _y + (_a * _sin) + (_b * _cos);
    
    // Triangle 1
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _ax, _ay);
    vertex_texcoord(_buffer, _v0, _v1);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _v2, _v1);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _v0, _v3);
    
    // Triangle 2
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _bx, _by);
    vertex_texcoord(_buffer, _v2, _v1);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _cx, _cy);
    vertex_texcoord(_buffer, _v0, _v3);
    
    vertex_colour(_buffer, _colour, _alpha);
    vertex_position(_buffer, _dx, _dy);
    vertex_texcoord(_buffer, _v2, _v3);
}