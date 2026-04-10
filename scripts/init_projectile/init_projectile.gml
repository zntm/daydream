global.projectile_data = {}

/// @desc Recursively load all projectile definitions from a directory tree of JSON files.
/// @param {String} _namespace  Namespace prefix for IDs.
/// @param {String} _directory  Path to the projectile JSON directory.
/// @param {String} [_id]       Current subdirectory path segment (used in recursion).
function init_projectile(_namespace = "phantasia", _directory)
{
    var _files        = file_read_directory(_directory, true);
    var _files_length = array_length(_files);

    for (var i = _files_length - 1; i >= 0; --i)
    {
        var _file = _files[i];

        if (!string_ends_with(_file, ".json")) || (directory_exists($"{_directory}/{_file}")) continue;

        dbg_timer("init_projectile");

        var _json = buffer_load_json($"{_directory}/{_file}");
        if (!init_data_namespace_allowed(_json, _file)) continue;

        if (!is_struct(_json)) continue;

        var _sprite    = _json[$ "sprite"];
        var _sprite_id = (_sprite != undefined) ? init_asset_resolve(_namespace, _sprite) : undefined;

        if (_sprite_id != undefined) && (!init_asset_sprite_exists(_sprite_id))
        {
            PRINT($"[init_projectile] Skipping '{_file}': missing sprite '{_sprite_id}'");

            delete _json;

            continue;
        }

        /* strip '.json' from name to get the id */
        var _data_id = string_delete(_file, string_length(_file) - 4, 5);

        var _data = new ProjectileData(_namespace, _data_id, _sprite);

        /* boolean properties */
        _data.set_boolean(projectile_parse_properties(_json[$ "properties"]));

        /* lifetime */
        var _lifetime = _json[$ "lifetime"];
        if (_lifetime != undefined) _data.set_lifetime(smart_value_parse(_lifetime));

        /* physics */
        var _physics = _json[$ "physics"];

        if (_physics != undefined)
        {
            _data.set_speed(smart_value_parse(_physics[$ "xspeed"] ?? 0));
            _data.set_speed_y(smart_value_parse(_physics[$ "yspeed"] ?? 0));
            _data.set_scale(smart_value_parse(_physics[$ "scale"]  ?? 1));

            /* rotation can be a struct { value, increment } or a plain number */
            var _rot = _physics[$ "rotation"];

            if (is_struct(_rot))
            {
                _data.set_rotation(smart_value_parse(_rot[$ "value"] ?? 0));
                _data.set_rotation_increment(smart_value_parse(_rot[$ "increment"] ?? 0));
            }
            else
            {
                _data.set_rotation(smart_value_parse(_rot ?? 0));
            }

            /* on-collision speed overrides */
            var _on_collision = _physics[$ "on_collision"];

            if (_on_collision != undefined)
            {
                if (_on_collision[$ "xspeed"] != undefined) _data.set_on_collision_speed_x(smart_value_parse(_on_collision.xspeed));
                if (_on_collision[$ "yspeed"] != undefined) _data.set_on_collision_speed_y(smart_value_parse(_on_collision.yspeed));
            }
        }

        /* attribute (collision box, hit box, gravity) */
        var _attribute = _json[$ "attribute"];

        if (_attribute != undefined)
        {
            _data.set_attribute(new Attribute()
                .set_collision_box(_attribute[$ "collision_box_width"], _attribute[$ "collision_box_height"])
                .set_hit_box(_attribute[$ "hit_box_width"], _attribute[$ "hit_box_height"])
                .set_gravity(_attribute[$ "gravity"])
            );

            _data.set_gravity(_attribute[$ "gravity"] ?? 0);
        }

        /* filter particle references */
        var _particles_json   = _json[$ "particles"];
        var _particles_parsed = [];

        if (is_array(_particles_json))
        {
            for (var j = array_length(_particles_json) - 1; j >= 0; --j)
            {
                var _p           = _particles_json[j];
                var _particle_id = init_asset_resolve(_namespace, _p.id);

                if (init_asset_particle_exists(_particle_id))
                {
                    var _mode = _p[$ "mode"] ?? "tick";

                    array_push(_particles_parsed, {
                        id:        _particle_id,
                        mode: (_mode == "shoot") ? PROJECTILE_PARTICLE_MODE.SHOOT
                            : ((_mode == "land") ? PROJECTILE_PARTICLE_MODE.LAND
                                : PROJECTILE_PARTICLE_MODE.TICK),
                        frequency: _p[$ "frequency"] ?? 0.1,
                        offset_x:  _p[$ "offset_x"]  ?? 0,
                        offset_y:  _p[$ "offset_y"]  ?? 0
                    });
                }
                else
                {
                    PRINT($"[init_projectile] '{_data_id}': particle '{_particle_id}' not loaded, skipping");
                }
            }
        }

        _data.set_particles(_particles_parsed);

        _data.set_on_shoot(_json[$ "on_shoot"]);
        _data.set_on_tick(_json[$ "on_tick"]);
        _data.set_on_hit_entity(_json[$ "on_hit_entity"]);
        _data.set_on_hit_tile(_json[$ "on_hit_tile"]);
        _data.set_on_land(_json[$ "on_land"]);

        global.projectile_data[$ $"{_namespace}:{_data_id}"] = _data;

        dbg_timer("init_projectile", $"[Init] Loaded Projectile: '{_data_id}'");

        delete _json;
    }
}
