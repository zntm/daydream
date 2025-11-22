function chunk_vertex_tile_connected(_buffer, _texel_width, _texel_height, _animation_type, _atla, _atla_sprite, _index, _index_offset, _x, _y, _xscale, _yscale, _rotation, _colour, _alpha)
{
    static __corner_index = function(_index, _bit_a, _bit_b, _bit_corner)
    {
        gml_pragma("forceinline");
        
        var _bit_c = _bit_a | _bit_b;
        
        var _index2 = _index & _bit_c;
        
        if !(_index2)
        {
            return 4;
        }
        
        if ((_index2) == _bit_c)
        {
            return (!(_index & _bit_corner) ? 3 : 0);
        }
        
        var _index3 = ~_index;
        
        if (_index3 & _bit_a)
        {
            return 2;
        }
        
        if (_index3 & _bit_b)
        {
            return 1;
        }
        
        return 0;
    }
    
    if (_index == 0b111_11_111)
    {
        chunk_vertex_tile(
            _buffer,
            _texel_width,
            _texel_height,
            _animation_type,
            _atla,
            _atla_sprite,
            _index_offset,
            _x,
            _y,
            _xscale,
            _yscale,
            _rotation,
            _colour,
            _alpha
        );
        
        exit;
    }
    
    if (_index == 0b010_11_010)
    {
        chunk_vertex_tile(
            _buffer,
            _texel_width,
            _texel_height,
            _animation_type,
            _atla,
            _atla_sprite,
            _index_offset + 3,
            _x,
            _y,
            _xscale,
            _yscale,
            _rotation,
            _colour,
            _alpha
        );
        
        exit;
    }
    
    var _index2 = _index & 0b010_11_010;
    
    if (_index2 == 0b000_00_000)
    {
        chunk_vertex_tile(
            _buffer,
            _texel_width,
            _texel_height,
            _animation_type,
            _atla,
            _atla_sprite,
            _index_offset + 4,
            _x,
            _y,
            _xscale,
            _yscale,
            _rotation,
            _colour,
            _alpha
        );
        
        exit;
    }
    
    if (_index2 == 0b010_00_010)
    {
        chunk_vertex_tile(
            _buffer,
            _texel_width,
            _texel_height,
            _animation_type,
            _atla,
            _atla_sprite,
            _index_offset + 1,
            _x,
            _y,
            _xscale,
            _yscale,
            _rotation,
            _colour,
            _alpha
        );
        
        exit;
    }
    
    if (_index2 == 0b000_11_000)
    {
        chunk_vertex_tile(
            _buffer,
            _texel_width,
            _texel_height,
            _animation_type,
            _atla,
            _atla_sprite,
            _index_offset + 2,
            _x,
            _y,
            _xscale,
            _yscale,
            _rotation,
            _colour,
            _alpha
        );
        
        exit;
    }
    
    var _cos =  dcos(_rotation);
    var _sin = -dsin(_rotation);
    
    var _atla_value = _atla.___value;
    
    var _width  = (_atla_value >> 22) & 2047;
    var _height = (_atla_value >> 33) & 2047;
    
    var _half_width  = _width  / 2;
    var _half_height = _height / 2;
    
    var _xoffset = -_xscale * (((_atla_value >> 0)  & 2047) - 1024);
    var _yoffset = -_yscale * (((_atla_value >> 11) & 2047) - 1024);
    
    var _a = _xoffset * _cos;
    var _b = _xoffset * _sin;
    var _c = _yoffset * _cos;
    var _d = _yoffset * _sin;
    
    var _e = _half_width * _cos;
    var _f = _half_width * _sin;
    var _g = _half_height * _cos;
    var _h = _half_height * _sin;
    
    var _x1 = _xscale * _xoffset;
    var _y1 = _yscale * _yoffset;
    
    var _x2 = _xscale * (_xoffset + _half_width);
    var _y2 = _yscale * (_yoffset + _half_height);
    
    var _uvs = _atla_sprite.___uvs;
    
    var _u0 = _uvs[0];
    var _v0 = _uvs[1];
    
    var _u2 = _uvs[2];
    var _v2 = _uvs[3];
    
    var _u1 = _u0 + ((_u2 - _u0) / 2);
    var _v1 = _v0 + ((_v2 - _v0) / 2);
    
    var _texel_sprite_width = _width * _texel_width;
    
    var _xw = _xscale * _width;
    var _yh = _yscale * _height;
    
    var _xhw = _xscale * _half_width;
    var _yhh = _yscale * _half_height;
    
    var _corner_x1 = _xoffset;
    var _corner_y1 = _yoffset;
    var _corner_x2 = _xoffset + _xhw;
    var _corner_y2 = _yoffset + _yhh;
    
    var _corner_x1_cos = _corner_x1 * _cos;
    var _corner_x1_sin = _corner_x1 * _sin;
    
    var _corner_y1_cos = _corner_y1 * _cos;
    var _corner_y1_sin = _corner_y1 * _sin;
    
    var _corner_x2_cos = _corner_x2 * _cos;
    var _corner_x2_sin = _corner_x2 * _sin;
    
    var _corner_y2_cos = _corner_y2 * _cos;
    var _corner_y2_sin = _corner_y2 * _sin;
    
    var _index_tl = _index_offset + __corner_index(_index, 0b010_00_000, 0b000_10_000, 0b100_00_000);
    var _index_tr = _index_offset + __corner_index(_index, 0b010_00_000, 0b000_01_000, 0b001_00_000);
    var _index_bl = _index_offset + __corner_index(_index, 0b000_00_010, 0b000_10_000, 0b000_00_100);
    var _index_br = _index_offset + __corner_index(_index, 0b000_00_010, 0b000_01_000, 0b000_00_001);
    
    var _vertex = 0b1111;
    
    if (_index_tl == _index_tr)
    {
        // Top
        chunk_vertex_tile_connected_part(
            _buffer,
            _x + _corner_x1_cos - _corner_y1_sin,
            _y + _corner_x1_sin + _corner_y1_cos,
            _xw,
            _yhh,
            _cos,
            _sin,
            _u0,
            _v0,
            _u2,
            _v1,
            _texel_sprite_width,
            _index_tl,
            _colour,
            _alpha
        );
        
        _vertex ^= 0b0011;
    }
    
    if (_index_bl == _index_br)
    {
        // Bottom
        chunk_vertex_tile_connected_part(
            _buffer, 
            _x + _corner_x1_cos - _corner_y2_sin,
            _y + _corner_x1_sin + _corner_y2_cos,
            _xw,
            _yhh,
            _cos,
            _sin,
            _u0,
            _v1,
            _u2,
            _v2,
            _texel_sprite_width,
            _index_bl,
            _colour,
            _alpha
        );
        
        _vertex ^= 0b1100;
    }
    
    if (_index_tl == _index_bl) && ((_vertex & 0b0101) == 0b0101)
    {
        // Left
        chunk_vertex_tile_connected_part(
            _buffer,
            _x + _corner_x1_cos - _corner_y1_sin,
            _y + _corner_x1_sin + _corner_y1_cos,
            _xhw,
            _yh,
            _cos,
            _sin,
            _u0,
            _v0,
            _u1,
            _v2,
            _texel_sprite_width,
            _index_tl,
            _colour,
            _alpha
        );
        
        _vertex ^= 0b0101;
    }
    
    if (_index_tr == _index_br) && ((_vertex & 0b1010) == 0b1010)
    {
        // Right
        chunk_vertex_tile_connected_part(
            _buffer,
            _x + _corner_x2_cos - _corner_y1_sin,
            _y + _corner_x2_sin + _corner_y1_cos,
            _xhw,
            _yh,
            _cos,
            _sin,
            _u1,
            _v0,
            _u2,
            _v2,
            _texel_sprite_width,
            _index_tr,
            _colour,
            _alpha
        );
        
        _vertex ^= 0b1010;
    }
    
    if (_vertex & (1 << 0))
    {
        // Top Left
        chunk_vertex_tile_connected_part(
            _buffer,
            _x + _corner_x1_cos - _corner_y1_sin,
            _y + _corner_x1_sin + _corner_y1_cos,
            _xhw,
            _yhh,
            _cos,
            _sin,
            _u0,
            _v0,
            _u1,
            _v1,
            _texel_sprite_width,
            _index_tl,
            _colour,
            _alpha
        );
    }
    
    if (_vertex & (1 << 2))
    {
        // Bottom Left
        chunk_vertex_tile_connected_part(
            _buffer, 
            _x + _corner_x1_cos - _corner_y2_sin,
            _y + _corner_x1_sin + _corner_y2_cos,
            _xhw,
            _yhh,
            _cos,
            _sin,
            _u0,
            _v1,
            _u1,
            _v2,
            _texel_sprite_width,
            _index_bl,
            _colour,
            _alpha
        );
    }
    
    if (_vertex & (1 << 1))
    {
        // Top Right
        chunk_vertex_tile_connected_part(
            _buffer,
            _x + _corner_x2_cos - _corner_y1_sin,
            _y + _corner_x2_sin + _corner_y1_cos,
            _xhw,
            _yhh,
            _cos, _sin,
            _u1,
            _v0,
            _u2,
            _v1,
            _texel_sprite_width,
            _index_tr,
            _colour,
            _alpha
        );
    }
    
    if (_vertex & (1 << 3))
    {
        // Bottom Right
        chunk_vertex_tile_connected_part(
            _buffer,
            _x + _corner_x2_cos - _corner_y2_sin,
            _y + _corner_x2_sin + _corner_y2_cos,
            _xhw,
            _yhh,
            _cos,
            _sin,
            _u1,
            _v1,
            _u2,
            _v2,
            _texel_sprite_width,
            _index_br,
            _colour,
            _alpha
        );
    }
}