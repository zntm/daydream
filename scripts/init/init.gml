function init(_namespace)
{
    var _files = file_read_directory(PROGRAM_DIRECTORY_ASSETS);

    for (var i = array_length(_files) - 1; i >= 0; --i)
    {
        init_assets(_namespace, $"{PROGRAM_DIRECTORY_ASSETS}/{_files[i]}");
    }

    init_credit($"{PROGRAM_DIRECTORY_RESOURCES}/credit/data.json");

    init_rarity(_namespace, $"{PROGRAM_DIRECTORY_RESOURCES}/data/json/rarity_colours.json");

    init_tag_recursive(_namespace, $"{PROGRAM_DIRECTORY_RESOURCES}/data/tags");

    init_attire(_namespace, $"{PROGRAM_DIRECTORY_RESOURCES}/data/attires");

    init_particle_recursive(_namespace, $"{PROGRAM_DIRECTORY_RESOURCES}/data/particles");

    init_projectile(_namespace, $"{PROGRAM_DIRECTORY_RESOURCES}/data/projectiles");

    init_effect(_namespace, $"{PROGRAM_DIRECTORY_RESOURCES}/data/effects");

    init_item(_namespace, $"{PROGRAM_DIRECTORY_RESOURCES}/data/items");
    init_item_resolve_drops();

    init_crafting(_namespace, $"{PROGRAM_DIRECTORY_RESOURCES}/data/json/crafting_recipes.json");

    init_structure(_namespace, $"{PROGRAM_DIRECTORY_RESOURCES}/data/structures");

    init_region_recursive(_namespace, $"{PROGRAM_DIRECTORY_RESOURCES}/data/regions");

    init_biome_recursive(_namespace, $"{PROGRAM_DIRECTORY_RESOURCES}/data/biomes");

    init_world(_namespace, $"{PROGRAM_DIRECTORY_RESOURCES}/data/worlds");

    init_menu($"{PROGRAM_DIRECTORY_RESOURCES}/data/json/menu/music.json");

    init_menu_biomes($"{PROGRAM_DIRECTORY_RESOURCES}/data/json/menu/biomes.json");

    init_splash($"{PROGRAM_DIRECTORY_RESOURCES}/data/json/menu/splash_texts.json");

    init_creature(_namespace, $"{PROGRAM_DIRECTORY_RESOURCES}/data/creatures");

    init_achievement(_namespace, $"{PROGRAM_DIRECTORY_RESOURCES}/data/achievements");

    init_loot(_namespace, $"{PROGRAM_DIRECTORY_RESOURCES}/data/loot");
}

call_later(8, time_source_units_frames, function()
{
    init("phantasia");

    randomize();

    menu_refresh_value_background();

    room_goto((global.settings.menu_skip_epilepsy) ? rm_Menu_Title : rm_Menu_Warning_Epilepsy);

    file_load_players();
}, false);