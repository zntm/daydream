#macro CHUNK_FOLIAGE_UPDATE_CHANCE   0.1
#macro CHUNK_FOLIAGE_WIND_MAX_OFFSET 0.25
#macro CHUNK_FOLIAGE_LERP_V          4.0

/// @desc Handles the wind skewing logic for foliage within active chunks.
/// @param {real} _dt The delta time for frame-independent movement.
function control_chunk_foliage(_dt)
{
    var _item_data = global.item_data;
    
    var _skew_strength = clamp(
        global.current_world.weather.wind + random_range(
            -CHUNK_FOLIAGE_WIND_MAX_OFFSET,
             CHUNK_FOLIAGE_WIND_MAX_OFFSET
        ),
        -1,
         1
    );
    
    for (var i = chunk_in_view_length - 1; i >= 0; --i)
    {
        var _c = chunk_in_view[i];
        
        if (_c == undefined) || !(_c.boolean & CHUNK_BOOLEAN.GENERATED) continue;
        
        var _chunk         = _c.chunk;
        var _chunk_count   = _c.chunk_count;
        var _chunk_covered = _c.chunk_covered;
        var _chunk_display = _c.chunk_display;
        
        if !(_chunk_display & ((1 << CHUNK_DEPTH_FOLIAGE_BACK) | (1 << CHUNK_DEPTH_FOLIAGE_FRONT)))
            || ((_chunk_count[CHUNK_DEPTH_FOLIAGE_BACK] <= 0) && (_chunk_count[CHUNK_DEPTH_FOLIAGE_FRONT] <= 0)) continue;
        
        var _chunk_skew    = _c.chunk_skew;
        var _chunk_skew_to = _c.chunk_skew_to;
        
        for (var j = CHUNK_SIZE - 1; j >= 0; --j)
        {
            var _covered = _chunk_covered[j];
            
            for (var k = CHUNK_SIZE - 1; k >= 0; --k)
            {
                var _skew_idx = (k << CHUNK_SIZE_BIT) | j;
                
                /* more optimal to skew all tiles rather than checking for foliage first */
                var _skew    = _chunk_skew[_skew_idx];
                var _skew_to = _chunk_skew_to[_skew_idx];
                
                if !(_covered & (1 << k)) && (chance(CHUNK_FOLIAGE_UPDATE_CHANCE))
                {
                    _c.chunk_skew_to[@ _skew_idx] = random(_skew_strength) * (TILE_SIZE / 2);
                    
                    continue;
                }
                
                if (_skew != _skew_to)
                {
                    _c.chunk_skew[@ _skew_idx] = lerp_delta(_skew, _skew_to, CHUNK_FOLIAGE_LERP_V, _dt);
                }
            }
        }
    }
}
