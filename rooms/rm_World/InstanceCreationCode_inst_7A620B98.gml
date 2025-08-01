text = loca_translate("phantasia:menu.settings.title");

category = "general";

on_select_release = function()
{
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    global.menu_settings_xoffset = _camera_x;
    global.menu_settings_yoffset = _camera_y;
    
    layer_set_visible("Menu_Pause", false);
    
    layer_set_visible("Menu_Settings", true);
    layer_set_visible("Settings", true);
    
    inst_7CD74435.x = _camera_x + inst_7CD74435.xstart;
    inst_7CD74435.y = _camera_y + inst_7CD74435.ystart;
    
    inst_704AF147.x = _camera_x + inst_704AF147.xstart;
    inst_704AF147.y = _camera_y + inst_704AF147.ystart;
    
    inst_209DCB50.x = _camera_x + inst_209DCB50.xstart;
    inst_209DCB50.y = _camera_y + inst_209DCB50.ystart;
    
    inst_2C1ECBCE.x = _camera_x + inst_2C1ECBCE.xstart;
    inst_2C1ECBCE.y = _camera_y + inst_2C1ECBCE.ystart;
    
    with (inst_7CD74435)
    {
        menu_refresh_instance_settings();
    }
}