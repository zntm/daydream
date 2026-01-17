/// @desc Update liquid wave forces for chunks in view
/// @param {real} _dt Delta time
/// @param {real} _player_x Player X position
/// @param {real} _player_y Player Y position
/// @param {real} _camera_x Camera X position
/// @param {real} _camera_y Camera Y position
/// @param {real} _camera_width Camera width
/// @param {real} _camera_height Camera height

function control_chunk_liquid(_dt, _player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height)
{
    var _item_data = global.item_data;
    
    for (var i = 0; i < chunk_in_view_length; ++i)
    {
        var _chunk = chunk_in_view[i];
        
        if (_chunk == undefined) || !(_chunk.boolean & CHUNK_BOOLEAN.GENERATED) continue;
        
        var _chunk_display = _chunk.chunk_display;
        
        if !(_chunk_display & (1 << CHUNK_DEPTH_LIQUID)) continue;
        
        for (var l = 0; l < CHUNK_SIZE; ++l)
        {
            for (var m = 0; m < CHUNK_SIZE; ++m)
            {
                var _index = (m << CHUNK_SIZE_BIT) | l;
                var _tile = _chunk.chunk[(CHUNK_DEPTH_LIQUID << (CHUNK_SIZE_BIT * 2)) | _index];
                
                if (_tile == TILE_EMPTY) continue;
                if (!_item_data[$ _tile.get_id()].is_liquid()) continue;
                
                var _wave = _chunk.chunk_wave[_index];
                var _wave_to = _chunk.chunk_wave_to[_index];
                
                // Decay wave force towards zero
                if (_wave != _wave_to)
                {
                    _chunk.chunk_wave[@ _index] = lerp_delta(_wave, _wave_to, 0.90, _dt);
                }
                
                // Decay target towards zero
                if (abs(_wave_to) > 0.01)
                {
                    _chunk.chunk_wave_to[@ _index] = lerp_delta(_wave_to, 0, 0.95, _dt);
                }
                else
                {
                    _chunk.chunk_wave_to[@ _index] = 0;
                }
            }
        }
    }
}

/// @desc Add wave force to a liquid tile (for splash effects)
/// @param {real} _world_x World tile X coordinate
/// @param {real} _world_y World tile Y coordinate
/// @param {real} _force Force amount (positive = up, negative = down)
function liquid_add_wave_force(_world_x, _world_y, _force)
{
    var _chunk_x = floor(_world_x / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
    var _chunk_y = floor(_world_y / CHUNK_SIZE) * CHUNK_SIZE_DIMENSION;
    
    var _chunk = chunk_map_get(_chunk_x, _chunk_y);
    
    if (_chunk == undefined) exit;
    
    var _local_x = _world_x mod CHUNK_SIZE;
    var _local_y = _world_y mod CHUNK_SIZE;
    
    if (_local_x < 0) _local_x += CHUNK_SIZE;
    if (_local_y < 0) _local_y += CHUNK_SIZE;
    
    var _index = (_local_y << CHUNK_SIZE_BIT) | _local_x;
    
    _chunk.chunk_wave_to[@ _index] += _force;
}
