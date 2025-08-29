function menu_refresh_instance_players()
{
    static __on_draw = function(_x, _y, _colour)
    {
        var _data = global.file_players[index];
        
        var _halign = draw_get_halign();
        var _valign = draw_get_valign();
        
        draw_set_align(fa_left, fa_center);
        
        render_text(_x, _y - 10, string(loca_translate("phantasia:gui.hp.header"), _data.get_hp(), _data.get_hp_max()), 1, 1, 0, _colour, 1);
        
        draw_set_valign(fa_top);
        
        render_text(_x - 84, _y + 20, _data.get_name(), 1, 1, 0, _colour, 1);
        render_text(_x - 84, _y + 20 + 24, date_datetime_string(_data.get_last_opened()), 0.75, 0.75, 0, _colour, 1);
        
        render_attire(_data.get_attire(), 0, _x - 56, _y + 24, 3, 3);
        
        draw_set_align(_halign, _valign);
    }
    
    static __on_select_release = function()
    {
        var _data = global.file_players[index];
        
        var _uuid = _data.get_uuid();
        
        if (!directory_exists($"{PROGRAM_DIRECTORY_PLAYERS}/{_uuid}"))
        {
            var _inst_header = instance_create_layer(480, 224, "Instances", obj_Menu_Anchor);
            
            with (_inst_header)
            {
                text = loca_translate("phantasia:menu.players.error.not_existing");
                
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
                    file_load_players();
                    
                    with (obj_Menu_Button)
                    {
                        if (id[$ "is_option"])
                        {
                            instance_destroy();
                        }
                    }
                    
                    menu_refresh_instance_players();
                }
            }
            
            menu_popup_create([
                _inst_header,
                _inst_close
            ]);
            
            exit;
        }
        
        global.player_save_data.name = _data.get_name();
        
        global.player_save_data.hp = _data.get_hp();
        global.player_save_data.hp_max = _data.get_hp_max();
        
        global.player_save_data.attire = _data.get_attire();
        
        global.player_save_data.uuid = _uuid;
        
        menu_refresh_value_world_save();
        
        room_goto(rm_Menu_Worlds);
    }
    
    var _a = file_read_directory(PROGRAM_DIRECTORY_PLAYERS);
    var _b = global.file_players_uuid;
    
    if (!array_equals(_a, _b))
    {
        file_load_players();
    }
    
    var _players = global.file_players;
    var _players_length = array_length(_players);
    
    for (var i = 0; i < _players_length; ++i)
    {
        var _player = _players[i];
        
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