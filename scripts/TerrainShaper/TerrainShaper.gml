/// @desc TerrainShaper - 3D density-based terrain with overhangs via Z-offset
/// Uses squashing factor to compress caves vertically, creating crusty overhangs

/// @param {Struct} _world_data World data struct
/// @returns {Struct.TerrainShaper}
function TerrainShaper(_world_data) constructor
{
    ___world_data = _world_data;
    
    /// @desc Get 3D density at position for solid tiles (Z=0)
    /// @param {Real} _x, _y World position
    /// @param {Real} _seed World seed
    /// @returns {Real} Density (positive = solid, negative = air)
    static get_density_solid = function(_x, _y, _seed)
    {
        return ___get_density_3d(_x, _y, 0, _seed);
    }
    
    /// @desc Get 3D density at position for wall tiles (Z-offset creates overhangs)
    /// Walls extend further than solid due to Z-offset in 3D noise
    static get_density_wall = function(_x, _y, _seed)
    {
        var _z_offset = ___world_data.get_terrain_z_offset_wall();
        return ___get_density_3d(_x, _y, _z_offset, _seed);
    }
    
    /// @desc Get 3D density at position for material variation (sedimentary layers, etc.)
    static get_density_material = function(_x, _y, _seed)
    {
        var _z_offset = ___world_data.get_terrain_z_offset_material();
        return ___get_density_3d(_x, _y, _z_offset, _seed);
    }
    
    /// @desc Estimate surface height using binary search on density
    /// @param {Real} _x World X position
    /// @param {Struct} _region Region data (for base height)
    /// @param {Real} _seed World seed
    /// @returns {Real} Estimated surface Y
    static get_surface_height = function(_x, _region, _seed)
    {
        var _terrain = (_region != undefined) ? _region.get_terrain() : undefined;
        var _base_y = (_terrain != undefined) ? (_terrain[$ "base_height"] ?? 400) : 400;
        
        // Binary search for where density crosses 0
        // Increased range for "crazier" terrain
        var _min_y = _base_y - 400;
        var _max_y = _base_y + 400;
        
        for (var i = 0; i < 12; i++)
        {
            var _mid_y = (_min_y + _max_y) / 2;
            var _density = get_density_solid(_x, _mid_y, _seed);
            
            if (_density > 0)
            {
                _max_y = _mid_y;
            }
            else
            {
                _min_y = _mid_y;
            }
        }
        
        return floor((_min_y + _max_y) / 2);
    }
    
    /// @desc Core 3D density evaluation with terrain shaping and squashing
    /// @param {Real} _x, _y World position
    /// @param {Real} _z Z-slice for 3D noise (0 = solid, offset = wall)
    /// @param {Real} _seed World seed
    static ___get_density_3d = function(_x, _y, _z, _seed)
    {
        // Get shaping parameters
        var _base_height = ___world_data.get_surface_start();
        var _squash = ___world_data.get_terrain_squash_factor();
        var _noise_scale = ___world_data.get_terrain_3d_noise_scale();
        var _threshold = ___world_data.get_terrain_density_threshold();
        
        // === 1. Height gradient ===
        // Above surface = negative (air), below = positive (solid)
        var _depth_from_surface = _y - _base_height;
        var _gradient_strength = 0.006; // More room for caves at depth
        var _height_gradient = _depth_from_surface * _gradient_strength;
        
        // === 2. Continentalness (large-scale surface variation) ===
        var _cont_scale = ___world_data.get_terrain_continentalness_scale();
        var _cont_amp = ___world_data.get_terrain_continentalness_amplitude();
        var _continentalness = open_simplex_noise(_x * _cont_scale, _seed * 7.3, 1.0, 2);
        
        // Shift base height by continentalness
        _height_gradient -= _continentalness * _cont_amp * _gradient_strength;
        
        // === 3. Peaks/Valleys (local variation) ===
        var _peak_scale = ___world_data.get_terrain_peaks_scale();
        var _peak_amp = ___world_data.get_terrain_peaks_amplitude();
        var _peaks = open_simplex_noise(_x * _peak_scale, _seed * 13.7, 1.0, 3);
        _height_gradient -= _peaks * _peak_amp * _gradient_strength;
        
        // === 4. 3D Noise with vertical squashing ===
        // Squash factor compresses Y axis, making caves/overhangs more horizontal
        var _squashed_y = _y * _squash;
        
        var _noise_3d = open_simplex_noise_3d(
            _x * _noise_scale,
            _squashed_y * _noise_scale,
            _z + (_seed * 0.0001),
            1.0,
            3
        );
        
        // === 5. Erosion modifier ===
        var _erosion_scale = ___world_data.get_terrain_erosion_scale();
        // Set range to 1.0 to get -1..1 output
        var _erosion = open_simplex_noise(_x * _erosion_scale, _y * _erosion_scale + 500, 1.0, 2);
        
        // === 6. Final density ===
        // Combine height gradient with 3D noise (buffed weight for larger gaps)
        var _density = _height_gradient + (_noise_3d * (1.8 + _erosion * 0.8));
        
        return _density - 0.05 - _threshold;
    }
}
