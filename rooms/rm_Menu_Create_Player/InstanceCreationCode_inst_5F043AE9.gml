icon = spr_Icon_Random;

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