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
    default_permission: {
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
    global.current_world.name = "";
    global.current_world.seed = 0;
}
