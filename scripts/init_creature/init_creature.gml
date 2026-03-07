global.creature_data = {}

function init_creature(_namespace = "phantasia", _directory)
{
    static __hostility_type = {
        passive: CREATURE_HOSTILITY_TYPE.PASSIVE,
        hostile: CREATURE_HOSTILITY_TYPE.HOSTILE,
    }

    static __movement_type = {
        ground: CREATURE_MOVEMENT_TYPE.DEFAULT,
        flight: CREATURE_MOVEMENT_TYPE.FLY,
        swim:   CREATURE_MOVEMENT_TYPE.SWIM,
    }

    var _files        = file_read_directory(_directory, true);
    var _files_length = array_length(_files);

    for (var i = _files_length - 1; i >= 0; --i)
    {
        var _file = _files[i];

        if (!string_ends_with(_file, ".json")) continue;

        dbg_timer("init_creature");

        var _json = buffer_load_json($"{_directory}/{_file}");

        if (!is_struct(_json)) continue;

        var _id        = string_delete(_file, string_length(_file) - 4, 5);
        var _sprite    = _json.sprite;
        var _sprite_id = init_asset_resolve(_namespace, _sprite);

        if (!init_asset_sprite_exists(_sprite_id))
        {
            PRINT($"[init_creature] Skipping '{_id}': missing sprite '{_sprite_id}'");

            delete _json;

            continue;
        }

        var _attribute = _json.attribute;

        var _data = new CreatureData(_namespace, _id, _json.hp, __hostility_type[$ _json.hostility_type], __movement_type[$ _json.movement_type]);

        _data.set_sprite(_sprite);
        _data.set_attribute(new Attribute()
            .set_boolean(_attribute[$ "boolean"])
            .set_collision_box(_attribute[$ "collision_box_width"], _attribute[$ "collision_box_height"])
            .set_hit_box(_attribute[$ "hit_box_width"], _attribute[$ "hit_box_height"])
            .set_eye_level(_attribute[$ "eye_level"])
            .set_gravity(_attribute[$ "gravity"])
            .set_jump_count_max(_attribute[$ "jump_count_max"])
            .set_jump_falloff(_attribute[$ "jump_falloff"])
            .set_jump_height(_attribute[$ "jump_height"])
            .set_jump_time(_attribute[$ "jump_time"])
            .set_movement_speed(_attribute[$ "movement_speed"])
            .set_regeneration_amount(_attribute[$ "regeneration_amount"])
            .set_regeneration_time(_attribute[$ "regeneration_time"])
        );

        /* filter drop references to only include loaded data */
        var _drops        = _json[$ "drops"];
        var _drops_parsed = [];

        if (is_array(_drops))
        {
            for (var j = array_length(_drops) - 1; j >= 0; --j)
            {
                var _drop    = _drops[j];
                var _drop_id = init_asset_resolve(_namespace, _drop.id);

                if (init_asset_item_exists(_drop_id))
                {
                    _drop.id = _drop_id;

                    array_push(_drops_parsed, _drop);
                }
                else
                {
                    PRINT($"[init_creature] '{_id}': drop '{_drop_id}' not loaded, skipping");
                }
            }
        }

        _data.set_drops(_drops_parsed);
        _data.set_properties(_json[$ "properties"]);
        _data.set_contact_damage(_json[$ "contact_damage"]);
        _data.set_predators(_json[$ "predators"]);

        global.creature_data[$ $"{_namespace}:{_id}"] = _data;

        dbg_timer("init_creature", $"[Init] Loaded Creature: '{_file}'");

        delete _json;
    }
}
