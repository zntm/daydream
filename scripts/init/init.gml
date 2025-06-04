function init(_namespace)
{
    init_splash($"{PROGRAM_DIRECTORY_RESOURCES}\\splash.json");
    
    init_rarity($"{PROGRAM_DIRECTORY_RESOURCES}\\rarity.json", _namespace);
    
    init_tag($"{PROGRAM_DIRECTORY_RESOURCES}\\tag.json", _namespace);
    
    init_attire($"{PROGRAM_DIRECTORY_RESOURCES}\\attire", _namespace);
    
    init_sfx_recursive($"{PROGRAM_DIRECTORY_RESOURCES}\\sfx", _namespace);
    
    init_particle_recursive($"{PROGRAM_DIRECTORY_RESOURCES}\\particle", _namespace);
    
    init_background($"{PROGRAM_DIRECTORY_RESOURCES}\\background", _namespace);
    
    init_music($"{PROGRAM_DIRECTORY_RESOURCES}\\music", _namespace);
    
    init_item($"{PROGRAM_DIRECTORY_RESOURCES}\\item", _namespace);
    
    init_structure($"{PROGRAM_DIRECTORY_RESOURCES}\\structure", _namespace);
    
    init_biome($"{PROGRAM_DIRECTORY_RESOURCES}\\biome", _namespace);
    
    init_world($"{PROGRAM_DIRECTORY_RESOURCES}\\world", _namespace);
}

call_later(8, time_source_units_frames, function()
{
    init("phantasia");
    
    room_goto(rm_Menu_Warning_Epilepsy);
}, -1);