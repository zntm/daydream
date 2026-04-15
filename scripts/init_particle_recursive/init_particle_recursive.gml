global.particle_data = {}

function init_particle_recursive(_namespace, _directory)
{
    var _files        = file_read_directory(_directory, true);
    var _files_length = array_length(_files);

    for (var i = _files_length - 1; i >= 0; --i)
    {
        var _file = _files[i];

        if (!string_ends_with(_file, ".json")) || (directory_exists($"{_directory}/{_file}")) continue;
        
        dbg_timer("init_particle");

        var _name_clean = string_delete(_file, string_length(_file) - 4, 5);
        var _json_root = buffer_load_json($"{_directory}/{_file}");
        var _prepared = init_data_prepare_json("particles", _namespace, _name_clean, _json_root, _file);
        if (_prepared == undefined) continue;

        var _data_namespace = _prepared.namespace;
        var _full_id = _prepared.full_id;
        var _json = _prepared.json;
        if (!init_data_namespace_allowed(_json, _file)) continue;

        if (!is_struct(_json)) continue;

        /* build folder-based group id if applicable */
        if (filename_dir(_file) != "")
        {
            var _id = filename_dir(_file);
            /* flip backslash to forward slash if on windows */
            _id = string_replace_all(_id, "\\", "/");
            
            global.particle_data[$ $"{_data_namespace}:{_id}"] ??= [];
            array_push(global.particle_data[$ $"{_data_namespace}:{_id}"], _full_id);
        }

        var _sprite    = _json[$ "sprite"];
        var _sprite_id = (_sprite != undefined) ? init_asset_resolve(_data_namespace, _sprite) : undefined;

        if (_sprite_id != undefined) && (!init_asset_sprite_exists(_sprite_id))
        {
            PRINT($"[init_particle] Skipping '{_file}': missing sprite '{_sprite_id}'");

            delete _json;

            continue;
        }

        var _particle_data = new ParticleData(_data_namespace, filename_dir(_file), _sprite);

        _particle_data.set_properties(_json[$ "properties"]);
        _particle_data.set_lifetime(_json[$ "lifetime"]);
        _particle_data.set_size(_json[$ "size"]);
        _particle_data.set_orientation(_json[$ "orientation"]);
        _particle_data.set_colour(_json[$ "colour"]);
        _particle_data.set_speed(_json[$ "speed"]);
        _particle_data.set_direction(_json[$ "direction"]);
        _particle_data.set_gravity(_json[$ "gravity"]);
        _particle_data.set_wind_factor(_json[$ "wind_factor"]);

        global.particle_data[$ _full_id] = _particle_data;
        init_data_finalize_json("particles", _full_id, _prepared.json);

        delete _json;

        dbg_timer("init_particle", $"[Init] Loaded Particle: '{_name_clean}'");
    }
}
