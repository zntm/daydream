function menu_refresh_instance_players()
{
    static __on_draw = function(_x, _y)
    {
        var _data = global.file_players[index];
        
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
        var _data = global.file_players[index];
        
        global.player_save_data = _data.get_attire();
        
        menu_refresh_value_world_save();
        menu_refresh_instance_worlds();
        
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
            
            index = i;
            
            on_draw = method(id, __on_draw);
            on_select_release = method(id, __on_select_release);
        }
    }
}