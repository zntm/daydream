vertex_format_begin();

vertex_format_add_position();
vertex_format_add_texcoord();
vertex_format_add_colour();

vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord);

global.chunk_format_perspective = vertex_format_end();

function render_chunk(_inst, _z)
{
    var _item_data = global.item_data;
    
    var _buffer = vertex_create_buffer();
    
    vertex_begin(_buffer, global.chunk_format_perspective);
    
    var _page = global.___atla_page[$ "item"];
    var _position = global.___atla_page_position[$ "item"];
    
    var _size = global.___atla_surface_size[$ "item"];
    
    var _texture = global.___atla_surface_texture[$ "item"];
    
    var _texel_width  = texture_get_texel_width(_texture);
    var _texel_height = texture_get_texel_height(_texture);
    
    var _xstart = _inst.x;
    var _ystart = _inst.y;
    
    var _chunk = _inst.chunk;
    
    for (var _x = 0; _x < CHUNK_SIZE; ++_x)
    {
        for (var _y = 0; _y < CHUNK_SIZE; ++_y)
        {
            var _tile = _chunk[tile_index_xyz(_x, _y, _z)];
            
            if (_tile == TILE_EMPTY) continue;
            
            var _id = _tile.get_id();
            var _data = _item_data[$ _id];
            
            if (!_data.get_is_visible()) continue;
            
            var _index = _tile.get_index();
            var _index_offset = _tile.get_index_offset();
            
            var _sprite = _data.get_sprite();
            
            var _draw_x = _xstart + (_x << TILE_SIZE_BIT);
            var _draw_y = _ystart + (_y << TILE_SIZE_BIT);
            
            var _xscale = _tile.get_xscale();
            var _yscale = _tile.get_yscale();
            
            var _rotation = _tile.get_rotation();
            
            var _atla = _page[$ _sprite];
            
            if (_data.is_tile())
            {
                var _edge_padding = _data.get_edge_padding();
                
                chunk_vertex_tile_connected(
                    _buffer,
                    _texel_width,
                    _texel_height,
                    _data.get_animation_type(),
                    _atla,
                    _position[_atla.get_sprite_index(0)],
                    _index,
                    _index_offset,
                    _draw_x,
                    _draw_y,
                    _xscale,
                    _yscale,
                    _rotation,
                    c_white,
                    1
                );
                
                continue;
            }
            
            if (_data.is_foliage())
            {
                chunk_vertex_foliage(
                    _buffer,
                    _texel_width,
                    _texel_height,
                    _data.get_animation_type(),
                    _atla,
                    _position[_atla.get_sprite_index(0)],
                    tile_index_xy(_x, _y),
                    _index + _index_offset,
                    _draw_x,
                    _draw_y,
                    _xscale,
                    _yscale,
                    _rotation,
                    c_white,
                    1
                );
                
                continue;
            }
            
            chunk_vertex_tile(
                _buffer,
                _texel_width,
                _texel_height,
                _data.get_animation_type(),
                _atla,
                _position[_atla.get_sprite_index(0)],
                _index + _index_offset,
                _draw_x,
                _draw_y,
                _xscale,
                _yscale,
                _rotation,
                c_white,
                1
            );
        }
    }
    
    _inst.chunk_vertex_buffer[@ _z] = _buffer;
    
    vertex_end(_buffer);
    vertex_freeze(_buffer);
    
    return _buffer;
}