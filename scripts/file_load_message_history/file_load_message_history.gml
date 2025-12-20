function file_load_message_history()
{
    var _path = $"{PROGRAM_DIRECTORY_APPDATA}/chat_history.dat";
    
    if (!file_exists(_path)) return;
    
    var _buffer = buffer_load_decompressed(_path);
    
    try
    {
        var _version = buffer_read(_buffer, buffer_u32);
        var _timestamp = buffer_read(_buffer, buffer_f64);
        var _length = buffer_read(_buffer, buffer_u16);
        
        global.chat_history = array_create(_length);
        
        for (var i = 0; i < _length; ++i)
        {
            var _name = buffer_read(_buffer, buffer_string);
            if (_name == "") _name = undefined;
            
            var _message = buffer_read(_buffer, buffer_string);
            var _colour = buffer_read(_buffer, buffer_u32);
            
            global.chat_history[i] = new Chat(_name, _message).set_colour(_colour);
            global.chat_history[i].add_timer(-100000); // Ensure expired
        }
    }
    catch (_error)
    {
        show_debug_message($"Failed to load chat history: {_error}");
    }
    finally
    {
        buffer_delete(_buffer);
    }
}
