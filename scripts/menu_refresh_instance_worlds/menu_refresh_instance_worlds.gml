function menu_refresh_instance_worlds()
{
    static __on_draw = function(_x, _y)
    {
        var _data = global.file_worlds[index];
        
        var _halign = draw_get_halign();
        var _valign = draw_get_valign();
        
        draw_set_align(fa_left, fa_top);
        
        render_text(_x, _y - 64, _data.get_name());
        render_text(_x, _y - 32, date_datetime_string(_data.get_last_opened()));
        
        render_text(_x, _y, date_datetime_string(_data.get_last_opened()));
        
        draw_set_align(_halign, _valign);
    }
    
    static __on_select_release = function()
    {
        var _data = global.file_worlds[index];
        
        var _uuid = _data.get_uuid();
        
        show_debug_message(_uuid);
        
        if (!directory_exists($"{PROGRAM_DIRECTORY_WORLDS}/{_uuid}"))
        {
            var _inst_header = instance_create_layer(480, 224, "Instances", obj_Menu_Anchor);
            
            with (_inst_header)
            {
                text = loca_translate("phantasia:menu.worlds.error.not_existing");
                
                menu_layer = 1;
                
                on_draw = function(_x, _y, _xscale, _yscale)
                {
                    var _x2 = x * _xscale;
                    var _y2 = y * _yscale;
                    
                    var _halign = draw_get_halign();
                    var _valign = draw_get_valign();
                    
                    draw_set_align(fa_center, fa_middle);
                    
                    render_text(_x2, _y2, text, _xscale, _yscale);
                    
                    draw_set_align(_halign, _valign);
                }
            }
            
            var _inst_close = instance_create_layer(480, 300, "Instances", obj_Menu_Button);
            
            with (_inst_close)
            {
                text = loca_translate("phantasia:menu.generic.close");
                
                image_xscale = 17;
                image_yscale = 3;
                
                menu_layer = 1;
                
                on_select_release = function()
                {
                    menu_popup_destroy();
                    file_load_worlds();
                    
                    with (obj_Menu_Button)
                    {
                        if (id[$ "is_option"])
                        {
                            instance_destroy();
                        }
                    }
                    
                    menu_refresh_instance_worlds();
                }
            }
            
            menu_popup_create([
                _inst_header,
                _inst_close
            ]);
            
            exit;
        }
        
        global.world_save_data.name = _data.get_name();
        global.world_save_data.seed = _data.get_seed();
        
        global.world_save_data.dimension = _data.get_dimension();
        
        global.world_save_data.time = _data.get_time();
        global.world_save_data.day  = _data.get_day();
        
        global.world_save_data.weather_wind  = _data.get_weather_wind();
        global.world_save_data.weather_storm = _data.get_weather_storm();
        
        global.world_save_data.uuid = _uuid;
        
        room_goto(rm_World);
    }
    
    var _a = file_read_directory(PROGRAM_DIRECTORY_WORLDS);
    var _b = global.file_worlds_uuid;
    
    if (!array_equals(_a, _b))
    {
        file_load_worlds();
    }
    
    var _worlds = global.file_worlds;
    var _worlds_length = array_length(_worlds);
    
    for (var i = 0; i < _worlds_length; ++i)
    {
        var _world = _worlds[i];
        
        var _xoffset = floor(i % 4) * 208;
        var _yoffset = floor(i / 4) * 160;
        
        with (instance_create_layer(176 + _xoffset, 184 + _yoffset, "Instances", obj_Menu_Button))
        {
            image_xscale = 12;
            image_yscale = 9;
            
            is_option = true;
            
            index = i;
            
            on_draw = method(id, __on_draw);
            on_select_release = method(id, __on_select_release);
        }
    }
}