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
    surface_noise_range_min = _world_data.get_surface_noise_offset_range_min();
    surface_noise_range_max = _world_data.get_surface_noise_offset_range_max();
    surface_noise_scale = _world_data.get_surface_noise_scale();
    
    // Z-offsets for wall and material layers
    z_offset_wall = _world_data.get_terrain_z_offset_wall();
    z_range_wall = _world_data.get_terrain_z_range_wall();
    z_offset_material = _world_data.get_terrain_z_offset_material();
}

function worldgen_get_density(_x, _y, _z, _seed, _config = global.chunk_pool.worldgen_config, _modifiers = undefined)
{
    if (_config == undefined) return -1.0;
    
    // 1. Calculate 1D Surface Height
    // Uses the pre-resolved noise settings from the config state
    var _noise = open_simplex_noise(_x * _config.surface_noise_scale, _seed * 100, 1.0, _config.surface_noise_octaves);
    var _noise_norm = (_noise + 1) * 0.5;
    var _offset = lerp(_config.surface_noise_range_min, _config.surface_noise_range_max, _noise_norm);
    var _surface_height = _config.base_height + _offset;
    
    if (_y < _surface_height) return -1.0;
    
    var _dist = _y - _surface_height;
    
    // 2. Cave check (only for foreground/solid layer where z=0)
    // Wall layers (z > 0) typically do not carve caves to provide background
    if (_z == 0)
    {
        if (worldgen_get_cave(_x, _y, _surface_height, 0, _seed)) return -1.0;
    }
    
    // 3. Return density gradient
    // 0.1 at surface, increasing with depth to allow crust/stone differentiation
    return 0.1 + (_dist * 0.2);
}

function worldgen_get_biome_modifiers(_x, _y, _seed)
{
    static _default_region_params = {
        height_offset: 0,
        base_height: 0,
        amplitude_min: 0,
        amplitude_max: 0
    };
    
    var _region_gen = global.region_generator;
    var _biome_data = global.biome_data;
    
    var _region = _region_gen.get_region(_x, _y, 0, _seed);
    var _biome = _biome_data[$ _region.get_surface_biome_id(_x, _y, _seed)];
    
    if (_biome == undefined)
    {
        return {
            erosion: 1.0,
            squash: 1.0,
            cave_density: 1.0,
            continentalness: 0.0,
            region_params: _default_region_params,
            region: _region,
            boundary_dist: 999
        };
    }
    
    var _smoothing = _biome.get_terrain_smoothing();
    var _influence = _biome.get_terrain_influence();
    
    var _erosion = lerp(1.0, _biome.get_erosion_modifier(), _influence);
    var _squash = lerp(1.0, _biome.get_squash_modifier(), _influence);
    var _cave_density = lerp(1.0, _biome.get_cave_density_modifier(), _influence);
    var _continentalness = _biome.get_continentalness_modifier() * _influence;
    
    if (_smoothing <= 0)
    {
        var _region_params = worldgen_get_region_parameters(_x, _y, _seed, 0, 0, 1.0, _region);
        
        return {
            erosion: _erosion,
            squash: _squash,
            cave_density: _cave_density,
            continentalness: _continentalness,
            region_params: _region_params,
            region: _region,
            boundary_dist: 999
        };
    }
    
    var _boundary_dist = _region_gen.get_boundary_distance(_x, _y, 0, _seed);
    var _blend_smooth = 1.0;
    
    if (_boundary_dist < _smoothing)
    {
        var _blend = _boundary_dist / _smoothing;
        _blend_smooth = _blend * _blend * (3 - 2 * _blend);
        
        _erosion = lerp(1.0, _erosion, _blend_smooth);
        _squash = lerp(1.0, _squash, _blend_smooth);
        _cave_density = lerp(1.0, _cave_density, _blend_smooth);
        _continentalness = lerp(0.0, _continentalness, _blend_smooth);
    }
    
    var _region_params = worldgen_get_region_parameters(_x, _y, _seed, _smoothing, _boundary_dist, _blend_smooth, _region);
    
    return {
        erosion: _erosion,
        squash: _squash,
        cave_density: _cave_density,
        continentalness: _continentalness,
        region_params: _region_params,
        region: _region,
        boundary_dist: _boundary_dist
    };
}

/// @desc Get blended region parameters
function worldgen_get_region_parameters(_x, _y, _seed, _smoothing = 0, _boundary_dist = 0, _blend = 0, _region = global.region_generator.get_region(_x, _y, 0, _seed))
{
    var _params = _region.get_terrain();
    
    var _height_offset = _params.height_offset;
    var _base_height = _params.base_height;
    var _amplitude_min = _params.amplitude_min;
    var _amplitude_max = _params.amplitude_max;
    
    if (_smoothing == 0)
    {
        var _region_blend_range = 64;
        
        _boundary_dist = global.region_generator.get_boundary_distance(_x, _y, 0, _seed);
        
        if (_boundary_dist < _region_blend_range)
        {
            var _t = _boundary_dist / _region_blend_range;
            
            _blend = _t * _t * (3 - 2 * _t);
        }
        else
        {
            _blend = 1.0;
        }
    }
    
    if (_blend < 1.0)
    {
        var _adj_region = global.region_generator.get_region(_x + 32, 0, 0, _seed);
        
        if (_adj_region != _region)
        {
            var _adj_params = _adj_region.get_terrain();
            
            _height_offset = lerp(_adj_params.height_offset, _height_offset, _blend);
        }
    }

    return {
        height_offset: _height_offset,
        base_height: _base_height,
        amplitude_min: _amplitude_min,
        amplitude_max: _amplitude_max
    }
}

/// @desc Evaluate surface height
function worldgen_get_surface_height_3d(_x, _seed, _config = global.chunk_pool.worldgen_config)
{
    var _min_y = _config.base_height - 400;
    var _max_y = _config.base_height + 400;
    
    repeat (12)
    {
        var _mid_y = (_min_y + _max_y) * 0.5;
        
        if (worldgen_get_density(_x, _mid_y, 0, _seed, _config) > 0)
        {
            _max_y = _mid_y;
        }
        else
        {
            _min_y = _mid_y;
        }
    }
    
    return floor((_min_y + _max_y) * 0.5);
}

/// @desc Check if solid
function worldgen_is_solid(_x, _y, _seed, _config = global.chunk_pool.worldgen_config, _modifiers = undefined)
{
    return (worldgen_get_density(_x, _y, 0, _seed, _config, _modifiers) > 0);
}

/// @desc Check if wall
function worldgen_is_wall(_x, _y, _seed, _config = global.chunk_pool.worldgen_config, _modifiers = undefined)
{
    var _z = _config.z_offset_wall;
    var _r = _config.z_range_wall;
    
    if (_r <= 0)
    {
        return (worldgen_get_density(_x, _y, _z, _seed, _config, _modifiers) > 0);
    }
    
    return max(
        worldgen_get_density(_x, _y, _z - _r, _seed, _config, _modifiers),
        worldgen_get_density(_x, _y, _z, _seed, _config, _modifiers),
        worldgen_get_density(_x, _y, _z + _r, _seed, _config, _modifiers)
    ) > 0;
}

/// @desc Compatibility: Get solid density
function worldgen_get_density_solid(_x, _y, _seed, _config = global.chunk_pool.worldgen_config, _modifiers = undefined)
{
    return worldgen_get_density(_x, _y, 0, _seed, _config, _modifiers);
}

/// @desc Compatibility: Get wall density
function worldgen_get_density_wall(_x, _y, _seed, _config = global.chunk_pool.worldgen_config, _modifiers = undefined)
{
    var _z = _config.z_offset_wall;
    var _r = _config.z_range_wall;
    
    if (_r <= 0) return worldgen_get_density(_x, _y, _z, _seed, _config, _modifiers);
    
    return max(
        worldgen_get_density(_x, _y, _z - _r, _seed, _config, _modifiers),
        worldgen_get_density(_x, _y, _z, _seed, _config, _modifiers),
        worldgen_get_density(_x, _y, _z + _r, _seed, _config, _modifiers)
    );
}

/// @desc Compatibility: Get material density
function worldgen_get_density_material(_x, _y, _seed, _config = global.chunk_pool.worldgen_config, _modifiers = undefined)
{
    return worldgen_get_density(_x, _y, _config.z_offset_material, _seed, _config, _modifiers);
}
