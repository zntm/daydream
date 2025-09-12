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
    
    instance_deactivate_layer("Menu_Settings");
    instance_activate_layer("Menu_Pause");
}