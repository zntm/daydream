function chunk_clear(_inst)
{
    if (_inst.chunk_display)
    {
        // Queue for async save instead of blocking save
        chunk_save_queue_add(_inst);
    }
    
    // Release to pool instead of destroying
    global.chunk_pool.release(_inst);
}
