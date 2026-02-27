#macro CHUNK_LIQUID_WAVE_LERP_V  0.90
#macro CHUNK_LIQUID_WAVE_DECAY_V 0.95
#macro CHUNK_LIQUID_WAVE_EPSILON 0.01

/// @desc Function Description
/// @param {real} _dt Description
/// @param {any*} _player_x Description
/// @param {any*} _player_y Description
/// @param {any*} _camera_x Description
/// @param {any*} _camera_y Description
/// @param {any*} _camera_width Description
/// @param {any*} _camera_height Description
function control_chunk_liquid(_dt, _player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height)
{
    var _item_data = global.item_data;
    
    for (var i = chunk_in_view_length - 1; i >= 0; --i)
    {
        var _c = chunk_in_view[i];
        
        if (_c == undefined) || !(_c.boolean & CHUNK_BOOL.GENERATED) || !(_c.chunk_display & (1 << CHUNK_DEPTH_LIQUID)) continue;
        
        var _chunk         = _c.chunk;
        var _chunk_wave    = _c.chunk_wave;
        var _chunk_wave_to = _c.chunk_wave_to;
        
        for (var j = CHUNK_SIZE - 1; j >= 0; --j)
        {
            for (var k = CHUNK_SIZE - 1; k >= 0; --k)
            {
                var _idx = (k << CHUNK_SIZE_BIT) | j;
                
                var _tile = _chunk[(CHUNK_DEPTH_LIQUID << (CHUNK_SIZE_BIT * 2)) | _idx];
                
                if (_tile == TILE_EMPTY) || (!_item_data[$ _tile.get_id()].is_liquid()) continue;
                
                var _wave    = _chunk_wave[_idx];
                var _wave_to = _chunk_wave_to[_idx];
                
                /* lerp current wave towards target */
                if (_wave != _wave_to)
                {
                    _c.chunk_wave[@ _idx] = lerp_delta(_wave, _wave_to, CHUNK_LIQUID_WAVE_LERP_V, _dt);
                }
                
                _c.chunk_wave_to[@ _idx] = (abs(_wave_to) > CHUNK_LIQUID_WAVE_EPSILON)
                    /* decay target towards zero */
                    ? lerp_delta(_wave_to, 0, CHUNK_LIQUID_WAVE_DECAY_V, _dt)
                    : 0;
            }
        }
    }
}
