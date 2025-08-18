menu_anchor_position(x, y, GUI_ANCHOR.TOP_LEFT, room_width, room_height);

icon = spr_Icon_Arrow_Left;

icon_xscale = 1.5;
icon_yscale = 1.5;

on_select_release = function()
{
    room_goto(rm_Menu_Title);
}