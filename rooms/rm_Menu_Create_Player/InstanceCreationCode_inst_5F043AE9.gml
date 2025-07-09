icon = spr_Icon_Random;

icon_xscale = 1.5;
icon_yscale = 1.5;

on_select_release = function()
{
    with (inst_72277DAD)
    {
        do
        {
            text = menu_textbox_randomize_player_name();
        }
        until (string_length(text) <= text_length);
        
        text_display = text;
    }
}