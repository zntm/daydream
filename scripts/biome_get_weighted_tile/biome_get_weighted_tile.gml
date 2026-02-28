/// @function biome_get_weighted_tile(_parsed, _noise)
/// @desc Choose a tile from a parsed weighted tile array using a noise value (0..255).
/// @param {Struct} _parsed The parsed tile data from BiomeData.__parse_tile_array.
/// @param {Real} _noise Noise value in the range 0..255.
/// @returns {String} The chosen tile ID.
function biome_get_weighted_tile(_parsed, _noise)
{
    var _entries = _parsed.entries;
    var _total   = _parsed.total_weight;

    if (array_length(_entries) == 0) return TILE_EMPTY;

    if (array_length(_entries) == 1)
    {
        return smart_value(_entries[0].id);
    }
    
    /* check explicit noise ranges first */
    for (var i = array_length(_entries) - 1; i >= 0; --i)
    {
        var _e = _entries[i];

        if (_e.noise_min == undefined) continue;

        if (_noise >= _e.noise_min) && (_noise < (_e.noise_max ?? 256))
        {
            return smart_value(_e.id);
        }
    }

    /* fallback to weighted selection */
    var _roll = (_noise / 255) * _total;

    for (var i = array_length(_entries) - 1; i >= 0; --i)
    {
        if (_roll >= _entries[i].cumulative_weight) continue;

        return smart_value(_entries[i].id);
    }

    return smart_value(_entries[0].id);
}
