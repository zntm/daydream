text = loca_translate("phantasia:menu.create_player.title");

on_select_release = function()
{
    var _name = inst_72277DAD.text;
    
    if (string_length(_name) <= 0) exit;
    
    var _directory = "";
    
    do 
    {
        _directory = uuid_generate(irandom_range(-0x8000_0000, 0x7fff_ffff));
    }
    until (!directory_exists($"{PROGRAM_DIRECTORY_PLAYERS}/{_directory}"));
    
    var _attire = global.player_save_data.attire;
    
    file_save_player_global($"{PROGRAM_DIRECTORY_PLAYERS}/{_directory}", _name, _attire, 100, 100, -1);
    
    array_insert(global.file_players, 0, new FilePlayer(_directory, _name, date_current_datetime())
        .set_version(PROGRAM_VERSION_MAJOR, PROGRAM_VERSION_MINOR, PROGRAM_VERSION_PATCH, PROGRAM_VERSION_TYPE)
        .set_attire(_attire)
        .set_hp(100, 100)
        .set_effects({}));
    
    array_insert(global.file_players_uuid, 0, _directory);
    
    room_goto(rm_Menu_Players);
}