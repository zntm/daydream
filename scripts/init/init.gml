function init(_namespace)
{
    var _files = file_read_directory(PROGRAM_DIRECTORY_ASSETS);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        init_assets($"{PROGRAM_DIRECTORY_ASSETS}/{_files[i]}", _namespace);
    }
    
    init_credit($"{PROGRAM_DIRECTORY_RESOURCES}\\credit\\data.json");
    
    init_rarity($"{PROGRAM_DIRECTORY_RESOURCES}/data/json/rarity_colours.json", _namespace);
    
    init_tag_recursive($"{PROGRAM_DIRECTORY_RESOURCES}/data/tags", _namespace);
    
    init_attire($"{PROGRAM_DIRECTORY_RESOURCES}/data/attires", _namespace);
    
    // init_sfx($"{PROGRAM_DIRECTORY_DATA}\\sfx", _namespace);
    
    init_particle_recursive($"{PROGRAM_DIRECTORY_RESOURCES}/data/particles", _namespace);
    
    init_projectile($"{PROGRAM_DIRECTORY_RESOURCES}/data/projectiles", _namespace);
    
    // init_music($"{PROGRAM_DIRECTORY_DATA}\\music", _namespace);
    
    init_effect($"{PROGRAM_DIRECTORY_RESOURCES}/data/effects", _namespace);

    init_item($"{PROGRAM_DIRECTORY_RESOURCES}/data/items", _namespace);
    
    init_crafting($"{PROGRAM_DIRECTORY_RESOURCES}/data/json/crafting_recipes.json", _namespace);
    
    init_structure($"{PROGRAM_DIRECTORY_RESOURCES}/data/structures", _namespace);
    
    init_biome_recursive($"{PROGRAM_DIRECTORY_RESOURCES}/data/biomes", _namespace);
    
    init_region_recursive($"{PROGRAM_DIRECTORY_RESOURCES}/data/regions", _namespace);
    
    init_world($"{PROGRAM_DIRECTORY_RESOURCES}/data/worlds", _namespace);
    
    // Initialize global region generator with all loaded regions
    var _regions = struct_get_names(global.region_data);
    var _region_count = array_length(_regions);
    var _region_array = array_create(_region_count);
    for (var i = 0; i < _region_count; i++) {
        _region_array[i] = global.region_data[$ _regions[i]];
    }
    global.region_generator = new RegionGenerator();
    global.region_generator.set_regions(_region_array);
    
    init_menu($"{PROGRAM_DIRECTORY_RESOURCES}/data/json/menu/music.json");
    
    init_menu_biomes($"{PROGRAM_DIRECTORY_RESOURCES}/data/json/menu/biomes.json");
    
    init_splash($"{PROGRAM_DIRECTORY_RESOURCES}/data/json/menu/splash_texts.json");
    
    init_creature($"{PROGRAM_DIRECTORY_RESOURCES}/data/creatures", _namespace);
    
    init_achievement($"{PROGRAM_DIRECTORY_RESOURCES}/data/achievements", _namespace);
    
    init_loot($"{PROGRAM_DIRECTORY_RESOURCES}/data/loot", _namespace);
}

call_later(8, time_source_units_frames, function()
{
    init("phantasia");
    
    randomize();
    
    menu_refresh_value_background();
    
    room_goto((global.settings.menu_skip_epilepsy) ? rm_Menu : rm_Menu_Warning_Epilepsy);
    
    file_load_players();
}, -1);