function control_chunk_fade()
{
    var _fading_chunks = global.chunk_pool.fading_chunks;
    var _length = array_length(_fading_chunks);
    
    // Process backwards to allow safe removal
    for (var i = _length - 1; i >= 0; --i)
    {
        var _chunk = _fading_chunks[i];
        
        // Safety check if chunk was destroyed but not removed from list (should be handled in on_release, but safe is better)
        if (_chunk == undefined) 
        {
            array_delete(_fading_chunks, i, 1);
            continue;
        }
        
        // Wait for tile processing to complete before starting fade (to prevent pop-in if queue is slow)
        if !(_chunk.boolean & CHUNK_BOOLEAN.TILE_PROCESSED) continue;
        
        // Increase timer
        var _time = global.settings.graphics_chunk_fade_time;
        
        if (_time <= 0)
        {
            _chunk.timer_fade = 1.0;
        }
        else
        {
            _chunk.timer_fade += 1 / (GAME_TICK * _time);
        }
        
        if (_chunk.timer_fade >= 1.0)
        {
            _chunk.timer_fade = 1.0;
            array_delete(_fading_chunks, i, 1);
        }
    }
}
