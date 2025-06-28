placeholder = loca_translate("menu.generic.textbox.enter_name");

var _text = global.menu_player_data.name;

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
    
    global.menu_player_data.name = text;
}

text_display = text;

on_update = function()
{
    global.menu_player_data.name = text;
}