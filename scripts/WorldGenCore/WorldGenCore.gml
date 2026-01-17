/// @desc WorldGenCore - Unified world generation system
/// Replaces TerrainShaper with a cleaner, more maintainable API.
/// All noise/spline parameters are centralized here.

/// @desc Helper to create a spline point struct
/// @param {Real} _pos Position (input value, e.g. depth)
/// @param {Real} _val Value (output value, e.g. squash factor)
/// @param {String} _ease Optional easing type
function sp(_pos, _val, _ease = undefined)
{
    var _pt = { position: _pos, value: _val };
    if (_ease != undefined) _pt.easing = _ease;
    
    return _pt;
}

/// @desc WorldGenState - Pre-resolved configuration for world generation
/// Stores flattened parameters for fast access during density evaluation.
/// @param {Struct.WorldData} _world_data
function WorldGenState(_world_data) constructor
{
    base_height = _world_data.get_surface_start();
    erosion_scale = _world_data.get_worldgen_erosion_scale();
    continentalness_scale = _world_data.get_worldgen_continentalness_scale();
    continentalness_amplitude = _world_data.get_worldgen_continentalness_amplitude();
    
    squash_spline = _world_data.get_worldgen_squash_spline() ?? [
        sp(0, 6.0, "ease_out"),
        sp(100, 3.0, "ease_in_out"),
        sp(400, 1.0)
    ];
    
    cave_noise_scale = _world_data.get_worldgen_cave_noise_scale();
    
    cave_noise_range_spline = _world_data.get_worldgen_cave_noise_range_spline() ?? [
        sp(0, 0.05, "ease_out"),
        sp(50, 0.15, "ease_in_out"),
        sp(200, 0.35),
        sp(500, 0.5)
    ];
    
    cave_density_spline = _world_data.get_worldgen_cave_density_spline() ?? [
        sp(0, 0.1, "ease_out"),
        sp(100, 0.3, "ease_in_out"),
        sp(400, 0.5)
    ];
    
    cave_smoothness_spline = _world_data.get_worldgen_cave_smoothness_spline() ?? [
        sp(0, 2),
        sp(300, 4)
    ];
    
    z_offset_wall = 0.075;
    z_range_wall = 0.05;
    z_offset_material = 0.5;
}

/// @desc Core density evaluation with biome modifier blending
/// @param {Real} _x, _y, _z World position
/// @param {Real} _seed World seed
/// @param {Struct.WorldGenState} _config Pre-resolved worldgen configuration
/// @returns {Real} Density (positive = solid, negative = air)
function worldgen_get_density(_x, _y, _z, _seed, _config = global.chunk_pool.worldgen_config)
{
    var _depth = _y - _config.base_height;
    
    var _mods = worldgen_get_biome_modifiers(_x, _y, _seed);
    
    var _gradient_strength = 0.006;
    var _height_gradient = _depth * _gradient_strength;
    
    var _continentalness = open_simplex_noise(_x * _config.continentalness_scale, _seed * 7.3, 1.0, 2);
    _continentalness += _mods.continentalness;
    _height_gradient -= _continentalness * _config.continentalness_amplitude * _gradient_strength;
    
    var _squash = spline_evaluate(_config.squash_spline, _depth) * _mods.squash;
    var _squashed_y = _y * _squash;
    
    var _noise_3d = open_simplex_noise_3d(
        _x * _config.cave_noise_scale,
        _squashed_y * _config.cave_noise_scale,
        _z + (_seed * 0.0001),
        1.0,
        spline_evaluate(_config.cave_smoothness_spline, _depth)
    );
    
    var _cave_density = spline_evaluate(_config.cave_density_spline, _depth) * _mods.cave_density;
    var _noise_range = spline_evaluate(_config.cave_noise_range_spline, _depth);
    
    var _erosion = open_simplex_noise(_x * _config.erosion_scale, _y * _config.erosion_scale + 500, 1.0, 2) * _mods.erosion;
    
    var _cave_carve = (_noise_3d > -_noise_range && _noise_3d < _noise_range) ? -_cave_density : 0;
    var _density = _height_gradient + (_noise_3d * (1.8 + _erosion * 0.8)) + _cave_carve;
    
    return _density - 0.05;
}

/// @desc Get blended biome modifiers
function worldgen_get_biome_modifiers(_x, _y, _seed)
{
    var _region = global.region_generator.get_region(_x, _y, 0, _seed);
    var _biome = global.biome_data[$ _region.get_surface_biome_id()];
    
    if (_biome == undefined) return { erosion: 1.0, squash: 1.0, cave_density: 1.0, continentalness: 0.0 };
    
    var _smoothing = _biome.get_terrain_smoothing();
    var _influence = _biome.get_terrain_influence();
    
    var _erosion = lerp(1.0, _biome.get_erosion_modifier(), _influence);
    var _squash = lerp(1.0, _biome.get_squash_modifier(), _influence);
    var _cave_density = lerp(1.0, _biome.get_cave_density_modifier(), _influence);
    var _continentalness = _biome.get_continentalness_modifier() * _influence;
    
    if (_smoothing > 0)
    {
        var _boundary_dist = global.region_generator.get_boundary_distance(_x, _y, 0, _seed);
        if (_boundary_dist < _smoothing)
        {
            var _blend = _boundary_dist / _smoothing;
            var _blend_smooth = _blend * _blend * (3 - 2 * _blend);
            
            _erosion = lerp(1.0, _erosion, _blend_smooth);
            _squash = lerp(1.0, _squash, _blend_smooth);
            _cave_density = lerp(1.0, _cave_density, _blend_smooth);
            _continentalness = lerp(0.0, _continentalness, _blend_smooth);
        }
    }
    
    return { erosion: _erosion, squash: _squash, cave_density: _cave_density, continentalness: _continentalness };
}

/// @desc Evaluate surface height
function worldgen_get_surface_height_3d(_x, _seed, _config = global.chunk_pool.worldgen_config)
{
    var _min_y = _config.base_height - 400;
    var _max_y = _config.base_height + 400;
    
    repeat(12)
    {
        var _mid_y = (_min_y + _max_y) * 0.5;
        if (worldgen_get_density(_x, _mid_y, 0, _seed, _config) > 0) _max_y = _mid_y;
        else _min_y = _mid_y;
    }
    
    return floor((_min_y + _max_y) * 0.5);
}

/// @desc Check if solid
function worldgen_is_solid(_x, _y, _seed, _config = global.chunk_pool.worldgen_config)
{
    return worldgen_get_density(_x, _y, 0, _seed, _config) > 0;
}

/// @desc Check if wall
function worldgen_is_wall(_x, _y, _seed, _config = global.chunk_pool.worldgen_config)
{
    var _z = _config.z_offset_wall;
    var _r = _config.z_range_wall;
    
    if (_r <= 0) return worldgen_get_density(_x, _y, _z, _seed, _config) > 0;
    
    return max(
        worldgen_get_density(_x, _y, _z - _r, _seed, _config),
        worldgen_get_density(_x, _y, _z, _seed, _config),
        worldgen_get_density(_x, _y, _z + _r, _seed, _config)
    ) > 0;
}

/// @desc Compatibility: Get solid density
function worldgen_get_density_solid(_x, _y, _seed, _config = global.chunk_pool.worldgen_config)
{
    return worldgen_get_density(_x, _y, 0, _seed, _config);
}

/// @desc Compatibility: Get wall density
function worldgen_get_density_wall(_x, _y, _seed, _config = global.chunk_pool.worldgen_config)
{
    var _z = _config.z_offset_wall;
    var _r = _config.z_range_wall;
    
    if (_r <= 0) return worldgen_get_density(_x, _y, _z, _seed, _config);
    
    return max(
        worldgen_get_density(_x, _y, _z - _r, _seed, _config),
        worldgen_get_density(_x, _y, _z, _seed, _config),
        worldgen_get_density(_x, _y, _z + _r, _seed, _config)
    );
}

/// @desc Compatibility: Get material density
function worldgen_get_density_material(_x, _y, _seed, _config = global.chunk_pool.worldgen_config)
{
    return worldgen_get_density(_x, _y, _config.z_offset_material, _seed, _config);
}
