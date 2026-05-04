function file_save_settings()
{
    var _buffer = buffer_create(1024, buffer_grow, 1);
    
    buffer_write(_buffer, buffer_u32, 1);
    
    var _categories       = struct_get_names(global.settings_data_category);
    var _settings_to_save = [];
    
    for (var i = array_length(_categories) - 1; i >= 0; --i)
    {
        var _cat_list = global.settings_data_category[$ _categories[i]];
        
        for (var j = array_length(_cat_list) - 1; j >= 0; --j)
        {
            array_push(_settings_to_save, _cat_list[j]);
        }
    }
    
    var _settings_length = array_length(_settings_to_save);
    
    buffer_write(_buffer, buffer_u16, _settings_length);
    
    for (var i = _settings_length - 1; i >= 0; --i)
    {
        var _name = _settings_to_save[i];
        var _val  = global.settings[$ _name];
        
        buffer_write(_buffer, buffer_string, _name);
        buffer_write(_buffer, buffer_f32,    _val);
    }
    
    buffer_save_compressed(_buffer, "settings.dat");
    
    buffer_delete(_buffer);
}
