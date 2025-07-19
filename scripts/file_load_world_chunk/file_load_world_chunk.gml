function file_load_world_chunk(_world_save_data, _inst)
{
    var _item_data = global.item_data;
    var _world_data = global.world_data[$ _world_save_data.dimension];
    
    var _chunk_x = _inst.chunk_xstart / CHUNK_SIZE;
    var _chunk_y = _inst.chunk_ystart / CHUNK_SIZE;
    
    var _region_x = floor(_chunk_x / CHUNK_REGION_SIZE);
    var _region_y = floor(_chunk_y / CHUNK_REGION_SIZE);
    
    var _directory = $"{PROGRAM_DIRECTORY_WORLDS}/{_world_save_data.uuid}/dimension/{_world_data.get_namespace()}/{_world_data.get_id()}/chunk/{_region_x} {_region_y}.dat";
    
    if (!file_exists(_directory))
    {
        return false;
    }
    
    var _buffer = buffer_load_decompressed(_directory);
    
    var _chunk_relative_x = ((_chunk_x % CHUNK_REGION_SIZE) + CHUNK_REGION_SIZE) % CHUNK_REGION_SIZE;
    var _chunk_relative_y = ((_chunk_y % CHUNK_REGION_SIZE) + CHUNK_REGION_SIZE) % CHUNK_REGION_SIZE;
    
    var _bit = buffer_peek(_buffer, _chunk_relative_x * 4, buffer_u32);
    
    if !(_bit & (1 << _chunk_relative_y))
    {
        return false;
    }
    
    var _version_major = buffer_read(_buffer, buffer_u16);
    var _version_minor = buffer_read(_buffer, buffer_u16);
    var _version_patch = buffer_read(_buffer, buffer_u16);
    var _version_type = buffer_read(_buffer, buffer_u16);
    
    var _datetime = unix_to_datetime(buffer_read(_buffer, buffer_f64));
    
    var _seek = (CHUNK_REGION_SIZE * 4) + (((_chunk_relative_y * CHUNK_REGION_SIZE) + _chunk_relative_x) * (1 << 16));
    
    buffer_seek(_buffer, buffer_seek_start, _seek);
    
    _inst.is_generated = buffer_read(_buffer, buffer_bool);
    
    var _chunk_display = buffer_read(_buffer, buffer_u16);
    
    _inst.chunk_display = _chunk_display;
    
    if (_chunk_display)
    {
        for (var i = 0; i < CHUNK_DEPTH; ++i)
        {
            if !(_chunk_display & (1 << i)) continue;
            
            _inst.chunk_count[@ i] = buffer_read(_buffer, buffer_u16);
            
            for (var j = 0; j < CHUNK_SIZE; ++j)
            {
                for (var l = 0; l < CHUNK_SIZE; ++l)
                {
                    _inst.chunk[@ tile_index(l, j, i)] = file_load_snippet_tile(_buffer, _item_data);
                }
            }
        }
    }
    
    buffer_delete(_buffer);
    
    return true;
}