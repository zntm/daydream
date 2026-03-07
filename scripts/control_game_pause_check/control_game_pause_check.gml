/// @desc Checks pause conditions (window focus lost, Escape key) and manages pause-UI lifecycle.
function control_game_pause_check()
{
    var _gc = obj_Game_Control;

    if (global.window_width <= 0) || (global.window_height <= 0)
    {
        _gc.is_opened |= WORLD_OPENED_BOOL.PAUSE;

        control_game_menu_hide_instances();

        if (_gc.is_opened & WORLD_OPENED_BOOL.MENU)
        {
            _gc.is_opened ^= WORLD_OPENED_BOOL.MENU;

            var _layer = layer_get_id("Menu_Item");

            with (all)
            {
                if (layer == _layer) instance_destroy();
            }
        }

        control_instance_pause();

        exit;
    }

    if !(keyboard_check_pressed(global.settings.input_keyboard_pause)) || (_gc.is_opened & WORLD_OPENED_BOOL.CHAT) exit;

    control_game_menu_hide_instances();

    if (_gc.is_opened & WORLD_OPENED_BOOL.MENU)
    {
        _gc.is_opened ^= WORLD_OPENED_BOOL.MENU;

        var _layer = layer_get_id("Menu_Item");

        with (all)
        {
            if (layer == _layer) instance_destroy();
        }

        exit;
    }

    _gc.is_opened ^= WORLD_OPENED_BOOL.PAUSE;

    if (_gc.is_opened & WORLD_OPENED_BOOL.PAUSE)
    {
        control_instance_pause();

        if (_gc.surface_refresh & SURFACE_REFRESH_BOOL.PAUSE)
        {
            _gc.surface_refresh ^= SURFACE_REFRESH_BOOL.PAUSE;
        }

        if (!variable_instance_exists(_gc, "ui_pause")) || (_gc.ui_pause == undefined)
        {
            var _pause_def = ui_load("ui/menu/pause.ui");

            if (_pause_def != undefined)
            {
                _gc.ui_pause = ui_spawn(_pause_def, {
                    link:   {},
                    parent: global.gui_root
                });

                var _elements = _gc.ui_pause.elements;

                var _btn_resume = _elements[$ "btn_resume"];

                if (_btn_resume != undefined)
                {
                    _btn_resume.add_event_handler("on_select_release", function()
                    {
                        obj_Game_Control.is_opened ^= WORLD_OPENED_BOOL.PAUSE;

                        control_instance_unpause();

                        if (variable_instance_exists(obj_Game_Control, "ui_pause")) && (obj_Game_Control.ui_pause != undefined)
                        {
                            ui_instance_destroy(obj_Game_Control.ui_pause);

                            obj_Game_Control.ui_pause = undefined;
                        }
                    });
                }

                var _btn_settings = _elements[$ "btn_settings"];

                if (_btn_settings != undefined)
                {
                    _btn_settings.add_event_handler("on_select_release", function()
                    {
                        obj_Game_Control.is_opened |= WORLD_OPENED_BOOL.MENU;

                        menu_refresh_instance_settings();
                    });
                }

                var _btn_save_quit = _elements[$ "btn_save_quit"];

                if (_btn_save_quit != undefined)
                {
                    _btn_save_quit.add_event_handler("on_select_release", function()
                    {
                        obj_Game_Control.is_opened |= WORLD_OPENED_BOOL.EXIT;
                    });
                }
            }
        }

        exit;
    }

    control_instance_unpause();

    if (variable_instance_exists(_gc, "ui_pause")) && (_gc.ui_pause != undefined)
    {
        ui_instance_destroy(_gc.ui_pause);

        _gc.ui_pause = undefined;
    }
}
