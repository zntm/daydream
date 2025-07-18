function control_chunk_foliage(_dt, _player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height)
{
    var _item_data = global.item_data;
    
    var _a = ceil(_camera_width  / (2 * CHUNK_SIZE_DIMENSION)) + 1;
    var _b = ceil(_camera_height / (2 * CHUNK_SIZE_DIMENSION)) + 1;
    
    var _world_save_data = global.world_save_data;
    
    var _world_data = global.world_data[$ _world_save_data.dimension];
    var _world_height = _world_data.get_world_height();
    
    var _wind = clamp(_world_save_data.weather_wind + random_range(-0.25, 0.25), -1, 1);
    
    for (var i = -_a; i < _a; ++i)
    {
        for (var j = -_b; j < _b; ++j)
        {
            var _x = (round(_player_x / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION) + (i * CHUNK_SIZE_DIMENSION);
            var _y = (round(_player_y / CHUNK_SIZE_DIMENSION) * CHUNK_SIZE_DIMENSION) + (j * CHUNK_SIZE_DIMENSION);
            
            if (_y < 0) || (_y >= _world_height * TILE_SIZE) continue;
            
            var _inst = instance_position(_x, _y, obj_Chunk);
            
            if (!instance_exists(_inst)) || (!_inst.is_generated) continue;
            
            var _chunk_display = _inst.chunk_display;
            var _chunk_count   = _inst.chunk_count;
            
            if (_chunk_display & (1 << CHUNK_DEPTH_FOLIAGE_BACK)) && (_chunk_count[CHUNK_DEPTH_FOLIAGE_BACK] > 0)
            {
                for (var l = 0; l < CHUNK_SIZE; ++l)
                {
                    var _chunk_covered = _inst.chunk_covered[l];
                    
                    if (!_chunk_covered) continue;
                    
                    for (var m = 0; m < CHUNK_SIZE; ++m)
                    {
                        if !(_chunk_covered & (1 << m)) continue;
                        
                        var _tile = _inst.chunk[(CHUNK_DEPTH_FOLIAGE_BACK << (CHUNK_SIZE_BIT * 2)) | (m << CHUNK_SIZE_BIT) | l];
                        
                        if (_tile == TILE_EMPTY) || (!_item_data[$ _tile.get_id()].is_foliage()) continue;
                        
                        if (chance(0.1))
                        {
                            _inst.chunk_skew_back_to[@ (m << CHUNK_SIZE_BIT) | l] = random_range(0, _wind) * (TILE_SIZE / 2);
                            
                            continue;
                        }
                        
                        var _skew = _inst.chunk_skew_back[(m << CHUNK_SIZE_BIT) | l];
                        var _skew_to = _inst.chunk_skew_back_to[(m << CHUNK_SIZE_BIT) | l];
                        
                        if (_skew != _skew_to)
                        {
                            _inst.chunk_skew_back[@ (m << CHUNK_SIZE_BIT) | l] = lerp_delta(_skew, _skew_to, 0.95, _dt);
                        }
                    }
                }
            }
            
            if (_chunk_display & (1 << CHUNK_DEPTH_FOLIAGE_FRONT)) && (_chunk_count[CHUNK_DEPTH_FOLIAGE_FRONT] > 0)
            {
                for (var l = 0; l < CHUNK_SIZE; ++l)
                {
                    var _chunk_covered = _inst.chunk_covered[l];
                    
                    if (!_chunk_covered) continue;
                    
                    for (var m = 0; m < CHUNK_SIZE; ++m)
                    {
                        if !(_chunk_covered & (1 << m)) continue;
                        
                        var _tile = _inst.chunk[(CHUNK_DEPTH_FOLIAGE_FRONT << (CHUNK_SIZE_BIT * 2)) | (m << CHUNK_SIZE_BIT) | l];
                        
                        if (_tile == TILE_EMPTY) || (!_item_data[$ _tile.get_id()].is_foliage()) continue;
                        
                        if (chance(0.1))
                        {
                            _inst.chunk_skew_front_to[@ (m << CHUNK_SIZE_BIT) | l] = random_range(0, _wind) * (TILE_SIZE / 2);
                            
                            continue;
                        }
                        
                        var _skew = _inst.chunk_skew_front[(m << CHUNK_SIZE_BIT) | l];
                        var _skew_to = _inst.chunk_skew_front_to[(m << CHUNK_SIZE_BIT) | l];
                        
                        if (_skew != _skew_to)
                        {
                            _inst.chunk_skew_front[@ (m << CHUNK_SIZE_BIT) | l] = lerp_delta(_skew, _skew_to, 0.95, _dt);
                        }
                    }
                }
            }
        }
    }
}