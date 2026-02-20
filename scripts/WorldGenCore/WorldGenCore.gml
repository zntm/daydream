/// @desc WorldGenState - Pre-resolved configuration for world generation
/// Stores flattened parameters for fast access during density evaluation.
/// @param {Struct.WorldData} _world_data
function WorldGenState(_world_data) constructor
{
    // Flattened parameters for fast access
    base_height = 0; 
    surface_noise_octaves = 4;
    surface_noise_scale = 0.01;
}


function worldgen_get_density(_x, _y, _z, _seed, _config = global.chunk_pool.worldgen_config, _surface_height = undefined)
{
    if (_config == undefined) return -1.0;
    
    // 1. Calculate 1D Surface Height (bypass if provided)
    _surface_height ??= worldgen_get_surface_height(_x, _seed, global.world_data[$ global.current_world.dimension]);
    
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
function worldgen_is_solid(_x, _y, _seed, _config = global.chunk_pool.worldgen_config, _surface_height = undefined)
{
    return (worldgen_get_density(_x, _y, 0, _seed, _config, _surface_height) > 0);
}
