icon = spr_Icon_Arrow_Left;

icon_xscale = 1.5;
icon_yscale = 1.5;

on_select_release = function()
{
    var _length = array_length(global.attire_elements);
    
    global.menu_player_attire_index = ((global.menu_player_attire_index - 1) + _length) % _length;
    
    global.menu_player_attire_page = 0;
    global.menu_player_colour_page = 0;
    
    inst_70D31AA3.text = loca_translate($"phantasia:menu.create_player.attire.{global.attire_elements[global.menu_player_attire_index]}");
    
    menu_refresh_instance_player_attire();
    menu_refresh_instance_player_colour();
}