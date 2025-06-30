text = loca_translate("phantasia:menu.create_player.title");

on_select_release = function()
{
    var _name = inst_72277DAD.text;
    
    if (string_length(_name) <= 0) exit;
    
    var _directory = -1;
    
    do 
    {
        _directory = uuid_generate(datetime_to_unix());
    }
    until (!directory_exists($"{PROGRAM_DIRECTORY_PLAYERS}/{_directory}"));
    
    file_save_player_global($"{PROGRAM_DIRECTORY_PLAYERS}/{_directory}", _name, global.player_save_data.attire);
    file_save_player_game($"{PROGRAM_DIRECTORY_PLAYERS}/{_directory}", 100, 100);
    
    room_goto(rm_Menu_Players);
    
    /*
    save_player(_directory, _name, 100, 100, 0, global.player.attire, false);
    save_grimoire(_directory, [ "phantasia:hatchet" ]);
    
    menu_goto_blur(rm_Menu_List_Players, true);
    */
}