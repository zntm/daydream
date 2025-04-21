function init(_namespace)
{
    init_splash($"{PROGRAM_DIRECTORY_RESOURCES}\\splash.json");
    
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
    
    show_debug_message(global.splash_data)
    
    room_goto(rm_World);
}, -1);