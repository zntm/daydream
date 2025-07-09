icon = spr_Icon_Arrow_Left;

icon_xscale = 1.5;
icon_yscale = 1.5;

on_select_release = function()
{
    menu_refresh_value_player_save();
    
    room_goto(rm_Menu_Players);
}