icon = spr_Icon_Folder;

icon_xscale = 1.5;
icon_yscale = 1.5;

on_select_release = function()
{
    execute_shell_simple(PROGRAM_DIRECTORY_WORLDS);
}