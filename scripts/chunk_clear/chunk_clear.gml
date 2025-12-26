/// @function chunk_clear(_chunk)
/// @desc Clear and release a chunk
/// @param {Struct.Chunk} _chunk Chunk struct to clear
function chunk_clear(_chunk)
{
    if (_chunk.chunk_display)
    {
        // Queue for async save instead of blocking save
        chunk_save_queue_add(_chunk);
    }
    
    // Release to pool instead of destroying
    global.chunk_pool.release(_chunk);
}
