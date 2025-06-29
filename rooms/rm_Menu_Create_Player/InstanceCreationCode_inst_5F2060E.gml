icon = spr_Icon_Arrow_Right;

on_select_release = function()
{
    var _length = ceil(array_length(global.attire_data[$ global.attire_elements[global.menu_player_attire_index]]) / 6);
    
    global.menu_player_attire_page = (global.menu_player_attire_page + 1) % _length;
    
    menu_refresh_instance_player_attire();
}