function control_instance_cleanup_legacy_pause_menu()
{
    var _pause_layer = layer_get_id("Menu_Pause");

    if (_pause_layer == -1) exit;

    with (all)
    {
        if (layer == _pause_layer)
        {
            instance_destroy();
        }
    }
}


function control_instance_pause()
{
    if (!instance_exists(obj_Game_Control)) exit;

    control_instance_cleanup_legacy_pause_menu();

    if (!variable_global_exists("gui_root")) || (global.gui_root == undefined)
    {
        global.gui_root = ui_create_root();
        global.gui_root.element_name = "gui_root";
    }

    var _gc = obj_Game_Control;

    if (variable_instance_exists(_gc, "ui_pause")) && (_gc.ui_pause != undefined)
    {
        _gc.ui_pause.visible = true;
        exit;
    }

    ui_invalidate_definition("ui/menu/pause.ui");

    var _pause_def = ui_load("ui/menu/pause.ui");

    if (_pause_def == undefined)
    {
        PRINT("[Pause] failed to load ui/menu/pause.ui");
        exit;
    }

    _gc.ui_pause = ui_spawn(_pause_def, {
        link:   {},
        parent: global.gui_root
    });

    var _elements = _gc.ui_pause.elements;

    var _title = _elements[$ "title"];

    if (_title != undefined)
    {
        _title.text = loca_translate("phantasia:menu.pause.title");
    }

    var _btn_resume = _elements[$ "btn_resume"];

    if (_btn_resume != undefined)
    {
        _btn_resume.text = loca_translate("phantasia:menu.pause.resume");
        _btn_resume.set_sprite_index(spr_Menu_Button_Success);

        _btn_resume.add_event_handler("on_select_release", function()
        {
            control_game_pause_close_settings();

            if (obj_Game_Control.is_opened & WORLD_OPENED_BOOL.PAUSE)
            {
                obj_Game_Control.is_opened ^= WORLD_OPENED_BOOL.PAUSE;
            }

            control_instance_unpause();
        });
    }

    var _btn_settings = _elements[$ "btn_settings"];

    if (_btn_settings != undefined)
    {
        _btn_settings.text = loca_translate("phantasia:menu.settings.title");
        _btn_settings.set_sprite_index(spr_Menu_Button_Secondary);

        _btn_settings.add_event_handler("on_select_release", function()
        {
            control_game_pause_open_settings();
        });
    }

    var _btn_save_quit = _elements[$ "btn_save_quit"];

    if (_btn_save_quit != undefined)
    {
        _btn_save_quit.text = loca_translate("phantasia:menu.pause.exit");
        _btn_save_quit.set_sprite_index(spr_Menu_Button_Warning);

        _btn_save_quit.add_event_handler("on_select_release", function()
        {
            obj_Game_Control.is_opened |= WORLD_OPENED_BOOL.EXIT;
        });
    }
}
