placeholder = loca_translate("menu.create_world.textbox.enter_seed");

// TODO: replace with global world var
var _text = "";

if (_text != "")
{
    text = _text;
}
else
{
    text = string(irandom(-0x8000_0000, 0x7fff_ffff));
}

text_display = text;