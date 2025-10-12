function control_chunk_activity(_camera_x, _camera_y, _camera_width, _camera_height)
{
    var _x1 = _camera_x - (CHUNK_SIZE_DIMENSION * 4);
    var _y1 = _camera_y - (CHUNK_SIZE_DIMENSION * 4);
    var _x2 = _camera_x + _camera_width  + (CHUNK_SIZE_DIMENSION * 4);
    var _y2 = _camera_y + _camera_height + (CHUNK_SIZE_DIMENSION * 4);
    
    var _collect = false;
    
    with (obj_Chunk)
    {
        var _x3 = x - (TILE_SIZE / 2);
        var _y3 = y - (TILE_SIZE / 2);
        var _x4 = _x3 + CHUNK_SIZE_DIMENSION;
        var _y4 = _y3 + CHUNK_SIZE_DIMENSION;
        
        if (!rectangle_in_rectangle(_x1, _y1, _x2, _y2, _x3, _y3, _x4, _y4))
        {
            chunk_clear(id);
            
            _collect = true;
        }
    }
    
    if (_collect)
    {
        gc_collect();
    }
}