/// @function chunk_clear(_chunk)
/// @desc Clear and release a chunk
/// @param {Struct.Chunk} _chunk Chunk struct to clear
function chunk_clear(_chunk)
{
    if (_chunk.chunk_display)
    {
        chunk_save_queue_add(_chunk);
    }
    
    global.chunk_pool.release(_chunk);
}
