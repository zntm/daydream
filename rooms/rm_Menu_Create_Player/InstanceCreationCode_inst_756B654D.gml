icon = spr_Icon_Arrow_Left;

icon_xscale = 1.5;
icon_yscale = 1.5;

on_select_release = function()
{
    var _length = ceil(array_length(global.attire_colour_data) / 6);
    
    global.menu_player_colour_page = ((global.menu_player_colour_page - 1) + _length) % (_length + 1);
    
    menu_refresh_instance_player_colour();
}