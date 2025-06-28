icon = spr_Icon_Random;

on_select_release = function()
{
    with (inst_8ABD565)
    {
        text = string(irandom_range(-0x8000_0000, 0x7fff_ffff));
        text_display = text;
    }
}