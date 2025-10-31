function init(_namespace)
{
    var _files = file_read_directory(PROGRAM_DIRECTORY_ASSETS);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        init_assets($"{PROGRAM_DIRECTORY_ASSETS}/{_files[i]}", _namespace);
    }
    
    init_credit($"{PROGRAM_DIRECTORY_DATA}\\credit\\data.json");
    
    init_splash($"{PROGRAM_DIRECTORY_DATA}\\splash.json");
    
    init_rarity($"{PROGRAM_DIRECTORY_DATA}\\rarity.json", _namespace);
    
    init_tag_recursive($"{PROGRAM_DIRECTORY_DATA}\\tag", _namespace);
    
    init_attire($"{PROGRAM_DIRECTORY_DATA}\\attire", _namespace);
    
    init_sfx($"{PROGRAM_DIRECTORY_DATA}\\sfx", _namespace);
    
    init_particle_recursive($"{PROGRAM_DIRECTORY_DATA}\\particle", _namespace);
    
    init_projectile($"{PROGRAM_DIRECTORY_DATA}\\projectile", _namespace);
    
    init_background($"{PROGRAM_DIRECTORY_DATA}\\background", _namespace);
    
    init_music($"{PROGRAM_DIRECTORY_DATA}\\music", _namespace);
    
    init_item($"{PROGRAM_DIRECTORY_RESOURCES}/data/items", _namespace);
    
    init_crafting($"{PROGRAM_DIRECTORY_DATA}\\crafting.json", _namespace);
    
    init_structure($"{PROGRAM_DIRECTORY_DATA}\\structure", _namespace);
    
    init_biome($"{PROGRAM_DIRECTORY_DATA}\\biome", _namespace);
    
    init_world($"{PROGRAM_DIRECTORY_DATA}\\world", _namespace);
    
    init_menu($"{PROGRAM_DIRECTORY_DATA}\\menu.json");
    
    init_creature($"{PROGRAM_DIRECTORY_DATA}\\creature", _namespace);
    
    init_loot($"{PROGRAM_DIRECTORY_DATA}\\loot", _namespace);
}

call_later(8, time_source_units_frames, function()
{
    init("phantasia");
    
    menu_refresh_value_background();
    
    room_goto((global.settings.menu_skip_epilepsy) ? rm_Menu_Title : rm_Menu_Warning_Epilepsy);
    
    file_load_players();
}, -1);