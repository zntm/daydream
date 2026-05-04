function buffer_load_text(_directory)
{
    if (!file_exists(_directory))
    {
        return undefined;
    }
    
    var _buffer = buffer_load(_directory);
    
    if (_buffer == -1)
    {
        return undefined;
    }
    
    var _text = buffer_read(_buffer, buffer_text);
    
    buffer_delete(_buffer);
    
    return _text;
}
