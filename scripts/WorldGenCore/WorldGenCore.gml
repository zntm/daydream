/// @desc WorldGenCore - Unified world generation system
/// Replaces TerrainShaper with a cleaner, more maintainable API.
/// All noise/spline parameters are centralized here.

/// @desc Helper to create a spline point struct
/// @param {Real} _pos Position (input value, e.g. depth)
/// @param {Real} _val Value (output value, e.g. squash factor)
/// @param {String} _ease Optional easing type
function sp(_pos, _val, _ease = undefined)
{
    var _pt = {
        position: _pos,
        value: _val
    }
    
    if (_ease != undefined)
    {
        _pt.easing = _ease;
    }
    
    return _pt;
}

/// @desc WorldGenState - Pre-resolved configuration for world generation
/// Stores flattened parameters for fast access during density evaluation.
/// @param {Struct.WorldData} _world_data
function WorldGenState(_world_data) constructor
{
    base_height = _world_data.get_surface_start();
    
    // Simplified system parameters (1D surface)
    surface_noise_octaves = _world_data.get_surface_noise_offset_octaves();
    surface_noise_scale = _world_data.get_surface_noise_scale();
}

/// @desc Get the 1D surface height at a specific X position, factoring in biome modifiers
function worldgen_get_surface_height_at(_x, _seed, _config = global.chunk_pool.worldgen_config)
{
    var _noise_scale = _config.surface_noise_scale;
    var _octaves = _config.surface_noise_octaves;
    var _range_min = _config.surface_noise_range_min;
    var _range_max = _config.surface_noise_range_max;
    
    var _noise = open_simplex_noise(_x * _noise_scale, _seed * 100, 1.0, _octaves);
    var _noise_norm = (_noise + 1) * 0.5;
    
    var _range = lerp(_range_min, _range_max, _noise_norm);
    
    return _config.base_height + _range;
}

function worldgen_get_density(_x, _y, _z, _seed, _config = global.chunk_pool.worldgen_config)
{
    if (_config == undefined) return -1.0;
    
    // 1. Calculate 1D Surface Height
    var _surface_height = worldgen_get_surface_height(_x, _seed, global.world_data[$ global.world_save_data.dimension]);
    
    if (_y < _surface_height) return -1.0;
    
    // 2. Cave check (only for foreground/solid layer where z=0)
    if (_z == 0)
    {
        // Simple cave system: if noise > threshold, it's air
        // Using arbitrary hardcoded values for "basic" caves for now as user requested simplicity
        var _cave_noise = open_simplex_noise(_x * 0.02, _y * 0.02, _seed * 200, 2);
        if (_cave_noise > 0.4) return -1.0;
    }
    
    // 3. Return density gradient
    var _dist = _y - _surface_height;
    return 0.2 + (_dist * 0.1);
}

/// @desc Check if solid
function worldgen_is_solid(_x, _y, _seed, _config = global.chunk_pool.worldgen_config)
{
    return (worldgen_get_density(_x, _y, 0, _seed, _config) > 0);
}

/// @desc Check if wall
function worldgen_is_wall(_x, _y, _seed, _config = global.chunk_pool.worldgen_config)
{
    // Simplified wall check
    var _density = worldgen_get_density(_x, _y, _config.z_offset_wall, _seed, _config);
    return (_density > 0);
}

/// @desc Compatibility: Get solid density
function worldgen_get_density_solid(_x, _y, _seed, _config = global.chunk_pool.worldgen_config)
{
    return worldgen_get_density(_x, _y, 0, _seed, _config);
}

/// @desc Compatibility: Get wall density
function worldgen_get_density_wall(_x, _y, _seed, _config = global.chunk_pool.worldgen_config)
{
    return worldgen_get_density(_x, _y, _config.z_offset_wall, _seed, _config);
}

/// @desc Compatibility: Get material density
function worldgen_get_density_material(_x, _y, _seed, _config = global.chunk_pool.worldgen_config)
{
    return worldgen_get_density(_x, _y, _config.z_offset_material, _seed, _config);
}
