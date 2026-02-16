function control_chunk_clear(_camera_x, _camera_y, _camera_width, _camera_height)
{
    var _camera_x2 = _camera_x + _camera_width;
    var _camera_y2 = _camera_y + _camera_height;
    
    var _chunks = chunk_map_get_all();
    
    for (var i = array_length(_chunks) - 1; i >= 0; --i)
    {
        var _c = _chunks[i];
        
        if (rectangle_distance(_c.xcenter, _c.ycenter, _camera_x, 0, _camera_x2, _camera_y2) > (CHUNK_SIZE_DIMENSION * 8))
        {
            chunk_clear(_c);
        }
    }
}