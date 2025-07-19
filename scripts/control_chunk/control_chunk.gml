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
    
    for (var i = -_a; i <= _a; ++i)
    {
        var _x = _xstart + (i * CHUNK_SIZE_DIMENSION);
        
        for (var j = -_b; j <= _b; ++j)
        {
            var _y = _ystart + (j * CHUNK_SIZE_DIMENSION);
            
            if (_y < 0) || (_y >= _world_height * TILE_SIZE) continue;
            
            var _inst = instance_position(_x, _y, obj_Chunk);
            
            if (!instance_exists(_inst))
            {
                instance_create_layer(_x, _y, "Instances", obj_Chunk);
                
                _refresh = true;
            }
        }
    }
    
    if (_refresh)
    {
        control_refresh_chunk_in_view();
    }
    
    var _xorshift_seed_start = ceil(global.world_save_data.seed / 0x8000);
    
    for (var i = 0; i < chunk_in_view_length; ++i)
    {
        var _inst = chunk_in_view[i];
        
        if (_inst.is_generated) continue;
        
        _inst.is_generated = true;
        
        var _chunk = _inst.chunk;
        
        for (var _tile_z = 0; _tile_z < CHUNK_DEPTH; ++_tile_z)
        {
            if !(_inst.chunk_display & (1 << _tile_z)) continue;
            
            for (var _tile_y = 0; _tile_y < CHUNK_SIZE; ++_tile_y)
            {
                for (var _tile_x = 0; _tile_x < CHUNK_SIZE; ++_tile_x)
                {
                    var _tile = _chunk[(_tile_z << (CHUNK_SIZE_BIT * 2)) | (_tile_y << CHUNK_SIZE_BIT) | _tile_x];
                    
                    if (_tile == TILE_EMPTY) continue;
                    
                    var _data = _item_data[$ _tile.get_id()];
                    
                    var _world_x = _inst.chunk_xstart + _tile_x;
                    var _world_y = _inst.chunk_ystart + _tile_y;
                    
                    tile_instance_create(_world_x, _world_y, _tile_z, _tile);
                    
                    tile_connect(_world_x, _world_y, _tile_z, _tile);
                }
            }
        }
    }
}