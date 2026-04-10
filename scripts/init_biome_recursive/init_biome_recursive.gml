global.biome_data = {}

function init_biome_recursive(_namespace = "phantasia", _directory)
{
    var _files        = file_read_directory(_directory, true);
    var _files_length = array_length(_files);

    for (var i = _files_length - 1; i >= 0; --i)
    {
        var _file = _files[i];

        if (directory_exists($"{_directory}/{_file}")) continue;

        if (!string_ends_with(_file, ".json")) continue;

        dbg_timer("init_biome");

        var _json = tag_value_parse(buffer_load_json($"{_directory}/{_file}"));
        if (!init_data_namespace_allowed(_json, _file)) continue;

        if (!is_struct(_json)) continue;

        var _id2        = string_delete(_file, string_length(_file) - 4, 5);
        var _biome_data = new BiomeData(_namespace, _file);

        if (_json[$ "background"] != undefined)
        {
            _biome_data.set_background(_json.background);
        }

        _biome_data.set_sky_colour(_json[$ "sky_colour"]);
        _biome_data.set_light_colour(_json[$ "light_colour"]);

        /* filter music references to only include loaded data */
        var _music        = _json[$ "music"];
        var _music_parsed = [];

        if (is_array(_music))
        {
            for (var j = array_length(_music) - 1; j >= 0; --j)
            {
                var _music_entry = _music[j];
                var _id_raw      = _music_entry[$ "id"] ?? _music_entry;
                var _music_id    = init_asset_resolve(_namespace, _id_raw);

                if (init_asset_music_exists(_music_id))
                {
                    if (is_struct(_music_entry))
                    {
                        _music_entry.id = _music_id;

                        array_push(_music_parsed, _music_entry);
                    }
                    else
                    {
                        array_push(_music_parsed, { id: _music_id, gain: 1.0 });
                    }
                }
                else
                {
                    PRINT($"[init_biome] '{_id2}': music '{_music_id}' not loaded, skipping");
                }
            }
        }
        else if (_music != undefined)
        {
            var _music_id = init_asset_resolve(_namespace, _music);

            if (init_asset_music_exists(_music_id))
            {
                array_push(_music_parsed, { id: _music_id, gain: 1.0 });
            }
            else
            {
                PRINT($"[init_biome] '{_id2}': music '{_music_id}' not loaded, skipping");
            }
        }

        _biome_data.set_music(_music_parsed);

        var _tile = _json[$ "tile"];

        if (_tile != undefined)
        {
            _biome_data.set_tile_top_layer(_tile.top_layer);
            _biome_data.set_tile_middle_layer(_tile.middle_layer);
            _biome_data.set_tile_bottom_layer(_tile.bottom_layer);
        }

        /* filter foliage references to only include loaded data */
        var _foliage        = _json[$ "foliage"];
        var _foliage_parsed = [];

        if (is_array(_foliage))
        {
            for (var j = array_length(_foliage) - 1; j >= 0; --j)
            {
                var _foliage_entry = _foliage[j];
                var _id_raw        = _foliage_entry[$ "id"] ?? _foliage_entry;
                var _foliage_id    = init_asset_resolve(_namespace, _id_raw);

                /* foliage can be tiles, but traditionally they are checked via tile exists? */
                /* actually foliage refers to tiles usually */
                if (init_asset_item_exists(_foliage_id))
                {
                    if (is_struct(_foliage_entry))
                    {
                        _foliage_entry.id = _foliage_id;

                        array_push(_foliage_parsed, _foliage_entry);
                    }
                    else
                    {
                        array_push(_foliage_parsed, _foliage_id);
                    }
                }
                else
                {
                    PRINT($"[init_biome] '{_id2}': foliage '{_foliage_id}' not loaded, skipping");
                }
            }
        }

        _biome_data.set_tile_foliage(_foliage_parsed);

        /* filter creature references to only include loaded data */
        var _creatures        = _json[$ "creatures"];
        var _creatures_parsed = [];

        if (is_array(_creatures))
        {
            for (var j = array_length(_creatures) - 1; j >= 0; --j)
            {
                var _creature_entry = _creatures[j];
                var _id_raw         = _creature_entry[$ "id"] ?? _creature_entry;
                var _creature_id    = init_asset_resolve(_namespace, _id_raw);

                if (init_asset_creature_exists(_creature_id))
                {
                    if (is_struct(_creature_entry)) _creature_entry.id = _creature_id;

                    array_push(_creatures_parsed, (is_struct(_creature_entry)) ? _creature_entry : _creature_id);
                }
                else
                {
                    PRINT($"[init_biome] '{_id2}': creature '{_creature_id}' not loaded, skipping");
                }
            }
        }

        _biome_data.set_creature(_creatures_parsed);

        /* filter structure references to only include loaded data */
        var _structures        = _json[$ "structures"];
        var _structures_parsed = [];

        if (is_array(_structures))
        {
            for (var j = array_length(_structures) - 1; j >= 0; --j)
            {
                var _structure_entry = _structures[j];
                var _id_raw          = _structure_entry[$ "id"] ?? _structure_entry;
                var _structure_id    = init_asset_resolve(_namespace, _id_raw);

                if (init_asset_structure_exists(_structure_id))
                {
                    if (is_struct(_structure_entry))
                    {
                        _structure_entry.id = _structure_id;

                        array_push(_structures_parsed, _structure_entry);
                    }
                    else
                    {
                        array_push(_structures_parsed, _structure_id);
                    }
                }
                else
                {
                    PRINT($"[init_biome] '{_id2}': structure '{_structure_id}' not loaded, skipping");
                }
            }
        }

        _biome_data.set_structure(_structures_parsed);

        _biome_data.set_terrain_modifier(_json[$ "terrain_modifier"]);
        _biome_data.set_is_ocean(_json[$ "is_ocean"]);
        _biome_data.set_shore_tiles(_json[$ "shore_tiles"]);
        _biome_data.set_is_skyland(_json[$ "is_skyland"]);
        _biome_data.set_sky_script(_json[$ "sky_script"]);

        var _ambience = _json[$ "ambience"];

        if (_ambience != undefined)
        {
            _biome_data.set_ambience(_ambience);
        }

        global.biome_data[$ $"{_namespace}:{_id2}"] = _biome_data;

        delete _json;

        dbg_timer("init_biome", $"[Init] Loaded Biome: '{_id2}'");
    }
}
