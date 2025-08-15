x = gui_xanchor(GUI_ANCHOR.MIDDLE, room_width,  1);
y = gui_yanchor(GUI_ANCHOR.MIDDLE, room_height, 1) + 2;

index = 0;

text = loca_translate("phantasia:menu.title.play");

on_select_release = function()
{
    room_goto(rm_Menu_Players);
}