#macro CHUNK_FOLIAGE_UPDATE_CHANCE 0.1
#macro CHUNK_FOLIAGE_WIND_MAX_OFFSET 0.25
#macro CHUNK_FOLIAGE_LERP_V 0.95

function control_chunk_foliage(_dt, _player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height)
{
    var _item_data = global.item_data;
    
    var _world_save_data = global.world_save_data;
    var _world_data = global.world_data[$ _world_save_data.dimension];
    
    var _skew_strength = clamp(_world_save_data.weather_wind + random_range(-CHUNK_FOLIAGE_WIND_MAX_OFFSET, CHUNK_FOLIAGE_WIND_MAX_OFFSET), -1, 1);
    
    for (var i = chunk_in_view_length - 1; i >= 0; --i)
    {
        var _c = chunk_in_view[i];
        
        if (_c == undefined) || !(_c.boolean & CHUNK_BOOLEAN.GENERATED) continue;
        
        var _chunk         = _c.chunk;
        var _chunk_count   = _c.chunk_count;
        var _chunk_covered = _c.chunk_covered;
        var _chunk_display = _c.chunk_display;
        
        if (_chunk_display & ((1 << CHUNK_DEPTH_FOLIAGE_BACK) | (1 << CHUNK_DEPTH_FOLIAGE_FRONT))) && ((_chunk_count[CHUNK_DEPTH_FOLIAGE_BACK] > 0) || (_chunk_count[CHUNK_DEPTH_FOLIAGE_FRONT] > 0))
        {
            var _chunk_skew = _c.chunk_skew;
            var _chunk_skew_to = _c.chunk_skew_to;
            
            for (var j = 0; j < CHUNK_SIZE; ++j)
            {
                var _covered = _chunk_covered[j];
                
                for (var k = 0; k < CHUNK_SIZE; ++k)
                {
                    var _skew_idx = (k << CHUNK_SIZE_BIT) | j;
                    
                    /* (CHUNK_SIZE_BIT * 2) is the z index for the flat array */
                    var _tile = _chunk[(CHUNK_DEPTH_FOLIAGE_BACK << (CHUNK_SIZE_BIT * 2)) | _skew_idx];
                    
                    if (_tile == TILE_EMPTY) || (!_item_data[$ _tile.get_id()].is_foliage()) continue;
                    
                    if (_covered & (1 << k))
                    {
                        var _skew = _chunk_skew[_skew_idx];
                        var _skew_to = _chunk_skew_to[_skew_idx];
                        
                        _c.chunk_skew[@ _skew_idx] = lerp_delta(_skew, _skew_to, CHUNK_FOLIAGE_LERP_V, _dt);
                        
                        continue;
                    }
                    
                    if (chance(CHUNK_FOLIAGE_UPDATE_CHANCE))
                    {
                        _c.chunk_skew_to[@ _skew_idx] = random(_skew_strength) * (TILE_SIZE / 2);
                        
                        continue;
                    }
                    
                    var _skew = _chunk_skew[_skew_idx];
                    var _skew_to = _chunk_skew_to[_skew_idx];
                    
                    if (_skew != _skew_to)
                    {
                        _c.chunk_skew[@ _skew_idx] = lerp_delta(_skew, _skew_to, CHUNK_FOLIAGE_LERP_V, _dt);
                    }
                }
            }
        }
    }
}
