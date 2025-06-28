icon = spr_Icon_Random;

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