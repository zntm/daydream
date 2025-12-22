function tile_update_surrounding(_x, _y, _z, _xoffset = 2, _yoffset = 2)
{
    var _xstart = _x - _xoffset;
    var _ystart = _y - _yoffset;
    
    var _xend = _x + _xoffset;
    var _yend = _y + _yoffset;
    
    for (var i = _xstart; i <= _xend; ++i)
    {
        for (var j = _ystart; j <= _yend; ++j)
        {
            var _inst = chunk_map_get_by_tile(i, j);
            
            for (var l = 0; l < CHUNK_DEPTH; ++l)
            {
                tile_update(i, j, l);
                
                if (instance_exists(_inst))
                {
                    var _vertex_buffer = _inst.chunk_vertex_buffer[l];
                    
                    if (vertex_buffer_exists(_vertex_buffer))
                    {
                        vertex_delete_buffer(_vertex_buffer);
                    }
                }
            }
        }
    }
}