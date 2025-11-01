vertex_format_begin();

vertex_format_add_colour();
vertex_format_add_position();
vertex_format_add_texcoord();

vertex_format_add_custom(vertex_type_float4, vertex_usage_texcoord);

global.chunk_format_perspective = vertex_format_end();

function render_chunk(_uv, _inst, _z)
{
    var _item_data = global.item_data;
    
    var _buffer = vertex_create_buffer();
    
    vertex_begin(_buffer, global.chunk_format_perspective);
    
    var _page = global.carbasa_page[$ "item"];
    var _position = global.carbasa_page_position[$ "item"];
    
    var _size = global.carbasa_surface_size[$ "item"];
    
    var _surface_width  = (_size >>  0) & 0xffff;
    var _surface_height = (_size >> 16) & 0xffff;
    
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
            
            if (!_data.get_tile_is_visible()) continue;
            
            var _index = _tile.get_index();
            
            var _sprite = _data.get_sprite();
            
            var _draw_x = _xstart + (_x * TILE_SIZE);
            var _draw_y = _ystart + (_y * TILE_SIZE);
            
            var _xscale = _tile.get_xscale();
            var _yscale = _tile.get_yscale();
            
            var _rotation = _tile.get_rotation();
            
            var _atla_data = atla_get_data("item", _sprite, _index + _tile.get_index_offset());
            
            if (_data.is_tile())
            {
                var _edge_padding = _data.get_edge_padding();
                
                render_connected_tile(_buffer, _data, _atla_data, _sprite, _position, _uv, _surface_width, _surface_height, _index, _tile.get_index_offset(), _edge_padding, _draw_x, _draw_y, _xscale, _yscale, _rotation, c_white, 1);
                
                continue;
            }
            
            if (_data.is_foliage())
            {
                render_tile_foliage(_buffer, _atla_data, _sprite, _position, _uv, tile_index_xy(_x, _y), _surface_width, _surface_height, _index + _tile.get_index_offset(), _draw_x, _draw_y, _xscale, _yscale, _rotation, c_white, 1);
                
                continue;
            }
            
            render_tile(_buffer, _sprite, _atla_data, _position, _uv, _surface_width, _surface_height, _id, _index + _tile.get_index_offset(), _draw_x, _draw_y, _xscale, _yscale, _rotation, c_white, 1);
        }
    }
    
    _inst.chunk_vertex_buffer[@ _z] = _buffer;
    
    vertex_end(_buffer);
    vertex_freeze(_buffer);
    
    return _buffer;
}