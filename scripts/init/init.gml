function init(_namespace)
{
    init_music($"{DATAFILES_RESOURCES}/music", _namespace);
    
    init_item($"{DATAFILES_RESOURCES}/item", _namespace);
    
    init_biome($"{DATAFILES_RESOURCES}/biome", _namespace);
    
    init_world($"{DATAFILES_RESOURCES}/world", _namespace);
}

init("phantasia");