function control_chunk_clear(_camera_x, _camera_y, _camera_width, _camera_height)
{
    var _camera_x2 = _camera_x + _camera_width;
    var _camera_y2 = _camera_y + _camera_height;
    
    // Get all chunks from the map
    var _chunks = chunk_map_get_all();
    var _chunk_count = array_length(_chunks);
    
    for (var i = 0; i < _chunk_count; ++i)
    {
        var _chunk = _chunks[i];
        
        if (rectangle_distance(_chunk.xcenter, _chunk.ycenter, _camera_x, 0, _camera_x2, _camera_y2) > (CHUNK_SIZE_DIMENSION * 8))
        {
            chunk_clear(_chunk);
        }
    }
}