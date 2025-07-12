function tile_update_surrounding(_x, _y, _z, _xoffset = 1, _yoffset = 1)
{
    var _chunk_xstart = floor(_x / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
    var _chunk_ystart = floor(_y / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
    
    var _xstart = _x - _xoffset;
    var _ystart = _y - _yoffset;
    
    var _xend = _x + _xoffset;
    var _yend = _y + _yoffset;
    
    for (var i = _xstart; i <= _xend; ++i)
    {
        for (var j = _ystart; j <= _yend; ++j)
        {
            tile_update(i, j, _z);
            
            var _chunk_x = floor(i / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
            var _chunk_y = floor(j / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
            
            var _inst = instance_position(_chunk_x, _chunk_y, obj_Chunk);
            
            if (instance_exists(_inst)) && ((_chunk_xstart != _chunk_x) || (_chunk_ystart != _chunk_y))
            {
                var _vertex_buffer = _inst.chunk_vertex_buffer[_z];
                
                if (vertex_buffer_exists(_vertex_buffer))
                {
                    vertex_delete_buffer(_vertex_buffer);
                }
            }
        }
    }
}