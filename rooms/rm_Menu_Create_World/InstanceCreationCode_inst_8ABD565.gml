placeholder = loca_translate("menu.create_world.textbox.enter_seed");

var _text = global.current_world.seed;

if (_text != "")
{
    text = _text;
}
else
{
    text = string(irandom_range(-0x8000_0000, 0x7fff_ffff));
}

text_display = text;