text = loca_translate("phantasia:menu.create_player.title");

on_select_release = function()
{
    menu_refresh_value_player_save();
    
    room_goto(rm_Menu_Create_Player);
}