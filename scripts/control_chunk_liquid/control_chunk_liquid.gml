#macro CHUNK_LIQUID_WAVE_SPRING          25.0
#macro CHUNK_LIQUID_WAVE_DAMPING          1.5
#macro CHUNK_LIQUID_WAVE_SPREAD           6.0
#macro CHUNK_LIQUID_WAVE_WIND_CHANCE      0.12
#macro CHUNK_LIQUID_WAVE_WIND_FORCE       5.0
#macro CHUNK_LIQUID_WAVE_DISTURB_MAX      3.5
#macro CHUNK_LIQUID_WAVE_DISTURB_IMPULSE 10.0
#macro CHUNK_LIQUID_WAVE_EPSILON          0.005

/// @desc Updates liquid surface waves using spring-damper physics with neighbor propagation.
/// @param {real} _dt Delta time for frame-independent movement.
/// @param {real} _player_x Player x position.
/// @param {real} _player_y Player y position.
/// @param {real} _camera_x Camera x position.
/// @param {real} _camera_y Camera y position.
/// @param {real} _camera_width Camera width.
/// @param {real} _camera_height Camera height.
function control_chunk_liquid(_dt, _player_x, _player_y, _camera_x, _camera_y, _camera_width, _camera_height)
{
    var _last      = CHUNK_SIZE - 1;

    var _wind_strength = clamp(
        global.current_world.weather.wind + random_range(
            -0.2,
             0.2
        ),
        -1,
         1
    );

    for (var i = chunk_in_view_length - 1; i >= 0; --i)
    {
        var _c = chunk_in_view[i];

        if (_c == undefined) || !(_c.boolean & CHUNK_BOOL.GENERATED) || !(_c.chunk_display & (1 << CHUNK_DEPTH_LIQUID)) continue;

        var _chunk          = _c.chunk;
        var _chunk_wave     = _c.chunk_wave;
        var _chunk_wave_vel = _c.chunk_wave_vel;
        var _surface        = _c.chunk_liquid_surface;
        var _surface_length = _c.chunk_liquid_surface_length;

        if (_surface_length <= 0) continue;

        for (var _surface_i = _surface_length - 1; _surface_i >= 0; --_surface_i)
        {
            var _idx = _surface[_surface_i];
            var j = _idx & _last;

            var _disp = _chunk_wave[_idx];
            var _vel  = _chunk_wave_vel[_idx];

            /* spring force pulls displacement back to rest position */
            _vel -= _disp * CHUNK_LIQUID_WAVE_SPRING * _dt;

            /* horizontal wave propagation from neighbors */
            var _left_disp  = (j > 0) ? _chunk_wave[_idx - 1] : 0;
            var _right_disp = (j < _last) ? _chunk_wave[_idx + 1] : 0;

            _vel += ((_left_disp + _right_disp) * 0.5 - _disp) * CHUNK_LIQUID_WAVE_SPREAD * _dt;

            /* ambient wind perturbation on surface */
            if (chance(CHUNK_LIQUID_WAVE_WIND_CHANCE))
            {
                _vel += random(_wind_strength) * CHUNK_LIQUID_WAVE_WIND_FORCE;
            }

            /* velocity damping */
            _vel *= exp(-CHUNK_LIQUID_WAVE_DAMPING * _dt);

            /* integrate displacement */
            _disp += _vel * _dt;
            _disp = clamp(_disp, -CHUNK_LIQUID_WAVE_DISTURB_MAX, CHUNK_LIQUID_WAVE_DISTURB_MAX);

            /* snap to zero when nearly still */
            if (abs(_disp) < CHUNK_LIQUID_WAVE_EPSILON) && (abs(_vel) < CHUNK_LIQUID_WAVE_EPSILON)
            {
                _disp = 0;
                _vel  = 0;
            }

            _chunk_wave[@ _idx] = _disp;
            _chunk_wave_vel[@ _idx] = _vel;
        }
    }
}

/// @desc Applies an impulse disturbance to liquid wave velocities in a radius.
/// @param {real} _tile_x Tile x coordinate of disturbance center.
/// @param {real} _tile_y Tile y coordinate of disturbance center.
/// @param {real} _strength Disturbance strength (positive = downward push).
/// @param {real} [_radius] Tile radius of effect.
/// @param {string} [_liquid_id] Optional liquid type filter.
function control_chunk_liquid_disturb(_tile_x, _tile_y, _strength, _radius = 1, _liquid_id = undefined)
{
    var _strength_abs = abs(_strength);

    if (_strength_abs <= CHUNK_LIQUID_WAVE_EPSILON) exit;

    var _direction = sign(_strength);
    if (_direction == 0) _direction = 1;

    for (var _yy = _tile_y - _radius; _yy <= _tile_y + _radius; ++_yy)
    {
        for (var _xx = _tile_x - _radius; _xx <= _tile_x + _radius; ++_xx)
        {
            var _chunk = chunk_map_get_by_tile(_xx, _yy);

            if (_chunk == undefined) || !(_chunk.boolean & CHUNK_BOOL.GENERATED) || !(_chunk.chunk_display & (1 << CHUNK_DEPTH_LIQUID)) continue;

            var _idx  = tile_index_xy(_xx, _yy);
            var _tile = _chunk.chunk[tile_index_xyz(_xx, _yy, CHUNK_DEPTH_LIQUID)];

            if (_tile == TILE_EMPTY) continue;
            if (_liquid_id != undefined) && (_tile.get_id() != _liquid_id) continue;

            var _falloff = max(0, 1 - (point_distance(_tile_x, _tile_y, _xx, _yy) / max(_radius + 0.5, 1)));

            if (_falloff <= 0) continue;

            /* apply velocity impulse */
            _chunk.chunk_wave_vel[@ _idx] += _direction * _strength_abs * _falloff * CHUNK_LIQUID_WAVE_DISTURB_IMPULSE;
        }
    }
}
