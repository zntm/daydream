function worldgen_get_biome_cave(_x, _y, _surface_height, _seed, _world_data = global.world_data[$ global.current_world.dimension])
{
    var _blend = _world_data.get_region_blend_data(_x, 0, _seed);
    if (_blend == undefined) return undefined;
    
    var _depth = _y - _surface_height;
    if (_depth <= 8) return undefined;
    
    var _region = _blend.r1;
    
    // Assuming default layer (1) for main cave generation
    return _region.get_cave_biome_id(_x, _y, 1, _depth, _seed);
}