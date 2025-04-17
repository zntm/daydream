var _texture = global.carbasa_surface_texture[$ "item"];

for (var _z = 0; _z < CHUNK_DEPTH; ++_z)
{
    var _bitmask = 1 << _z;
    
    with (obj_Chunk)
    {
        if (!is_in_view) || ((chunk_surface_display & _bitmask) == 0) continue;
        
        if (!vertex_buffer_exists(chunk_vertex_buffer[_z]))
        {
            render_chunk(global.carbasa_surface_uv[$ "item"], id, _z);
        }
        /*
        draw_rectangle(x - (TILE_SIZE / 2), y - (TILE_SIZE / 2), x - (TILE_SIZE / 2) + CHUNK_SIZE_DIMENSION - 1, y - (TILE_SIZE / 2) + CHUNK_SIZE_DIMENSION - 1, true);
        draw_rectangle_colour(x + TILE_SIZE - (TILE_SIZE / 2), y + TILE_SIZE - (TILE_SIZE / 2), x - TILE_SIZE - (TILE_SIZE / 2) + CHUNK_SIZE_DIMENSION - 1, y - TILE_SIZE - (TILE_SIZE / 2) + CHUNK_SIZE_DIMENSION - 1, c_red, c_red, c_red, c_red, true);
        */
        var _buffer = chunk_vertex_buffer[_z];
        
        if (chunk_render & _bitmask) && (vertex_buffer_exists(_buffer))
        {
            vertex_submit(_buffer, pr_trianglelist, _texture);
        }
    }
}

// draw_surface(global.carbasa_surface.item, obj_Player.x, obj_Player.y + 128);