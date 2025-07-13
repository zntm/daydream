function control_chunk_clear(_camera_x, _camera_y, _camera_width, _camera_height)
{
    var _camera_x2 = _camera_x + _camera_width;
    var _camera_y2 = _camera_y + _camera_height;
    
    with (obj_Chunk)
    {
        if (rectangle_distance(xcenter, ycenter, _camera_x, 0, _camera_x2, _camera_y2) > (CHUNK_SIZE_DIMENSION * 8))
        {
            chunk_clear(id);
        }
    }
}