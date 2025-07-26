function tile_audio_emitter(_x, _y)
{
    if (_y < 0) || (_y >= global.world_data[$ global.world_save_data.dimension].get_world_height())
    {
        return undefined;
    }
    
    var _chunk_x = floor(_x / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
    var _chunk_y = floor(_y / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
    
    var _inst = instance_position(_chunk_x, _chunk_y, obj_Chunk);
    
    if (!instance_exists(_inst))
    {
        return undefined;
    }
    
    return _inst.chunk_audio_emitter[tile_index_xy(_x, _y)];
}