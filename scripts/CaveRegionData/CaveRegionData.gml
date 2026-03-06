/// @desc A special cave region that generates independently of surface regions.
/// @param {String} _id Region identifier (e.g. "phantasia:lumin")
/// @param {Struct} _config Configuration struct
function CaveRegionData(_id, _config = {}) constructor
{
    ___id              = _id;
    ___noise_scale     = _config[$ "noise_scale"] ?? 0.008;
    ___noise_threshold = _config[$ "noise_threshold"] ?? 0.6;
    ___min_depth       = _config[$ "min_depth"] ?? 0;
    ___max_depth       = _config[$ "max_depth"] ?? 99999;
    ___salt            = _config[$ "salt"] ?? 0;

    var _biomes_raw       = _config[$ "biomes"] ?? [];
    ___biomes             = [];
    ___biome_count        = array_length(_biomes_raw);
    ___biome_noise_scale  = _config[$ "biome_noise_scale"] ?? 0.008;
    ___biome_total_weight = 0;

    for (var i = 0; i < ___biome_count; ++i)
    {
        var _b = _biomes_raw[i];
        var _entry = {
            id:     _b[$ "id"] ?? _b,
            weight: _b[$ "weight"] ?? 1,
        }

        array_push(___biomes, _entry);

        ___biome_total_weight += _entry.weight;
    }

    static get_id = function()
    {
        return ___id;
    }

    static get_noise_scale = function()
    {
        return ___noise_scale;
    }

    static get_noise_threshold = function()
    {
        return ___noise_threshold;
    }

    static get_min_depth = function()
    {
        return ___min_depth;
    }

    static get_max_depth = function()
    {
        return ___max_depth;
    }

    static get_salt = function()
    {
        return ___salt;
    }

    static get_biomes = function()
    {
        return ___biomes;
    }

    /// @desc Get biome ID based on position using noise-weighted selection
    /// @param {Real} _x World X
    /// @param {Real} _y World Y
    /// @returns {String} Biome ID
    static get_biome_id = function(_x = 0, _y = 0)
    {
        if (___biome_count <= 1)
        {
            return (___biome_count == 0) ? "" : ___biomes[0].id;
        }

        var _noise = open_simplex_noise(
            _x * ___biome_noise_scale,
            _y * ___biome_noise_scale + 2048,
            1.0, 2
        );

        var _pick  = _noise * ___biome_total_weight;
        var _accum = 0;

        for (var i = 0; i < ___biome_count; ++i)
        {
            _accum += ___biomes[i].weight;

            if (_pick < _accum)
            {
                return ___biomes[i].id;
            }
        }

        return ___biomes[___biome_count - 1].id;
    }

    /// @desc Get resolved BiomeData
    /// @param {Real} _x World X
    /// @param {Real} _y World Y
    /// @returns {Struct} BiomeData
    static get_biome = function(_x = 0, _y = 0)
    {
        return global.biome_data[$ get_biome_id(_x, _y)];
    }

    /// @desc Check if position qualifies for this cave region
    /// @param {Real} _x World X
    /// @param {Real} _y World Y
    /// @param {Real} _depth Depth from surface
    /// @param {Real} _seed World seed
    /// @returns {Bool}
    static check = function(_x, _y, _depth, _seed)
    {
        if (_depth < ___min_depth) || (_depth > ___max_depth) return false;

        var _noise = open_simplex_noise(
            _x * ___noise_scale,
            _y * ___noise_scale + ___salt,
            1.0,
            2
        );

        /* check threshold */
        return (_noise >= ___noise_threshold);
    }
}

/// @desc Check all special cave regions and return the biome of the first match.
/// @param {Real} _x World X
/// @param {Real} _y World Y
/// @param {Real} _depth Depth from surface
/// @param {Real} _seed World seed
/// @returns {String|undefined} Biome ID or undefined
function worldgen_get_special_cave_region(_x, _y, _depth, _seed)
{
    for (var i = array_length(global.cave_region_list) - 1; i >= 0; --i)
    {
        var _region = global.cave_region_list[i];

        if (_region.check(_x, _y, _depth, _seed))
        {
            return _region.get_biome_id(_x, _y);
        }
    }

    return undefined;
}
