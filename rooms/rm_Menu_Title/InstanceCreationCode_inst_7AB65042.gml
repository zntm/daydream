menu_anchor_position(x, y, GUI_ANCHOR.MIDDLE, room_width, room_height);

index = 0;

text = loca_translate("phantasia:menu.title.play");

on_select_release = function()
{
    room_goto(rm_Menu_Players);
}