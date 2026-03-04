/// @desc Functional Region Generator
/// @description Selects regions via domain-warped Voronoi cells + heat/humidity climate matching.
///              Supports optional map buffer override for hand-painted region maps.

/// @desc Create a region generator config struct
/// @param {Struct} _config Configuration
/// @returns {Struct} Generator config
function region_gen_create(_config = {})
{
    var _regions = _config[$ "regions"] ?? [];
    var _region_count = array_length(_regions);

    // Build color lookup table for map-based regions
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
        cell_size: _config[$ "cell_size"] ?? 2048,
        warp_scale: _config[$ "warp_scale"] ?? 0.0015,
        warp_power: _config[$ "warp_power"] ?? 384,
        seed_offset: _config[$ "seed_offset"] ?? 12345,
        climate_scale: _config[$ "climate_scale"] ?? 0.0003,
        map_buffer: _config[$ "map_buffer"],
        map_width: _config[$ "map_width"] ?? 0,
        map_height: _config[$ "map_height"] ?? 0,
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
    
    var _px = clamp(floor(_x / _gen.cell_size), 0, _gen.map_width - 1);
    var _py = clamp(floor(_y / _gen.cell_size), 0, _gen.map_height - 1);
    
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

#region --- Climate-Based Region Selection ---

/// @desc Sample region-level heat at a position
/// @desc Uses a MUCH coarser noise scale than worldgen_get_heat (per-tile = 0.005).
///       Region climate varies slowly — smooth zones spanning many Voronoi cells.
/// @param {Real} _x World X
/// @param {Real} _y World Y (unused, kept for API consistency)
/// @param {Real} _seed World seed
/// @param {Real} _scale Climate noise scale
/// @returns {Real} Heat value (-1 to 1)
function region_gen_sample_heat(_x, _y, _seed, _scale)
{
    return clamp(open_simplex_noise(
        _x * _scale + (_seed * 0.001),
        _y * _scale + 2048,
        63, 4
    ), 0, 63);
}

/// @desc Sample region-level humidity at a position
/// @returns {Real} Humidity value (-1 to 1)
function region_gen_sample_humidity(_x, _y, _seed, _scale)
{
    return clamp(open_simplex_noise(
        _x * _scale + (_seed * 0.001),
        _y * _scale + 2048 + 32,
        63, 4
    ), 0, 63);
}

/// @desc Pick the best-matching region for a climate point
/// @param {Struct} _gen Generator config
/// @param {Real} _heat Heat value (-1 to 1)
/// @param {Real} _humid Humidity value (-1 to 1)
/// @returns {Real} Region index
function region_gen_climate_pick(_gen, _heat, _humid)
{
    var _best_score = infinity;
    var _best_id = 0;

    // PRINT($"region_gen_climate_pick: heat={_heat}, humid={_humid}");

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

#endregion

#region --- Voronoi Cell Helpers ---

/// @desc Calculate a deterministic cell seed
function __region_cell_seed(_cx, _cy, _seed_offset)
{
    return abs(_cx * 73856093) ^ abs(_cy * 19349663) ^ _seed_offset;
}

/// @desc Calculate a deterministic jittered cell center point
/// @returns {Array<Real>} [point_x, point_y]
function __region_cell_point(_cx, _cy, _cell_size, _cell_seed)
{
    var _jx = frac(sin(_cell_seed * 0.0001) * 43758.5453) * 0.8 + 0.1;
    var _jy = frac(sin(_cell_seed * 0.0002) * 22578.1459) * 0.8 + 0.1;
    
    return [(_cx + _jx) * _cell_size, (_cy + _jy) * _cell_size];
}

#endregion

#region --- Main Lookup Functions ---

/// @desc Get region at world position
/// @param {Struct} _gen Generator config
/// @param {Real} _x World X
/// @param {Real} _y World Y
/// @param {Real} _seed World seed
/// @returns {Struct} RegionData struct
function region_gen_get_region(_gen, _x, _y, _seed)
{
    // 1. Map override
    var _map_region = region_gen_map_lookup(_gen, _x, _y);
    if (_map_region != undefined) return _map_region;

    // 2. Domain-warped Voronoi + climate
    var _warped = region_gen_warp(_gen, _x, _y);
    var _wx = _warped[0];
    var _wy = _warped[1];

    PRINT($"region_gen_get_region: x={_x}, y={_y} -> wx={_wx}, wy={_wy}");

    var _cs = _gen.cell_size;
    var _so = _seed + _gen.seed_offset;
    var _cx0 = floor(_wx / _cs);
    var _cy0 = floor(_wy / _cs);

    var _best_dist = infinity;
    var _best_region_id = 0;

    for (var _cx = _cx0 - 1; _cx <= _cx0 + 1; ++_cx)
    {
        for (var _cy = _cy0 - 1; _cy <= _cy0 + 1; ++_cy)
        {
            var _cseed = __region_cell_seed(_cx, _cy, _so);
            var _pt = __region_cell_point(_cx, _cy, _cs, _cseed);

            var _dx = _wx - _pt[0];
            var _dy = _wy - _pt[1];
            var _dist_sq = _dx * _dx + _dy * _dy;

            if (_dist_sq < _best_dist)
            {
                _best_dist = _dist_sq;

                // Climate selection at cell center (using region-level coarse noise)
                var _heat = region_gen_sample_heat(_pt[0], _pt[1], _seed, _gen.climate_scale);
                var _humid = region_gen_sample_humidity(_pt[0], _pt[1], _seed, _gen.climate_scale);
                _best_region_id = region_gen_climate_pick(_gen, _heat, _humid);
                
                var _r = _gen.regions[clamp(_best_region_id, 0, _gen.region_count - 1)];
                PRINT($"  New best cell: cx={_cx}, cy={_cy}, heat={_heat}, humid={_humid} -> region='{_r.get_id()}'");
            }
        }
    }

    if (_gen.region_count <= 0) return undefined;
    return _gen.regions[clamp(_best_region_id, 0, _gen.region_count - 1)];
}

/// @desc Get blend data between the two nearest Voronoi cells
/// @param {Struct} _gen Generator config
/// @param {Real} _x World X
/// @param {Real} _y World Y
/// @param {Real} _seed World seed
/// @returns {Struct} { r1, r2, diff }
function region_gen_get_blend_data(_gen, _x, _y, _seed)
{
    // Map override — no blending
    var _map_region = region_gen_map_lookup(_gen, _x, _y);
    if (_map_region != undefined)
    {
        return { r1: _map_region, r2: _map_region, diff: 1000 }
    }

    var _warped = region_gen_warp(_gen, _x, _y);
    var _wx = _warped[0];
    var _wy = _warped[1];

    var _cs = _gen.cell_size;
    var _so = _seed + _gen.seed_offset;
    var _cx0 = floor(_wx / _cs);
    var _cy0 = floor(_wy / _cs);

    var _best_dist = infinity;
    var _second_dist = infinity;
    var _best_region_id = 0;
    var _second_region_id = 0;

    for (var _cx = _cx0 - 1; _cx <= _cx0 + 1; _cx++)
    {
        for (var _cy = _cy0 - 1; _cy <= _cy0 + 1; _cy++)
        {
            var _cseed = __region_cell_seed(_cx, _cy, _so);
            var _pt = __region_cell_point(_cx, _cy, _cs, _cseed);

            var _dx = _wx - _pt[0];
            var _dy = _wy - _pt[1];
            var _dist = sqrt(_dx * _dx + _dy * _dy);

            // Climate-based region pick for this cell (using region-level coarse noise)
            var _heat = region_gen_sample_heat(_pt[0], _pt[1], _seed, _gen.climate_scale);
            var _humid = region_gen_sample_humidity(_pt[0], _pt[1], _seed, _gen.climate_scale);
            var _rid = region_gen_climate_pick(_gen, _heat, _humid);

            if (_dist < _best_dist)
            {
                _second_dist = _best_dist;
                _second_region_id = _best_region_id;
                _best_dist = _dist;
                _best_region_id = _rid;
            }
            else if (_dist < _second_dist)
            {
                _second_dist = _dist;
                _second_region_id = _rid;
            }
        }
    }

    if (_gen.region_count <= 0) return undefined;

    var _rc = _gen.region_count;
    var _r1 = _gen.regions[clamp(_best_region_id, 0, _rc - 1)];
    var _r2 = _gen.regions[clamp(_second_region_id, 0, _rc - 1)];

    return {
        r1: _r1,
        r2: _r2,
        diff: _second_dist - _best_dist,
    }
}

/// @desc Get distance to nearest region boundary (for transition blending)
/// @param {Struct} _gen Generator config
/// @param {Real} _x World X
/// @param {Real} _y World Y
/// @param {Real} _seed World seed
/// @returns {Real} Boundary distance
function region_gen_get_boundary_distance(_gen, _x, _y, _seed)
{
    if (_gen.map_buffer != undefined) return 1000;
    
    var _warped = region_gen_warp(_gen, _x, _y);
    var _wx = _warped[0];
    var _wy = _warped[1];
    
    var _cs = _gen.cell_size;
    var _so = _seed + _gen.seed_offset;
    var _cx0 = floor(_wx / _cs);
    var _cy0 = floor(_wy / _cs);
    
    var _best_dist = infinity;
    var _second_dist = infinity;
    
    for (var _cx = _cx0 - 1; _cx <= _cx0 + 1; ++_cx)
    {
        for (var _cy = _cy0 - 1; _cy <= _cy0 + 1; ++_cy)
        {
            var _cseed = __region_cell_seed(_cx, _cy, _so);
            var _pt = __region_cell_point(_cx, _cy, _cs, _cseed);
            
            var _dx = _wx - _pt[0];
            var _dy = _wy - _pt[1];
            var _dist = sqrt(_dx * _dx + _dy * _dy);
            
            if (_dist < _best_dist)
            {
                _second_dist = _best_dist;
                _best_dist = _dist;
            }
            else if (_dist < _second_dist)
            {
                _second_dist = _dist;
            }
        }
    }
    
    return (_second_dist - _best_dist) / 2.0;
}

#endregion
