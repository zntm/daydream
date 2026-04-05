/// @desc Returns aquifer liquid info at position, or undefined if not in an aquifer
/// @param {Real} _x World X position
/// @param {Real} _y World Y position  
/// @param {Real} _surface_height Surface height at this X
/// @param {Real} _seed World seed
/// @param {Struct} _world_data World data struct
/// @returns {Struct|Undefined} Aquifer config or undefined
function worldgen_get_aquifer(_x, _y, _surface_height, _seed, _world_data = global.world_data[$ global.current_world.dimension])
{
    static __aquifer_hash_01 = function(_x, _y, _salt)
    {
        var _state = int64(_x * 374761393);
        _state = _state ^ int64(_y * 668265263);
        _state = _state ^ int64(_salt * 2246822519);
        _state = xorshift(_state);

        return (_state & 0x7fff_ffff) / 0x7fff_ffff;
    }

    static __aquifer_cell_center = function(_cell, _size, _jitter, _noise)
    {
        return ((_cell + 0.5) + ((_noise - 0.5) * 2 * _jitter)) * _size;
    }

    var _depth = _y - _surface_height;

    if (_depth < 0)
    {
        return undefined;
    }
    
    var _aquifers = _world_data.get_aquifers();
    var _aquifers_length = _world_data.get_aquifers_length();
    
    for (var i = 0; i < _aquifers_length; ++i)
    {
        var _aq = _aquifers[i];
        
        if (_depth >= _aq.depth_min) && (_depth <= _aq.depth_max)
        {
            var _cell_width = _aq.cell_width;
            var _cell_height = _aq.cell_height;
            var _cell_x = floor(_x / _cell_width);
            var _cell_y = floor(_y / _cell_height);
            var _best_distance = 999999;
            var _best_center_x = undefined;
            var _best_center_y = undefined;
            var _activation_chance = _aq.activation_chance;
            var _cell_radius = _aq.cell_radius;
            var _cell_radius_sq = _cell_radius * _cell_radius;
            var _salt_base = (_seed & 0x7fff_ffff) + ((i + 1) * 8191);

            for (var _yy = -1; _yy <= 1; ++_yy)
            {
                var _candidate_cell_y = _cell_y + _yy;

                for (var _xx = -1; _xx <= 1; ++_xx)
                {
                    var _candidate_cell_x = _cell_x + _xx;

                    if (__aquifer_hash_01(_candidate_cell_x, _candidate_cell_y, _salt_base) > _activation_chance)
                    {
                        continue;
                    }

                    var _center_x = __aquifer_cell_center(_candidate_cell_x, _cell_width, _aq.cell_jitter, __aquifer_hash_01(_candidate_cell_x, _candidate_cell_y, _salt_base + 13));
                    var _center_y = __aquifer_cell_center(_candidate_cell_y, _cell_height, _aq.cell_jitter, __aquifer_hash_01(_candidate_cell_x, _candidate_cell_y, _salt_base + 29));
                    var _dx = (_x - _center_x) / _cell_width;
                    var _dy = (_y - _center_y) / _cell_height;
                    var _distance = (_dx * _dx) + (_dy * _dy);

                    if (_distance <= _cell_radius_sq) && (_distance < _best_distance)
                    {
                        _best_distance = _distance;
                        _best_center_x = _center_x;
                        _best_center_y = _center_y;
                    }
                }
            }

            if (_best_center_x == undefined)
            {
                continue;
            }

            var _level_cell_x = floor(_best_center_x / _aq.level_cell_width);
            var _level_cell_y = floor(_best_center_y / _aq.level_cell_height);
            var _level_padding = _aq.fluid_level_padding;
            var _level_min = min(_aq.depth_min + _level_padding, _aq.depth_max);
            var _level_max = max(_level_min, _aq.depth_max - _level_padding);
            var _level_noise = __aquifer_hash_01(_level_cell_x, _level_cell_y, _salt_base + 47);
            var _fluid_level = round(lerp(_level_min, _level_max, _level_noise));

            if (_depth >= _fluid_level)
            {
                return _aq;
            }
        }
    }
    
    return undefined;
}
