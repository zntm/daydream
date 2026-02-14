function control_chunk(_player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height)
{
    var _item_data = global.item_data;
    
    var _camera_x_real = global.camera_x_real;
    var _camera_y_real = global.camera_y_real;
    
    var _xstart = round((_camera_x + (_camera_width  / 2)) / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION;
    var _ystart = round((_camera_y + (_camera_height / 2)) / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION;
    
    var _a = ceil(_camera_width  / (2 * CHUNK_SIZE_DIMENSION)) + 1;
    var _b = ceil(_camera_height / (2 * CHUNK_SIZE_DIMENSION)) + 1;
    
    var _world_data = global.world_data[$ global.world_save_data.dimension];
    var _world_height = _world_data.get_world_height();
    
    var _refresh = false;
    
    // Create chunks that don't exist
    for (var i = -_a; i <= _a; ++i)
    {
        var _x = _xstart + (i * CHUNK_SIZE_DIMENSION);
        
        for (var j = -_b; j <= _b; ++j)
        {
            var _y = _ystart + (j * CHUNK_SIZE_DIMENSION);
            
            if (_y < 0) || (_y >= _world_height * TILE_SIZE) continue;
            
            if (!chunk_map_exists(_x, _y))
            {
                global.chunk_pool.acquire(_x, _y);
                
                _refresh = true;
            }
        }
    }
    
    if (_refresh)
    {
        control_update_chunk_in_view();
    }
    
    // Queue ungenerated chunks for processing (priority = distance to player)
    for (var i = 0; i < chunk_in_view_length; ++i)
    {
        var _chunk = chunk_in_view[i];
        
        if (_chunk == undefined) continue;
        if (_chunk.boolean & CHUNK_BOOLEAN.GENERATED) continue;
        if (_chunk.boolean & CHUNK_BOOLEAN.QUEUED) continue;
        
        // Calculate priority based on distance to player (lower = higher priority)
        var _priority = point_distance(_player_x, _player_y, _chunk.xcenter, _chunk.ycenter);
        
        chunk_queue_add(_chunk, _priority);
    }
    
    // Process queued chunks within time budget
    chunk_queue_process(_player_x, _player_y);
    
    // Process queued chunk saves within time budget
    chunk_save_queue_process();
}
