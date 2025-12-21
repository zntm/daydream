function file_save_settings()
{
    var _buffer = buffer_create(1024, buffer_grow, 1);
    
    buffer_write(_buffer, buffer_u32, 1); // Version
    
    var _names = struct_get_names(global.settings);
    var _length = array_length(_names);
    
    var _valid_settings = 0;
    
    // Calculate valid settings count first (or just filter them)
    // Actually, we should only save settings that are in our known categories to avoid garbage
    var _categories = struct_get_names(global.settings_data_category);
    var _settings_to_save = [];
    
    for (var i = 0; i < array_length(_categories); ++i)
    {
        var _cat_list = global.settings_data_category[$ _categories[i]];
        for (var j = 0; j < array_length(_cat_list); ++j)
        {
            array_push(_settings_to_save, _cat_list[j]);
        }
    }
    
    buffer_write(_buffer, buffer_u16, array_length(_settings_to_save));
    
    for (var i = 0; i < array_length(_settings_to_save); ++i)
    {
        var _name = _settings_to_save[i];
        var _val = global.settings[$ _name];
        
        buffer_write(_buffer, buffer_string, _name);
        buffer_write(_buffer, buffer_f32, _val);
    }
    
    buffer_save_compressed(_buffer, "settings.dat");
    buffer_delete(_buffer);
}
