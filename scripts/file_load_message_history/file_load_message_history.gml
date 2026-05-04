function file_load_message_history()
{
    var _path = $"{PROGRAM_DIRECTORY_APPDATA}/chat_history.dat";
    
    if (!file_exists(_path)) exit;
    
    var _buffer = buffer_load_decompressed(_path);
    
    try
    {
        var _version   = buffer_read(_buffer, buffer_u32);
        var _timestamp = buffer_read(_buffer, buffer_f64);
        var _length    = buffer_read(_buffer, buffer_u16);
        
        global.message_history = array_create(_length);
        
        for (var i = _length - 1; i >= 0; --i)
        {
            global.message_history[@ i] = buffer_read(_buffer, buffer_string);
        }
        
        /* reset navigation index */
        obj_Game_Control.chat_message_history_index = _length;
    }
    catch (_error)
    {
        PRINT($"Failed to load chat history: {_error}");
    }
    
    buffer_delete(_buffer);
}
