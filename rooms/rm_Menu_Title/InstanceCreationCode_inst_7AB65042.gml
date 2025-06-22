index = 0;

text = loca_translate("phantasia:menu.title.play");
icon = spr_Null;

on_select_release = function()
{
    room_goto(rm_Menu_Players);
}