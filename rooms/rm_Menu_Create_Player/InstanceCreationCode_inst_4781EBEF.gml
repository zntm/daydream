text = loca_translate("phantasia:menu.create_player.title");

on_select_release = function()
{
    var _name = inst_72277DAD.text;
    
    if (_name == "") exit;
    
    var _uuid = "";
    var _index = datetime_to_unix();
    
    do 
    {
        _uuid = uuid_generate(_index++);
    }
    until (!directory_exists($"{PROGRAM_DIRECTORY_PLAYERS}/{_uuid}"));
    
    var _attire = global.player_save_data.attire;
    
    file_save_player_global($"{PROGRAM_DIRECTORY_PLAYERS}/{_uuid}", _name, _attire, 100, 100, -1);
    
    array_insert(global.file_players, 0, new FilePlayer(_uuid, _name, date_current_datetime())
        .set_version(PROGRAM_VERSION_MAJOR, PROGRAM_VERSION_MINOR, PROGRAM_VERSION_PATCH, PROGRAM_VERSION_TYPE)
        .set_attire(_attire)
        .set_hp(100, 100)
        .set_effects({}));
    
    array_insert(global.file_players_uuid, 0, _uuid);
    
    room_goto(rm_Menu_Players);
}