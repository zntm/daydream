function control_instance_unpause()
{
    control_instance_cleanup_legacy_pause_menu();

    if (instance_exists(obj_Menu_Control_Render))
    {
        obj_Menu_Control_Render.xoffset = -1000;
        obj_Menu_Control_Render.yoffset = -1000;
    }

    var _layer = layer_get_id("Settings");

    if (_layer != -1)
    {
        with (all)
        {
            if (layer == _layer)
            {
                instance_destroy();
            }
        }
    }

    if (variable_global_exists("ui_settings_menu")) && (global.ui_settings_menu != undefined)
    {
        menu_settings_ui_close();
    }

    if (!instance_exists(obj_Game_Control)) exit;

    if (variable_instance_exists(obj_Game_Control, "ui_pause")) && (obj_Game_Control.ui_pause != undefined)
    {
        ui_instance_destroy(obj_Game_Control.ui_pause);
        obj_Game_Control.ui_pause = undefined;
    }

    obj_Game_Control.ui_pause_settings = undefined;
}
