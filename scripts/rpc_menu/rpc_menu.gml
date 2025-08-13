function rpc_menu()
{
    np_setpresence_timestamps(date_current_datetime(), 0, false);
    
    np_setpresence_buttons(0, "Discord", SITE_DISCORD);
    np_setpresence_buttons(1, "Bluesky", SITE_BLUESKY);
    
    var _header = loca_translate("phantasia:rpc.menu.header");
    var _description = loca_translate("phantasia:rpc.menu.description");
    
    np_setpresence(_header, _description, "icon", "");
}