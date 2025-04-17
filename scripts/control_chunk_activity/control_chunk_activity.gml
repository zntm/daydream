function control_chunk_activity(_camera_x, _camera_y, _camera_width, _camera_height)
{
    var _x1 = _camera_x;
    var _y1 = _camera_y;
    var _x2 = _camera_x + _camera_width;
    var _y2 = _camera_y + _camera_height;
    
    var _x3 = _x1 - (CHUNK_SIZE_DIMENSION * 4);
    var _y3 = _y1 - (CHUNK_SIZE_DIMENSION * 4);
    var _x4 = _x2 + (CHUNK_SIZE_DIMENSION * 4);
    var _y4 = _y2 + (CHUNK_SIZE_DIMENSION * 4);
    
    var _collect = false;
    
    with (obj_Chunk)
    {
        var _x5 = x - (TILE_SIZE / 2);
        var _y5 = y - (TILE_SIZE / 2);
        var _x6 = _x5 + CHUNK_SIZE_DIMENSION;
        var _y6 = _y5 + CHUNK_SIZE_DIMENSION;
        
        var _is_in_view = rectangle_in_rectangle(_x5, _y5, _x6, _y6, _x1, _y1, _x2, _y2);
        
        if (!_is_in_view)
        {
            if (!rectangle_in_rectangle(_x5, _y5, _x6, _y6, _x3, _y3, _x4, _y4))
            {
                if (chunk_surface_display)
                {
                    for (var _z = 0; _z < CHUNK_DEPTH; ++_z)
                    {
                        var _vertex_buffer = chunk_vertex_buffer[_z];
                        
                        if (vertex_buffer_exists(_vertex_buffer))
                        {
                            _collect = true;
                            
                            vertex_delete_buffer(_vertex_buffer);
                        }
                    }
                }
                
                instance_destroy();
                
                continue;
            }
        }
        
        is_in_view = _is_in_view;
    }
    
    if (_collect)
    {
        gc_collect();
    }
}