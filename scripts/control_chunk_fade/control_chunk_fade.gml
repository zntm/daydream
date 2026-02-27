function control_chunk_fade()
{
    var _fading_chunks = global.chunk_pool.fading_chunks;
    
    for (var i = array_length(_fading_chunks) - 1; i >= 0; --i)
    {
        var _chunk = _fading_chunks[i];
        
        /* wait for tile processing to complete before starting fade (to prevent pop-in if queue is slow) */
        if !(_chunk.boolean & CHUNK_BOOL.TILE_PROCESSED) continue;
        
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
