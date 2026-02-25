function worldgen_get_biome_cave(_x, _y, _surface_height, _seed, _world_data = global.world_data[$ global.current_world.dimension])
{
    var _depth = _y - _surface_height;
    if (_depth <= 8) return undefined;

    /* check special cave regions first */
    var _special = worldgen_get_special_cave_region(_x, _y, _depth, _seed);
    if (_special != undefined) return _special;

    var _blend = _world_data.get_region_blend_data(_x, 0, _seed);
    if (_blend == undefined) return undefined;

    var _region = _blend.r1;

    return _region.get_cave_biome_id(_x, _y, 1, _depth, _seed);
}