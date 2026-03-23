function tile_predict(_x, _y, _z)
{
    static __structure_sort = function(_a, _b)
    {
        return ((_a.x * 0xffff) + _a.y) - ((_b.x * 0xffff) + _b.y);
    }

    static __make_tile = function(_tile_id, _item_data)
    {
        if (_tile_id == TILE_EMPTY) return TILE_EMPTY;

        var _d = _item_data[$ _tile_id];
        if (_d == undefined) return TILE_EMPTY;

        return new Tile(_tile_id)
            .set_index(smart_value(_d.get_placement_index()))
            .set_index_offset(smart_value(_d.get_placement_index_offset()));
    }

    var _current_world = global.current_world;
    var _world_seed = _current_world.seed;
    var _world_data = global.world_data[$ _current_world.dimension];
    var _item_data = global.item_data;
    var _global_biome_data = global.biome_data;
    var _world_height = _world_data.get_world_height();
    var _sky_threshold = _world_data.get_sky_biome_threshold();
    var _sky_enabled = _world_data.is_sky_biome_enabled();

    var _skip_z = 0;
    var _structure_tile = TILE_STRUCTURE_VOID;
    var _structures = global.structure_pool.query_range(_x, _y, _x + 1, _y + 1);
    var _structures_length = array_length(_structures);

    if (_structures_length > 0)
    {
        array_sort(_structures, __structure_sort);

        for (var i = 0; i < _structures_length; ++i)
        {
            var _inst = _structures[i];

            if (_inst.data == undefined)
            {
                structure_generate(_inst, _world_seed, _item_data, global.structure_data, global.natural_structure_data);
            }

            var _width = _inst.width;
            var _height = _inst.height;
            var _rectangle = _width * _height;

            var _sx = _x - _inst.x;
            var _sy = _y - _inst.y;

            if (_sx < 0 || _sx >= _width || _sy < 0 || _sy >= _height) continue;

            var _structure_index = _sx + (_sy * _width);

            for (var m = CHUNK_DEPTH - 1; m >= 0; --m)
            {
                var _tile = _inst.data[_structure_index + (m * _rectangle)];
                if (_tile == TILE_STRUCTURE_VOID) continue;

                var _mask = (1 << m) & ((1 << CHUNK_DEPTH_DEFAULT) | (1 << CHUNK_DEPTH_FOLIAGE_BACK) | (1 << CHUNK_DEPTH_FOLIAGE_FRONT));
                if (_mask) _skip_z |= (1 << CHUNK_DEPTH_DEFAULT) | (1 << CHUNK_DEPTH_FOLIAGE_BACK) | (1 << CHUNK_DEPTH_FOLIAGE_FRONT);
                else _skip_z |= 1 << m;

                if (m == _z)
                {
                    _structure_tile = _tile;
                }
            }
        }
    }

    if (_structure_tile != TILE_STRUCTURE_VOID)
    {
        return _structure_tile;
    }

    if (_skip_z & (1 << _z))
    {
        return TILE_EMPTY;
    }

    var _blend_data = _world_data.get_region_blend_data(_x, 0, _world_seed);
    var _surface_height = worldgen_get_surface_height(_x, _world_seed, _world_data, _blend_data);
    var _world_surface_start = _world_data.get_surface_start();

    var _chunk_ystart = floor(_y / CHUNK_SIZE) * CHUNK_SIZE;
    var _chunk_local_y = _y - _chunk_ystart;

    var _cave_bit_stream = 0;
    var _sky_bit_stream = 0;
    var _cave_start = worldgen_get_cave_start(_x, _world_seed, _world_data);
    var _cave_below = worldgen_get_cave(_x, _surface_height + 2, _surface_height, _cave_start, _world_seed, _world_data);

    for (var j = 0; j < CHUNK_SIZE + 2; ++j)
    {
        var _world_y = _chunk_ystart + j - 1;

        _cave_bit_stream |= worldgen_get_cave(_x, _world_y, _surface_height, _cave_start, _world_seed, _world_data, _cave_below) << j;

        if (_sky_enabled && _world_y <= _sky_threshold)
        {
            if (worldgen_get_sky_island(_x, _world_y, _world_seed, _world_data))
            {
                _sky_bit_stream |= 1 << j;
            }
        }
    }

    var _h_left = worldgen_get_surface_height(_x - 1, _world_seed, _world_data);
    var _h_right = worldgen_get_surface_height(_x + 1, _world_seed, _world_data);
    var _slope = max(abs(_surface_height - _h_left), abs(_h_right - _surface_height));

    var _surface_biome = worldgen_get_biome_surface(_x, _surface_height, _surface_height, _world_seed, _world_data, _slope, _blend_data);
    var _surface_biome_data = _global_biome_data[$ worldgen_resolve_id(_surface_biome)];

    if ((_z == CHUNK_DEPTH_DEFAULT) && (_y <= _sky_threshold) && _sky_enabled)
    {
        if ((_sky_bit_stream >> (_chunk_local_y + 1)) & 1)
        {
            var _sky_biome_data = _global_biome_data[$ _world_data.get_sky_biome_id()];

            if (_sky_biome_data != undefined)
            {
                var _is_above = (_sky_bit_stream >> _chunk_local_y) & 1;
                var _is_below = (_sky_bit_stream >> (_chunk_local_y + 2)) & 1;
                var _tile_seed = abs(_x * 73856093) ^ abs(_y * 19349663) ^ _world_seed;
                var _tile_id = (!_is_above ? _sky_biome_data.get_tile_top_layer_base(_tile_seed) :
                               (!_is_below ? _sky_biome_data.get_tile_bottom_layer_base(_tile_seed) :
                               _sky_biome_data.get_tile_middle_layer_base(_tile_seed)));

                var _sky_tile = __make_tile(_tile_id, _item_data);
                if (_sky_tile != TILE_EMPTY) return _sky_tile;
            }
        }
    }

    if (_z == CHUNK_DEPTH_LIQUID)
    {
        if ((_surface_biome_data != undefined) && (_y < _surface_height) && (_y >= _world_surface_start) && (_surface_biome_data.is_ocean()))
        {
            var _water_id = "phantasia:water";
            if (_item_data[$ _water_id] != undefined)
            {
                return new Tile(_water_id).set_component("level", 8);
            }
        }
    }

    if (_y >= _surface_height - 1)
    {
        var _cave_biome = worldgen_get_biome_cave(_x, _y, _surface_height, _world_seed, _world_data, _blend_data);
        var _is_cave = (_cave_bit_stream >> (_chunk_local_y + 1)) & 1;

        if ((_z == CHUNK_DEPTH_DEFAULT) && !_is_cave && (_y >= _surface_height))
        {
            var _tile_base = worldgen_get_tile_base(_x, _y, _surface_biome, _cave_biome, _surface_height, (_cave_bit_stream >> _chunk_local_y) & 1, _world_seed, _world_data, _global_biome_data);
            var _base_tile = __make_tile(_tile_base, _item_data);
            if (_base_tile != TILE_EMPTY) return _base_tile;
        }

        if ((_z == CHUNK_DEPTH_WALL) && (_y >= _surface_height))
        {
            var _tile_wall = worldgen_get_tile_wall(_x, _y, _surface_biome, _cave_biome, _surface_height, _world_seed, _world_data, _global_biome_data);
            var _wall_tile = __make_tile(_tile_wall, _item_data);
            if (_wall_tile != TILE_EMPTY) return _wall_tile;
        }

        if ((_z == CHUNK_DEPTH_LIQUID) && _is_cave)
        {
            var _aquifer = worldgen_get_aquifer(_x, _y, _surface_height, _world_seed, _world_data);
            if (_aquifer != undefined)
            {
                if (_item_data[$ _aquifer.type] != undefined)
                {
                    return new Tile(_aquifer.type).set_component("level", _aquifer.fill_level);
                }
            }

            if ((_world_height - _y <= 32) && (_world_height - _y > 3))
            {
                var _lava_id = "phantasia:lava";
                if (_item_data[$ _lava_id] != undefined)
                {
                    return new Tile(_lava_id).set_component("level", 8);
                }
            }
        }

        var _xorshift_val = xorshift(_world_seed ^ ((_x + _chunk_ystart) * _surface_height));
        var _foliage_layer = ((_xorshift_val & (1 << _chunk_local_y)) ? CHUNK_DEPTH_FOLIAGE_FRONT : CHUNK_DEPTH_FOLIAGE_BACK);

        if (_z == _foliage_layer)
        {
            var _is_floor = _is_cave && !((_cave_bit_stream >> (_chunk_local_y + 2)) & 1);

            if (_is_floor)
            {
                var _tile_next = worldgen_get_tile_base(_x, _y + 1, _surface_biome, _cave_biome, _surface_height, true, _world_seed, _world_data, _global_biome_data);
                var _foliage_id = worldgen_get_tile_foliage(_x, _y, _surface_biome, _cave_biome, _tile_next, _surface_height, _world_seed, _global_biome_data);

                if (_foliage_id != TILE_EMPTY)
                {
                    var _d = _item_data[$ _foliage_id];
                    if (_d != undefined)
                    {
                        var _flip = ((_d.can_flip_on_x()) && (_xorshift_val & (1 << (CHUNK_SIZE + _chunk_local_y)))) ? -1 : 1;
                        return new Tile(_foliage_id)
                            .set_xscale(_flip)
                            .set_index(smart_value(_d.get_placement_index()))
                            .set_index_offset(smart_value(_d.get_placement_index_offset()));
                    }
                }
            }
        }
    }

    return TILE_EMPTY;
}
