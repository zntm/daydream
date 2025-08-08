function file_save_player_global(_directory, _player_name, _player_attire, _player_hp, _player_hp_max, _player_saturation, _player_effects, _hotbar = 0)
{
    var _buffer = buffer_create(0xff, buffer_grow, 1);
    
    buffer_write(_buffer, buffer_u16, PROGRAM_VERSION_MAJOR);
    buffer_write(_buffer, buffer_u16, PROGRAM_VERSION_MINOR);
    buffer_write(_buffer, buffer_u16, PROGRAM_VERSION_PATCH);
    buffer_write(_buffer, buffer_u16, PROGRAM_VERSION_TYPE);
    
    buffer_write(_buffer, buffer_f64, datetime_to_unix());
    
    buffer_write(_buffer, buffer_string, _player_name);
    
    var _names  = global.attire_elements;
    var _length = array_length(_names);
    
    for (var i = 0; i < _length; ++i)
    {
        var _name   = _names[i];
        var _attire = _player_attire[$ _name];
        
        buffer_write(_buffer, buffer_string, _name);
        
        buffer_write(_buffer, buffer_u16, _attire.colour);
        
        if (_name != "body")
        {
            buffer_write(_buffer, buffer_u16, _attire.index);
        }
    }
    
    buffer_write(_buffer, buffer_u16, _player_hp);
    buffer_write(_buffer, buffer_u16, _player_hp_max);
    
    buffer_write(_buffer, buffer_u16, _player_saturation);
    
    file_save_snippet_effects(_buffer, _player_effects);
    
    buffer_write(_buffer, buffer_u8, _hotbar);
    
    buffer_save_compressed(_buffer, $"{_directory}/global.dat");
    
    buffer_delete(_buffer);
}