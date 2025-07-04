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
        global.world_save_data = global.file_worlds[index];
        
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
            
            index = i;
            
            on_draw = method(id, __on_draw);
            on_select_release = method(id, __on_select_release);
        }
    }
}