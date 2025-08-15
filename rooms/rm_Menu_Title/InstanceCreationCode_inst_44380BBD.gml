x = gui_xanchor(GUI_ANCHOR.MIDDLE, room_width,  1);
y = gui_yanchor(GUI_ANCHOR.MIDDLE, room_height, 1) + 66;

index = 1;

text = loca_translate("phantasia:menu.settings.title");

on_select_release = function()
{
    room_goto(rm_Menu_Settings);
}