icon = spr_Icon_Arrow_Left;

icon_xscale = 1.5;
icon_yscale = 1.5;

on_select_release = function()
{
    var _layer = layer_get_id("Settings");
    
    with (all)
    {
        if (layer == _layer)
        {
            instance_destroy();
        }
    }
    
    with (obj_Menu_Anchor)
    {
        y = -1000;
    }
    
    with (obj_Menu_Button)
    {
        y = -1000;
    }
    
    with (obj_Menu_Dropdown)
    {
        y = -1000;
    }
    
    with (obj_Menu_Textbox)
    {
        y = -1000;
    }
    
    control_instance_pause();
}