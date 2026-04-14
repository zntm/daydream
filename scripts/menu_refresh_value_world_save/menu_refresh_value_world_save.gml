function world_get_default_enabled_mods()
{
    var _enabled_mods = [];

    if (!variable_global_exists("mod_list")) || !is_array(global.mod_list)
    {
        return _enabled_mods;
    }

    var _count = array_length(global.mod_list);

    for (var i = 0; i < _count; ++i)
    {
        var _mod_info = global.mod_list[i];
        if (_mod_info == undefined) continue;

        var _namespace = _mod_info.namespace ?? "";
        if (_namespace == "") continue;

        array_push(_enabled_mods, _namespace);
    }

    return _enabled_mods;
}


global.current_world = {
    uuid: "",
    name: "",
    seed: 0,
    time: 0,
    day: 0,
    dimension: "phantasia:playground",
    weather: {
        wind: 0,
        storm: 0
    },
    difficulty: 0,
    death_penalty: {
        item_drop_percentage: 0,
        item_durability_percentage: 0,
    },
    backup: {
        interval_minutes: 0,
        slots: 0
    },
    enabled_mods: world_get_default_enabled_mods(),
    default_permission: {
        level: 1
    },
    gamerule: {
        advance_time: 1,
        friendly_fire: false,
        item_drops: {
            entity_percentage: 0,
            tile_percentage: 0
        },
        natural_regeneration: 1
    }
}

function menu_refresh_value_world_save()
{
    global.current_world.uuid = "";
    global.current_world.name = "";
    global.current_world.seed = 0;
    global.current_world.time = 0;
    global.current_world.day = 0;
    global.current_world.dimension = "phantasia:playground";
    global.current_world.weather.wind = 0;
    global.current_world.weather.storm = 0;
    global.current_world.difficulty = 1;
    global.current_world.death_penalty.item_drop_percentage = 0;
    global.current_world.death_penalty.item_durability_percentage = 0;
    global.current_world.backup.interval_minutes = 0;
    global.current_world.backup.slots = 0;
    global.current_world.enabled_mods = world_get_default_enabled_mods();
    global.current_world.default_permission.level = 1;
    global.current_world.gamerule.advance_time = 1;
    global.current_world.gamerule.friendly_fire = false;
    global.current_world.gamerule.item_drops.entity_percentage = 0;
    global.current_world.gamerule.item_drops.tile_percentage = 0;
    global.current_world.gamerule.natural_regeneration = 1;
}
