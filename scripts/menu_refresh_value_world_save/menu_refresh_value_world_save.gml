global.world_save_data = {
    name: "",
    seed: "",
    dimension: "phantasia:playground",
    time: 0,
    day: 0,
    weather_wind: 0,
    weather_storm: 0,
    uuid: "",
    difficulty: 1.0,
    death_penalty_item_drop: 0.1,
    death_penalty_item_durability: 0.1,
    backup_interval: 0
}

function menu_refresh_value_world_save()
{
    global.world_save_data.name = "";
    global.world_save_data.seed = "";
    global.world_save_data.difficulty = 1.0;
    global.world_save_data.death_penalty_item_drop = 0.1;
    global.world_save_data.death_penalty_item_durability = 0.1;
    global.world_save_data.backup_interval = 0;
}