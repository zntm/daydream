function worldgen_get_biome_surface(_x, _y, _surface_height, _seed, _world_data = global.world_data[$ global.current_world.dimension], _slope = 0, _blend_data = undefined)
{
    var _blend = (_blend_data != undefined) ? _blend_data : _world_data.get_region_blend_data(_x, 0, _seed);
    
    if (_blend == undefined)
    {
        return undefined;
    }
    
    // Pick dominant region
    var _region = _blend.r1;
    
    return _region.get_surface_biome_id(_x, _surface_height, _seed, _slope);
}