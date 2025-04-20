function init(_namespace)
{
    init_background($"{DATAFILES_RESOURCES}/background", _namespace);
    
    init_music($"{DATAFILES_RESOURCES}/music", _namespace);
    
    init_item($"{DATAFILES_RESOURCES}/item", _namespace);
    
    init_structure($"{DATAFILES_RESOURCES}/structure", _namespace);
    
    init_biome($"{DATAFILES_RESOURCES}/biome", _namespace);
    
    init_world($"{DATAFILES_RESOURCES}/world", _namespace);
}

call_later(8, time_source_units_frames, function()
{
    init("phantasia");
    
    show_debug_message(global.structure_data)
    
    room_goto(rm_World);
}, -1);