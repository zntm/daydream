vertex_format_begin();

vertex_format_add_colour();
vertex_format_add_position();
vertex_format_add_texcoord();

global.chunk_format_perspective = vertex_format_end();

function render_chunk(_uv, _inst, _z)
{
    if (!instance_exists(_inst)) exit;
    
    var _item_data = global.item_data;
    
    var _buffer = vertex_create_buffer();
    
    vertex_begin(_buffer, global.chunk_format_perspective);
    
    var _size = global.carbasa_surface_size[$ "item"];
    
    var _surface_width  = (_size >>  0) & 0xffff;
    var _surface_height = (_size >> 16) & 0xffff;
    
    for (var _x = 0; _x < CHUNK_SIZE; ++_x)
    {
        for (var _y = 0; _y < CHUNK_SIZE; ++_y)
        {
            var _tile = _inst.chunk[(_z << (CHUNK_SIZE_BIT * 2)) | (_y << CHUNK_SIZE_BIT) | _x];
            
            if (_tile == TILE_EMPTY) continue;
            
            var _item_id = _tile.get_item_id();
            var _index = _tile.get_index();
            
            var _data = _item_data[$ _item_id];
            
            if (_z == CHUNK_DEPTH_WALL) && (_index == 0b111_11_111) && (_data.is_obstructable())
            {
                var _default_tile = _inst.chunk[(CHUNK_DEPTH_DEFAULT << (CHUNK_SIZE_BIT * 2)) | (_y << CHUNK_SIZE_BIT) | _x];
                
                if (_default_tile != TILE_EMPTY) && (_default_tile.get_index() == 0b111_11_111)
                {
                    var _default_tile_data = _item_data[$ _default_tile.get_item_id()];
                    
                    if (_default_tile_data.has_type(ITEM_TYPE_BIT.SOLID)) && (_default_tile_data.is_tile()) && (_default_tile_data.is_obstructing()) continue;
                }
            }
            
            var _draw_x = _inst.x + (_x * TILE_SIZE);
            var _draw_y = _inst.y + (_y * TILE_SIZE);
            
            var _xscale = _tile.get_xscale();
            var _yscale = _tile.get_yscale();
            
            var _rotation = _tile.get_rotation();
            
            if (_data.is_tile())
            {
                var _edge_padding = _data.get_edge_padding();
                
                render_connected_tile(_buffer, _uv, _surface_width, _surface_height, _item_id, _index, 0, _edge_padding, _draw_x, _draw_y, _xscale, _yscale, _rotation, c_white, 1);
                
                continue;
            }
            
            render_tile(_buffer, _uv, _surface_width, _surface_height, _item_id, _index + _tile.get_index_offset(), _draw_x, _draw_y, _xscale, _yscale, _rotation, c_white, 1);
        }
    }
    
    _inst.chunk_render |= 1 << _z;
    
    _inst.chunk_vertex_buffer[@ _z] = _buffer;
    
    vertex_end(_buffer);
    vertex_freeze(_buffer);
}