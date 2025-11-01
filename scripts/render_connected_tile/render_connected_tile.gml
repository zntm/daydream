function render_connected_tile(_buffer, _item_data, _data, _name, _position, _uv, _surface_width, _surface_height, _index, _index_offset, _padding, _x, _y, _xscale, _yscale, _rotation, _colour, _alpha)
{
    static __corner_index = function(_index, _bit_a, _bit_b, _bit_corner)
    {
        gml_pragma("forceinline");
        
        var _bit_c = _bit_a | _bit_b;
        
        if !(_index & _bit_c)
        {
            return 4;
        }
        
        if ((_index & _bit_c) == _bit_c)
        {
            return (!(_index & _bit_corner) ? 3 : 0);
        }
        
        if (~_index & _bit_a)
        {
            return 2;
        }
        
        if (~_index & _bit_b)
        {
            return 1;
        }
        
        return 0;
    }
    
    var _animation_type = _item_data.get_animation_type();
    
    if (_index == 0b111_11_111)
    {
        render_tile(_buffer, _name, _data, _animation_type, _position, _uv, _surface_width, _surface_height, _name, _index_offset, _x, _y, _xscale, _yscale, _rotation, _colour, _alpha);
        
        exit;
    }
    
    if (_index == 0b010_11_010)
    {
        render_tile(_buffer, _name, _data, _animation_type, _position, _uv, _surface_width, _surface_height, _name, _index_offset + 3, _x, _y, _xscale, _yscale, _rotation, _colour, _alpha);
        
        exit;
    }
    
    var _index2 = _index & 0b010_11_010;
    
    if (_index2 == 0b000_00_000)
    {
        render_tile(_buffer, _name, _data, _animation_type, _position, _uv, _surface_width, _surface_height, _name, _index_offset + 4, _x, _y, _xscale, _yscale, _rotation, _colour, _alpha);
        
        exit;
    }
    
    if (_index2 == 0b010_00_010)
    {
        render_tile(_buffer, _name, _data, _animation_type, _position, _uv, _surface_width, _surface_height, _name, _index_offset + 1, _x, _y, _xscale, _yscale, _rotation, _colour, _alpha);
        
        exit;
    }
    
    if (_index2 == 0b000_11_000)
    {
        render_tile(_buffer, _name, _data, _animation_type, _position, _uv, _surface_width, _surface_height, _name, _index_offset + 2, _x, _y, _xscale, _yscale, _rotation, _colour, _alpha);
        
        exit;
    }
    
    var _cos =  dcos(_rotation);
    var _sin = -dsin(_rotation);
    
    var _xoffset = -atla_get_xoffset("item", _name);
    var _yoffset = -atla_get_yoffset("item", _name);
    
    var _width  = atla_get_width("item", _name);
    var _height = atla_get_height("item", _name);
    
    var _edge_x1 = _xscale * (_xoffset + _padding);
    var _edge_y1 = _yscale * (_yoffset + _padding);
    
    var _edge_x2 = _xscale * (_xoffset + _width  - _padding);
    var _edge_y2 = _yscale * (_yoffset + _height - _padding);
    
    var _corner_x1 = _xscale * _xoffset;
    var _corner_y1 = _yscale * _yoffset;
    
    // var _corner_x2 = _xscale * (_xoffset + _width  - _padding);
    // var _corner_y2 = _yscale * (_yoffset + _height - _padding);
    var _corner_x2 = _edge_x2;
    var _corner_y2 = _edge_y2;
    
    var _width_half  = _width  / 2;
    var _height_half = _height / 2;
    
    if (_padding < _height_half)
    {
        // Top
        var _t_x = (_edge_x1 * _cos) - (_corner_y1 * _sin);
        var _t_y = (_edge_x1 * _sin) + (_corner_y1 * _cos);
        
        render_connected_tile_part(_buffer, _name, _data, _animation_type, _surface_width, _surface_height, _cos, _sin, _index_offset + ((_index & ~0b010_00_000) ? 2 : 0), _padding, 0, _width - (_padding * 2), _padding, _x + _t_x, _y + _t_y, _xscale, _yscale, _colour, _alpha);
        
        // Bottom
        var _b_x = (_edge_x1 * _cos) - (_edge_y2 * _sin);
        var _b_y = (_edge_x1 * _sin) + (_edge_y2 * _cos);
        
        render_connected_tile_part(_buffer, _name, _data, _animation_type, _surface_width, _surface_height, _cos, _sin, _index_offset + ((_index & ~0b000_00_010) ? 2 : 0), _padding, _height - _padding, _width - (_padding * 2), _padding, _x + _b_x, _y + _b_y, _xscale, _yscale, _colour, _alpha);
    }
    
    if (_padding < _width_half)
    {
        // Right
        var _r_x = (_edge_x2 * _cos) - (_edge_y1 * _sin);
        var _r_y = (_edge_x2 * _sin) + (_edge_y1 * _cos);
        
        render_connected_tile_part(_buffer, _name, _data, _animation_type, _surface_width, _surface_height, _cos, _sin, _index_offset + ((_index & ~0b000_01_000) ? 1 : 0), _width - _padding, _padding, _padding, _height - (_padding * 2), _x + _r_x, _y + _r_y, _xscale, _yscale, _colour, _alpha);
        
        // Left
        var _l_x = (_corner_x1 * _cos) - (_edge_y1 * _sin);
        var _l_y = (_corner_x1 * _sin) + (_edge_y1 * _cos);
        
        render_connected_tile_part(_buffer, _name, _data, _animation_type, _surface_width, _surface_height, _cos, _sin, _index_offset + ((_index & ~0b000_10_000) ? 1 : 0), 0, _padding, _padding, _height - (_padding * 2), _x + _l_x, _y + _l_y, _xscale, _yscale, _colour, _alpha);
    }
    
    // Top Left
    var _tl_x = (_corner_x1 * _cos) - (_corner_y1 * _sin);
    var _tl_y = (_corner_x1 * _sin) + (_corner_y1 * _cos);
    
    render_connected_tile_part(_buffer, _name, _data, _animation_type, _surface_width, _surface_height, _cos, _sin, _index_offset + __corner_index(_index, 0b010_00_000, 0b000_10_000, 0b100_00_000), 0, 0, _padding, _padding, _x + _tl_x, _y + _tl_y, _xscale, _yscale, _colour, _alpha);
    
    // Top Right
    var _tr_x = (_corner_x2 * _cos) - (_corner_y1 * _sin);
    var _tr_y = (_corner_x2 * _sin) + (_corner_y1 * _cos);
    
    render_connected_tile_part(_buffer, _name, _data, _animation_type, _surface_width, _surface_height, _cos, _sin, _index_offset + __corner_index(_index, 0b010_00_000, 0b000_01_000, 0b001_00_000), _width - _padding, 0, _padding, _padding, _x + _tr_x, _y + _tr_y, _xscale, _yscale, _colour, _alpha);
    
    // Bottom Left
    var _bl_x = (_corner_x1 * _cos) - (_corner_y2 * _sin);
    var _bl_y = (_corner_x1 * _sin) + (_corner_y2 * _cos);
    
    render_connected_tile_part(_buffer, _name, _data, _animation_type, _surface_width, _surface_height, _cos, _sin, _index_offset + __corner_index(_index, 0b000_00_010, 0b000_10_000, 0b000_00_100), 0, _height - _padding, _padding, _padding, _x + _bl_x, _y + _bl_y, _xscale, _yscale, _colour, _alpha);
    
    // Bottom Right
    var _br_x = (_corner_x2 * _cos) - (_corner_y2 * _sin);
    var _br_y = (_corner_x2 * _sin) + (_corner_y2 * _cos);
    
    render_connected_tile_part(_buffer, _name, _data, _animation_type, _surface_width, _surface_height, _cos, _sin, _index_offset + __corner_index(_index, 0b000_00_010, 0b000_01_000, 0b000_00_001), _width - _padding, _height - _padding, _padding, _padding, _x + _br_x, _y + _br_y, _xscale, _yscale, _colour, _alpha);
    
    if (_padding < _width_half) && (_padding < _height_half)
    {
        // Center
        var _c_x = (_edge_x1 * _cos) - (_edge_y1 * _sin);
        var _c_y = (_edge_x1 * _sin) + (_edge_y1 * _cos);
        
        render_connected_tile_part(_buffer, _name, _data, _animation_type, _surface_width, _surface_height, _cos, _sin, _index_offset, _padding, _padding, _width - (_padding * 2), _height - (_padding * 2), _x + _c_x, _y + _c_y, _xscale, _yscale, _colour, _alpha);
    }
}