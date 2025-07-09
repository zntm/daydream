icon = spr_Icon_Random;

icon_xscale = 1.5;
icon_yscale = 1.5;

on_select_release = function()
{
    with (inst_5F90B43E)
    {
        do
        {
            text = menu_textbox_randomize_world_name();
        }
        until (string_length(text) <= text_length);
        
        text_display = text;
    }
}