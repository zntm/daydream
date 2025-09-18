text = loca_translate("phantasia:menu.settings.title");

category = "general";

on_select_release = function()
{
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    global.menu_settings_xoffset = _camera_x;
    global.menu_settings_yoffset = _camera_y;
    
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
    
    var _layer = layer_get_id("Menu_Settings");
    
    with (all)
    {
        if (layer == _layer)
        {
            x = _camera_x + xstart;
            y = _camera_y + ystart;
        }
    }
    
    with (inst_7CD74435)
    {
        menu_refresh_instance_settings();
    }
}