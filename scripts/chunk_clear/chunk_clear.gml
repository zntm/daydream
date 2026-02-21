/// @function chunk_clear(_chunk)
/// @desc Clear and release a chunk
/// @param {Struct.Chunk} _chunk Chunk struct to clear
function chunk_clear(_chunk)
{
    if (_chunk.boolean & CHUNK_BOOLEAN.SAVING) exit;
    
    if (_chunk.chunk_display)
    {
        _chunk.boolean |= CHUNK_BOOLEAN.SAVING;

        chunk_save_queue_add(_chunk);
    }
    else
    {
        global.chunk_pool.release(_chunk);
    }
}
