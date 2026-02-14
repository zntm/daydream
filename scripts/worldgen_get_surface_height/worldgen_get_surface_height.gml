/// @desc Get surface height at world x position (uniform across all biomes within a region, blended at edges)
/// @param {Real} _x World X position
/// @param {Real} _seed World seed
/// @param {Struct} _world_data World data struct
/// @returns {Real} Surface height (in tiles)
function worldgen_get_surface_height(_x, _seed, _world_data = global.world_data[$ global.world_save_data.dimension])
{
    var _surface_start = _world_data.get_surface_start();
    var _smoothing = _world_data.get_biome_transition_smoothing();
    
<<<<<<< HEAD
    // 2. Resolve surface biome at this position (for subtle modifiers)
    var _biome = _region.get_surface_biome(_x, 0, _seed);
    
    var _biome_offset = 0;
    var _biome_amp_scale = 1;
    
    if (_biome != undefined)
    {
        _biome_offset = _biome.get_terrain_height_offset();
        _biome_amp_scale = _biome.get_terrain_amplitude_scale();
    }
    else
    {
        show_debug_message($"[WorldGen] Warning: Surface biome undefined at x={_x}. Using defaults.");
    }
=======
    var _blend = _world_data.get_region_blend_data(_x, 0, _seed);
>>>>>>> region
    
    if (_blend == undefined) return _surface_start;
    
    var _h1 = _blend.r1.get_surface_height(_x, _seed);
    
    // Calculate blend factor (0.5 at edge, 1.0 at smoothing distance)
    var _factor = 0.5 + (_blend.diff / (2 * _smoothing));
    
    if (_factor >= 1.0)
    {
        return round(_surface_start + _h1);
    }
    
    var _h2 = _blend.r2.get_surface_height(_x, _seed);
    
    return round(_surface_start + lerp(_h2, _h1, _factor));
}