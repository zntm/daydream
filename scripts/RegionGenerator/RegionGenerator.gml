/// @desc Functional Region Generator
/// @description Selects regions via domain-warped simplex noise climate matching.
///              Samples heat + humidity at each position, picks the closest region.
///              Supports optional map buffer override for hand-painted region maps.

/// @desc Create a region generator config struct
/// @param {Struct} _config Configuration
/// @returns {Struct} Generator config
function region_gen_create(_config = {})
{
    var _regions = _config[$ "regions"] ?? [];
    var _region_count = array_length(_regions);

    /* build color lookup table for map-based regions */
    var _color_lookup = {}
    for (var i = 0; i < _region_count; ++i)
    {
        var _r = _regions[i];
        var _color = _r.get_map_color();
        _color_lookup[$ string(_color)] = _r;
    }
    
    return {
        regions: _regions,
        region_count: _region_count,
        warp_scale: _config[$ "warp_scale"] ?? 0.0015,
        warp_power: _config[$ "warp_power"] ?? 384,
        climate_scale: _config[$ "climate_scale"] ?? 0.0003,
        map_buffer: _config[$ "map_buffer"],
        map_width: _config[$ "map_width"] ?? 0,
        map_height: _config[$ "map_height"] ?? 0,
        map_cell_size: _config[$ "map_cell_size"] ?? 2048,
        color_lookup: _color_lookup,
    }
}

#region --- Map Buffer Lookup ---

/// @desc Try to get a region from a painted map buffer
/// @param {Struct} _gen Generator config
/// @param {Real} _x World X
/// @param {Real} _y World Y
/// @returns {Struct|undefined} RegionData or undefined
function region_gen_map_lookup(_gen, _x, _y)
{
    if (_gen.map_buffer == undefined)
    {
        return undefined;
    }
    
    var _px = clamp(floor(_x / _gen.map_cell_size), 0, _gen.map_width - 1);
    var _py = clamp(floor(_y / _gen.map_cell_size), 0, _gen.map_height - 1);
    
    var _buffer = _gen.map_buffer;
    
    buffer_seek(_buffer, buffer_seek_start, ((_py * _gen.map_width) + _px) * 4);
    
    var _colour = buffer_read(_buffer, buffer_u32) & 0xffffff;
    
    return _gen.color_lookup[$ string(_colour)];
}

#endregion

#region --- Domain Warping ---

/// @desc Apply domain warping to a position
/// @returns {Array<Real>} [warped_x, warped_y]
function region_gen_warp(_gen, _x, _y)
{
    var _ws = _gen.warp_scale;
    var _wp = _gen.warp_power;
    
    var _warp_x = open_simplex_noise(_x * _ws, _y * _ws, 1.0, 2) * _wp;
    var _warp_y = open_simplex_noise(_x * _ws + 1000, _y * _ws + 1000, 1.0, 2) * _wp;
    
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

/// @desc Pick the best-matching region index for a climate point
/// @param {Struct} _gen Generator config
/// @param {Real} _heat Heat value
/// @param {Real} _humid Humidity value
/// @returns {Real} Region index
function region_gen_climate_pick(_gen, _heat, _humid)
{
    var _best_score = infinity;
    var _best_id = 0;

    for (var i = _gen.region_count - 1; i >= 0; --i)
    {
        var _region = _gen.regions[i];
        var _th = _region.get_heat_target();
        var _tw = _region.get_humidity_target();
        
        var _dh = _heat - _th;
        var _dw = _humid - _tw; 
        var _score = _dh * _dh + _dw * _dw;
        
        if (_score < _best_score)
        {
            _best_score = _score;
            _best_id = i;
        }
    }

    return _best_id;
}

/// @desc Pick the two best-matching regions and their score difference
/// @param {Struct} _gen Generator config
/// @param {Real} _heat Heat value
/// @param {Real} _humid Humidity value
/// @returns {Array} [best_index, second_index, best_score, second_score]
function region_gen_climate_pick_two(_gen, _heat, _humid)
{
    var _best_score  = infinity;
    var _second_score = infinity;
    var _best_id   = 0;
    var _second_id = 0;

    for (var i = _gen.region_count - 1; i >= 0; --i)
    {
        var _region = _gen.regions[i];
        var _dh = _heat - _region.get_heat_target();
        var _dw = _humid - _region.get_humidity_target();
        var _score = _dh * _dh + _dw * _dw;

        if (_score < _best_score)
        {
            _second_score = _best_score;
            _second_id    = _best_id;
            _best_score   = _score;
            _best_id      = i;
        }
        else if (_score < _second_score)
        {
            _second_score = _score;
            _second_id    = i;
        }
    }

    return [_best_id, _second_id, _best_score, _second_score];
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
    var _map_region = region_gen_map_lookup(_gen, _x, _y);
    if (_map_region != undefined) return _map_region;

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
    /* map override — no blending */
    var _map_region = region_gen_map_lookup(_gen, _x, _y);
    if (_map_region != undefined)
    {
        return { r1: _map_region, r2: _map_region, diff: 1000 }
    }

    if (_gen.region_count <= 0) return undefined;

    /* domain-warp then sample climate */
    var _warped = region_gen_warp(_gen, _x, _y);

    var _heat  = region_gen_sample_heat(_warped[0], _warped[1], _gen.climate_scale);
    var _humid = region_gen_sample_humidity(_warped[0], _warped[1], _gen.climate_scale);
    var _pick  = region_gen_climate_pick_two(_gen, _heat, _humid);

    var _rc = _gen.region_count;
    var _r1 = _gen.regions[clamp(_pick[0], 0, _rc - 1)];
    var _r2 = _gen.regions[clamp(_pick[1], 0, _rc - 1)];

    /* diff = euclidean distance difference between the two closest regions */
    return {
        r1: _r1,
        r2: _r2,
        diff: sqrt(_pick[3]) - sqrt(_pick[2]),
    }
}

/// @desc Get distance to nearest region boundary (for transition blending)
/// @param {Struct} _gen Generator config
/// @param {Real} _x World X
/// @param {Real} _y World Y
/// @param {Real} _seed World seed (unused, kept for API compatibility)
/// @returns {Real} Boundary distance (climate score difference)
function region_gen_get_boundary_distance(_gen, _x, _y, _seed)
{
    if (_gen.map_buffer != undefined) return 1000;
    if (_gen.region_count <= 1) return 1000;

    /* domain-warp then sample climate */
    var _warped = region_gen_warp(_gen, _x, _y);

    var _heat  = region_gen_sample_heat(_warped[0], _warped[1], _gen.climate_scale);
    var _humid = region_gen_sample_humidity(_warped[0], _warped[1], _gen.climate_scale);
    var _pick  = region_gen_climate_pick_two(_gen, _heat, _humid);

    return (sqrt(_pick[3]) - sqrt(_pick[2])) / 2.0;
}

#endregion
