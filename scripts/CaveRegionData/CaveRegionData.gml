global.cave_region_data = [];
global.cave_region_data_length = 0;

/// @desc A special cave region that generates independently of surface regions.
/// @param {String} _id Region identifier (e.g. "lumin")
/// @param {Struct} _config Configuration struct
function CaveRegionData(_id, _config = {}) constructor
{
    ___id             = _id;
    ___biome          = _config[$ "biome"] ?? "phantasia:cave/chasm";
    ___noise_scale    = _config[$ "noise_scale"] ?? 0.008;
    ___noise_threshold = _config[$ "noise_threshold"] ?? 0.6;
    ___min_depth      = _config[$ "min_depth"] ?? 0;
    ___max_depth      = _config[$ "max_depth"] ?? 99999;
    ___salt           = _config[$ "salt"] ?? 0;

    static get_id = function()
    {
        return ___id;
    }

    static get_biome = function()
    {
        return ___biome;
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

        /* normalize from 0..1 to check threshold */
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
    for (var i = global.cave_region_data_length - 1; i >= 0; --i)
    {
        var _region = global.cave_region_data[i];

        if (_region.check(_x, _y, _depth, _seed))
        {
            return _region.get_biome();
        }
    }

    return undefined;
}
