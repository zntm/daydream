icon = spr_Icon_Random;

icon_xscale = 1.5;
icon_yscale = 1.5;

on_select_release = function()
{
    with (inst_8ABD565)
    {
        text = string(irandom_range(-0x8000_0000, 0x7fff_ffff));
        text_display = text;
    }
}