
if (!IS_MULTIPLAYER_ENABLED)
{
    instance_destroy();
    exit;
}

menu_anchor_position(x, y, GUI_ANCHOR.BOTTOM, room_width, room_height);

text = loca_translate("phantasia:menu.multiplayer.title");

on_select_release = function()
{
    menu_transition_goto(rm_Menu_Multiplayer);
}