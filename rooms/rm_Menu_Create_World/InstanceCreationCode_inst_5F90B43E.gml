placeholder = loca_translate("menu.generic.textbox.enter_name");

text_length = 40;

var _text = global.current_world.name;

if (_text != "")
{
    text = _text;
}
else
{
    do
    {
        text = menu_textbox_randomize_world_name();
    }
    until (string(text) != "undefined") && (string_length(text) <= text_length);
}

text_display = text;