menu_anchor_position(x, y, GUI_ANCHOR.BOTTOM_LEFT, room_width, room_height);

icon = spr_Icon_Folder;

icon_xscale = 1.5;
icon_yscale = 1.5;

on_select_release = function()
{
    execute_shell_simple(PROGRAM_DIRECTORY_WORLDS);
}