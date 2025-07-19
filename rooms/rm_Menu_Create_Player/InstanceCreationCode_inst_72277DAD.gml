placeholder = loca_translate("phantasia:menu.generic.textbox.enter_name");

var _text = global.player_save_data.name;

if (_text != "")
{
    text = _text;
}
else
{
    do
    {
        text = menu_textbox_randomize_player_name();
    }
    until (string_length(text) <= text_length);
    
    global.player_save_data.name = text;
}

text_display = text;

on_update = function()
{
    global.player_save_data.name = text;
}