/// @desc Functional Region Generator
/// @description Selects regions via a pre-built 64x64 climate map.
///              Heat + humidity noise values [0, 63] index directly into the map.
///              The map is built from a painted region sprite (indexed by climate)
///              or from region heat/humidity targets as a fallback.

#macro REGION_MAP_SIZE 64

/// @desc Create a region generator config struct
/// @param {Struct} _config Configuration
/// @returns {Struct} Generator config
function region_gen_create(_config = {})
{
    var _regions     = _config[$ "regions"] ?? [];
    var _region_count = array_length(_regions);

    /* build color lookup table for map-based regions */
    var _color_lookup = {}

    for (var i = _region_count - 1; i >= 0; --i)
    {
        var _r     = _regions[i];
        var _color = _r.get_map_color();

        _color_lookup[$ string(_color)] = i;
    }

    /* pre-build 64x64 region map */
    var _map_total  = REGION_MAP_SIZE * REGION_MAP_SIZE;
    var _region_map = array_create(_map_total, 0);
    var _map_buffer = _config[$ "map_buffer"];
    var _map_width  = _config[$ "map_width"] ?? 0;
    var _map_height = _config[$ "map_height"] ?? 0;

    if (_region_count > 0)
    {
        if (_map_buffer != undefined) && (_map_width > 0) && (_map_height > 0)
        {
            /* build from the painted region sprite — heat = row, humidity = column */
            for (var _h = REGION_MAP_SIZE - 1; _h >= 0; --_h)
            {
                var _py = clamp(floor(_h / (REGION_MAP_SIZE - 1) * (_map_height - 1)), 0, _map_height - 1);

                for (var _w = REGION_MAP_SIZE - 1; _w >= 0; --_w)
                {
                    var _px = clamp(floor(_w / (REGION_MAP_SIZE - 1) * (_map_width - 1)), 0, _map_width - 1);

                    buffer_seek(_map_buffer, buffer_seek_start, (_py * _map_width + _px) * 4);

                    var _colour = buffer_read(_map_buffer, buffer_u32) & 0xffffff;
                    var _idx    = _color_lookup[$ string(_colour)];

                    _region_map[@ _h * REGION_MAP_SIZE + _w] = (_idx != undefined) ? _idx : 0;
                }
            }
        }
        else
        {
            /* fallback: build from heat/humidity targets (voronoi) */
            for (var _h = REGION_MAP_SIZE - 1; _h >= 0; --_h)
            {
                for (var _w = REGION_MAP_SIZE - 1; _w >= 0; --_w)
                {
                    var _best_score = infinity;
                    var _best_id    = 0;

                    for (var i = _region_count - 1; i >= 0; --i)
                    {
                        var _region = _regions[i];
                        var _dh    = _h - _region.get_heat_target();
                        var _dw    = _w - _region.get_humidity_target();
                        var _score = _dh * _dh + _dw * _dw;

                        if (_score < _best_score)
                        {
                            _best_score = _score;
                            _best_id    = i;
                        }
                    }

                    _region_map[@ _h * REGION_MAP_SIZE + _w] = _best_id;
                }
            }
        }
    }

    return {
        regions: _regions,
        region_count: _region_count,
        region_map: _region_map,
        warp_scale: _config[$ "warp_scale"] ?? 0.0015,
        warp_power: _config[$ "warp_power"] ?? 384,
        climate_scale: _config[$ "climate_scale"] ?? 0.0003,
        color_lookup: _color_lookup,
    }
}

#region --- Domain Warping ---

/// @desc Apply domain warping to a position
/// @returns {Array<Real>} [warped_x, warped_y]
function region_gen_warp(_gen, _x, _y)
{
    var _ws = _gen.warp_scale;
    var _wp = _gen.warp_power;

    var _warp_x = (open_simplex_noise(_x * _ws, _y * _ws, 1.0, 2) - 0.5) * _wp;
    var _warp_y = (open_simplex_noise(_x * _ws + 1000, _y * _ws + 1000, 1.0, 2) - 0.5) * _wp;

    return [_x + _warp_x, _y + _warp_y];
}

#endregion

#region --- Climate Sampling ---

/// @desc Sample region-level heat at a position
///       Per-world variation is handled by open_simplex_noise_seed().
/// @param {Real} _x World X
/// @param {Real} _y World Y
/// @param {Real} _scale Climate noise scale
/// @returns {Real} Heat value [0, 63]
function region_gen_sample_heat(_x, _y, _scale)
{
    return floor(open_simplex_noise(
        _x * _scale,
        _y * _scale + 2048,
        63, 4
    ));
}

/// @desc Sample region-level humidity at a position
/// @param {Real} _x World X
/// @param {Real} _y World Y
/// @param {Real} _scale Climate noise scale
/// @returns {Real} Humidity value [0, 63]
function region_gen_sample_humidity(_x, _y, _scale)
{
    return floor(open_simplex_noise(
        _x * _scale,
        _y * _scale + 2048 + 32,
        63, 4
    ));
}

/// @desc Pick the best-matching region index via the pre-built region map
/// @param {Struct} _gen Generator config
/// @param {Real} _heat Heat value [0, 63]
/// @param {Real} _humid Humidity value [0, 63]
/// @returns {Real} Region index
function region_gen_climate_pick(_gen, _heat, _humid)
{
    return _gen.region_map[_heat * REGION_MAP_SIZE + _humid];
}

/// @desc Pick the two best-matching regions for transition blending
/// @param {Struct} _gen Generator config
/// @param {Real} _heat Heat value [0, 63]
/// @param {Real} _humid Humidity value [0, 63]
/// @returns {Array} [best_index, second_index, blend_factor]
function region_gen_climate_pick_two(_gen, _heat, _humid)
{
    var _map    = _gen.region_map;
    var _best   = _map[_heat * REGION_MAP_SIZE + _humid];
    var _second = _best;
    var _min_dist = infinity;

    /* search a small neighborhood for the nearest different-region cell */
    var _radius = 4;

    for (var _dh = -_radius; _dh <= _radius; ++_dh)
    {
        var _sh = _heat + _dh;

        if (_sh < 0) || (_sh >= REGION_MAP_SIZE) continue;

        for (var _dw = -_radius; _dw <= _radius; ++_dw)
        {
            if (_dh == 0) && (_dw == 0) continue;

            var _sw = _humid + _dw;

            if (_sw < 0) || (_sw >= REGION_MAP_SIZE) continue;

            var _neighbor = _map[_sh * REGION_MAP_SIZE + _sw];

            if (_neighbor != _best)
            {
                var _d = _dh * _dh + _dw * _dw;

                if (_d < _min_dist)
                {
                    _min_dist = _d;
                    _second   = _neighbor;
                }
            }
        }
    }

    /* blend factor: 0 = right on the boundary, higher = deeper inside the region */
    var _blend = (_second == _best) ? 1000 : sqrt(_min_dist);

    return [_best, _second, _blend];
}

#endregion

#region --- Main Lookup Functions ---

/// @desc Get region at world position
/// @param {Struct} _gen Generator config
/// @param {Real} _x World X
/// @param {Real} _y World Y
/// @param {Real} _seed World seed (unused, kept for API compatibility)
/// @returns {Struct} RegionData struct
function region_gen_get_region(_gen, _x, _y, _seed)
{
    if (_gen.region_count <= 0) return undefined;

    /* domain-warp then sample climate */
    var _warped = region_gen_warp(_gen, _x, _y);

    var _heat  = region_gen_sample_heat(_warped[0], _warped[1], _gen.climate_scale);
    var _humid = region_gen_sample_humidity(_warped[0], _warped[1], _gen.climate_scale);
    var _rid   = region_gen_climate_pick(_gen, _heat, _humid);

    return _gen.regions[_rid];
}

/// @desc Get blend data between the two closest-matching regions
/// @param {Struct} _gen Generator config
/// @param {Real} _x World X
/// @param {Real} _y World Y
/// @param {Real} _seed World seed (unused, kept for API compatibility)
/// @returns {Struct} { r1, r2, diff }
function region_gen_get_blend_data(_gen, _x, _y, _seed)
{
    if (_gen.region_count <= 0) return undefined;

    /* domain-warp then sample climate */
    var _warped = region_gen_warp(_gen, _x, _y);

    var _heat  = region_gen_sample_heat(_warped[0], _warped[1], _gen.climate_scale);
    var _humid = region_gen_sample_humidity(_warped[0], _warped[1], _gen.climate_scale);
    var _pick  = region_gen_climate_pick_two(_gen, _heat, _humid);

    var _rc = _gen.region_count;
    var _r1 = _gen.regions[clamp(_pick[0], 0, _rc - 1)];
    var _r2 = _gen.regions[clamp(_pick[1], 0, _rc - 1)];

    return {
        r1: _r1,
        r2: _r2,
        diff: _pick[2],
    }
}

/// @desc Get distance to nearest region boundary (for transition blending)
/// @param {Struct} _gen Generator config
/// @param {Real} _x World X
/// @param {Real} _y World Y
/// @param {Real} _seed World seed (unused, kept for API compatibility)
/// @returns {Real} Boundary distance (cells to nearest different region)
function region_gen_get_boundary_distance(_gen, _x, _y, _seed)
{
    if (_gen.region_count <= 1) return 1000;

    /* domain-warp then sample climate */
    var _warped = region_gen_warp(_gen, _x, _y);

    var _heat  = region_gen_sample_heat(_warped[0], _warped[1], _gen.climate_scale);
    var _humid = region_gen_sample_humidity(_warped[0], _warped[1], _gen.climate_scale);
    var _pick  = region_gen_climate_pick_two(_gen, _heat, _humid);

    return _pick[2];
}

#endregion
