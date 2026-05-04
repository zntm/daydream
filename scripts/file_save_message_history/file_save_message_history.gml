function file_save_message_history()
{
    var _buffer = buffer_create(1024, buffer_grow, 1);
    
    /* header */
    buffer_write(_buffer, buffer_u32, PROGRAM_VERSION_NUMBER);
    buffer_write(_buffer, buffer_f64, datetime_to_unix());
    
    /* write input history */
    var _history = global.message_history;
    var _length  = array_length(_history);
    
    buffer_write(_buffer, buffer_u16, _length);
    
    for (var i = _length - 1; i >= 0; --i)
    {
        buffer_write(_buffer, buffer_string, _history[i]);
    }
    
    /* save to appdata */
    buffer_save_compressed(_buffer, $"{PROGRAM_DIRECTORY_APPDATA}/chat_history.dat");
    
    buffer_delete(_buffer);
}
