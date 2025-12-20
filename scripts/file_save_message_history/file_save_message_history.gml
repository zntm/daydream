function file_save_message_history()
{
    var _buffer = buffer_create(1024, buffer_grow, 1);
    
    // Header
    buffer_write(_buffer, buffer_u32, PROGRAM_VERSION_NUMBER);
    buffer_write(_buffer, buffer_f64, datetime_to_unix());
    
    var _history = global.chat_history;
    var _length = array_length(_history);
    
    buffer_write(_buffer, buffer_u16, _length);
    
    for (var i = 0; i < _length; ++i)
    {
        var _chat = _history[i];
        
        // Ensure name is string
        var _name = _chat.get_name();
        if (_name == undefined) _name = "";
        
        buffer_write(_buffer, buffer_string, _name);
        buffer_write(_buffer, buffer_string, _chat.get_message());
        
        // Colour
        var _colour = _chat.get_colour();
        if (_colour == undefined) _colour = c_white;
        buffer_write(_buffer, buffer_u32, _colour);
    }
    
    // Save to AppData
    buffer_save_compressed(_buffer, $"{PROGRAM_DIRECTORY_APPDATA}/chat_history.dat");
    
    buffer_delete(_buffer);
}
