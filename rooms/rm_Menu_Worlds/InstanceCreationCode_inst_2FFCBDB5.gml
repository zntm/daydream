menu_anchor_position(x, y, GUI_ANCHOR.BOTTOM, room_width, room_height);

text = loca_translate("phantasia:menu.create_world.title");

on_select_release = function()
{
    room_goto(rm_Menu_Create_World);
}