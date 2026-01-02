/// @desc Returns aquifer liquid info at position, or undefined if not in an aquifer
/// @param {Real} _x World X position
/// @param {Real} _y World Y position  
/// @param {Real} _surface_height Surface height at this X
/// @param {Real} _seed World seed
/// @param {Struct} _world_data World data struct
/// @returns {Struct|Undefined} { type: "tile_id", fill_level: 1-8 } or undefined
function worldgen_get_aquifer(_x, _y, _surface_height, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    var _depth = _y - _surface_height;
    
    var _aquifers = _world_data.get_aquifers();
    var _aquifers_length = _world_data.get_aquifers_length();
    
    for (var i = 0; i < _aquifers_length; ++i)
    {
        var _aq = _aquifers[i];
        
        // Check if we're in this aquifer's depth range
        if (_depth >= _aq.depth_min) && (_depth <= _aq.depth_max)
        {
            var _noise_scale = _aq.noise_scale;
            
            // Use noise to determine if this position is in an aquifer pocket
            var _noise = open_simplex_noise(_x * _noise_scale, _y * _noise_scale + ((0xffff * (i + 10)) + 500), _aq.range, _aq.octaves);
            
            if (_noise > _aq.threshold)
            {
                return {
                    type: _aq.type,
                    fill_level: _aq.fill_level
                }
            }
        }
    }
    
    return undefined;
}
