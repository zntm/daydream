/// @desc Get surface height at world x position with biome-aware terrain and edge smoothing
/// @param {Real} _x World X position
/// @param {Real} _seed World seed
/// @param {Struct} _world_data World data struct
/// @returns {Real} Surface height (in tiles)
function worldgen_get_surface_height(_x, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    var _base_amplitude = _world_data.get_surface_noise_offset_max() - _world_data.get_surface_noise_offset_min();
    var _octaves = _world_data.get_surface_noise_offset_octaves();
    var _surface_start = _world_data.get_surface_start();
    
    // Smoothing parameters
    var _smoothing_range = _world_data.get_surface_smoothing_range();
    var _smoothing_factor = _world_data.get_surface_smoothing_factor();
    
    // Get biome at current position
    var _heat = worldgen_get_heat(_x, 0, _seed, _world_data);
    var _humidity = worldgen_get_humidity(_x, 0, _seed, _world_data);
    var _surface_biome_map = _world_data.get_surface_biome_map();
    var _biome_id = _surface_biome_map[(_humidity << WORLDGEN_SIZE_HEAT_BIT) | _heat];
    var _biome_data = global.biome_data[$ _biome_id];
    
    // Calculate base terrain height for this position
    // Use biome salt to decorrelate terrain between different biome families
    // Biome variants with the same salt will share identical terrain shapes
    var _salt = _biome_data.get_salt();
    var _base_noise = open_simplex_noise(_x * _world_data.get_surface_noise_scale(), _world_data.get_surface_seed_offset() + _salt, _base_amplitude, _octaves);
    
    // Apply biome modifiers
    var _height_offset = _biome_data.get_terrain_height_offset();
    var _amplitude_scale = _biome_data.get_terrain_amplitude_scale();
    var _scaled_noise = round(_base_noise * _amplitude_scale);
    var _height = _surface_start - _world_data.get_surface_noise_offset_min() + _scaled_noise + _height_offset;
    
    // Edge smoothing: check if we're near a biome boundary
    // Compare current position to left and right neighbors
    var _heat_left = worldgen_get_heat(_x - _smoothing_range, 0, _seed, _world_data);
    var _heat_right = worldgen_get_heat(_x + _smoothing_range, 0, _seed, _world_data);
    var _humidity_left = worldgen_get_humidity(_x - _smoothing_range, 0, _seed, _world_data);
    var _humidity_right = worldgen_get_humidity(_x + _smoothing_range, 0, _seed, _world_data);
    
    // Detect biome boundary - compare against CURRENT position's heat/humidity
    var _is_left_different = (_heat_left != _heat) || (_humidity_left != _humidity);
    var _is_right_different = (_heat_right != _heat) || (_humidity_right != _humidity);
    var _is_boundary = _is_left_different || _is_right_different;
    
    // Get neighbor biome salts - skip smoothing if they share the same salt
    var _biome_id_left = _is_left_different ? _surface_biome_map[(_humidity_left << WORLDGEN_SIZE_HEAT_BIT) | _heat_left] : _biome_id;
    var _biome_id_right = _is_right_different ? _surface_biome_map[(_humidity_right << WORLDGEN_SIZE_HEAT_BIT) | _heat_right] : _biome_id;
    var _salt_left = global.biome_data[$ _biome_id_left].get_salt();
    var _salt_right = global.biome_data[$ _biome_id_right].get_salt();
    
    // If all salts match, no smoothing needed (biome variants share terrain)
    if (_salt == _salt_left && _salt == _salt_right)
    {
        _is_boundary = false;
    }
    
    if (_is_boundary)
    {
        var _total_weight = 1.0;
        var _weighted_height = _height;
        
        // Blend with left neighbor if different biome
        // Skip blending if neighbor salt matches current salt
        if (_is_left_different && _salt_left != _salt)
        {
            var _biome_left = global.biome_data[$ _biome_id_left];
            
            var _noise_left = open_simplex_noise((_x - _smoothing_range) * _world_data.get_surface_noise_scale(), _world_data.get_surface_seed_offset(), _base_amplitude, _octaves);
            var _height_left = _surface_start - _world_data.get_surface_noise_offset_min() 
                + round(_noise_left * _biome_left.get_terrain_amplitude_scale()) 
                + _biome_left.get_terrain_height_offset();
            
            _weighted_height += _height_left * _smoothing_factor;
            _total_weight += _smoothing_factor;
        }
        
        // Blend with right neighbor if different biome
        // Skip blending if neighbor salt matches current salt
        if (_is_right_different && _salt_right != _salt)
        {
            var _biome_right = global.biome_data[$ _biome_id_right];
            
            var _noise_right = open_simplex_noise((_x + _smoothing_range) * _world_data.get_surface_noise_scale(), _world_data.get_surface_seed_offset(), _base_amplitude, _octaves);
            var _height_right = _surface_start - _world_data.get_surface_noise_offset_min() 
                + round(_noise_right * _biome_right.get_terrain_amplitude_scale()) 
                + _biome_right.get_terrain_height_offset();
            
            _weighted_height += _height_right * _smoothing_factor;
            _total_weight += _smoothing_factor;
        }
        
        _height = _weighted_height / _total_weight;
    }
    
    return _height;
}