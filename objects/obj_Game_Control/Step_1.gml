if (obj_Game_Control.is_opened & (IS_OPENED_BOOLEAN.GENERATING_WORLD | IS_OPENED_BOOLEAN.EXIT)) exit;

if (global.window_width <= 0) || (global.window_height <= 0)
{
    is_opened |= IS_OPENED_BOOLEAN.PAUSE;
    
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
    
    if (is_opened & IS_OPENED_BOOLEAN.MENU)
    {
        is_opened ^= IS_OPENED_BOOLEAN.MENU;
        
        var _layer = layer_get_id("Menu_Item");
        
        with (all)
        {
            if (layer == _layer)
            {
                instance_destroy();
            }
        }
    }
    
    control_instance_pause();
}
else if (keyboard_check_pressed(global.settings.input_keyboard_pause) && !(is_opened & IS_OPENED_BOOLEAN.CHAT))
{
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
    
    if (is_opened & IS_OPENED_BOOLEAN.MENU)
    {
        is_opened ^= IS_OPENED_BOOLEAN.MENU;
        
        var _layer = layer_get_id("Menu_Item");
        
        with (all)
        {
            if (layer == _layer)
            {
                instance_destroy();
            }
        }
    }
    else
    {
        is_opened ^= IS_OPENED_BOOLEAN.PAUSE;
        
        if (is_opened & IS_OPENED_BOOLEAN.PAUSE)
        {
            control_instance_pause();
            
            if (surface_refresh & SURFACE_REFRESH_BOOLEAN.PAUSE)
            {
                surface_refresh ^= SURFACE_REFRESH_BOOLEAN.PAUSE;
            }
            
            /* spawn pause ui */
            if (!variable_instance_exists(id, "ui_pause")) || (ui_pause == undefined)
            {
                var _pause_def = ui_load("ui/menu/pause.ui");
                
                if (_pause_def != undefined)
                {
                    ui_pause = ui_spawn(_pause_def, {
                        link: {},
                        parent: global.gui_root
                    });
                    
                    var _elements = ui_pause.elements;
                    
                    var _btn_resume = _elements[$ "btn_resume"];
                    
                    if (_btn_resume != undefined)
                    {
                        _btn_resume.add_event_handler("on_select_release", function()
                        {
                            obj_Game_Control.is_opened ^= IS_OPENED_BOOLEAN.PAUSE;
                            
                            control_instance_unpause();
                            
                            /* destroy pause ui */
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
                            /* open in-game settings menu */
                            obj_Game_Control.is_opened |= IS_OPENED_BOOLEAN.MENU;
                            
                            menu_refresh_instance_settings();
                        });
                    }
                    
                    var _btn_save_quit = _elements[$ "btn_save_quit"];
                    
                    if (_btn_save_quit != undefined)
                    {
                        _btn_save_quit.add_event_handler("on_select_release", function()
                        {
                            obj_Game_Control.is_opened |= IS_OPENED_BOOLEAN.EXIT;
                        });
                    }
                }
            }
        }
        else
        {
            control_instance_unpause();
            
            /* destroy pause ui */
            if (variable_instance_exists(id, "ui_pause")) && (ui_pause != undefined)
            {
                ui_instance_destroy(ui_pause);
                
                ui_pause = undefined;
            }
        }
    }
}