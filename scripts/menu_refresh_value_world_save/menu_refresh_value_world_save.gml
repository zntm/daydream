global.world_save_data =
{
    name: "",
    seed: "",
    dimension: "phantasia:playground",
    time: 0,
    day: 0,
    weather_wind: 0,
    weather_storm: 0,
    uuid: "",
    difficulty: 1.0,
    death_penalty_item_drop: 100,
    death_penalty_item_durability: 100,
    backup_enabled: false,
    backup_interval: 5,
    backup_slots: 3,
    permissions: 0,
    advance_time: 1,
    friendly_fire: false,
    entity_drops: true,
    tile_drops: true,
    natural_regeneration: 1.0
}

function menu_refresh_value_world_save()
{
    global.world_save_data.name = "";
    global.world_save_data.seed = "";
}