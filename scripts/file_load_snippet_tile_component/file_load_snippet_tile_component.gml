function file_load_snippet_tile_component(_buffer, _tile)
{
    var _component_length = buffer_read(_buffer, buffer_u8);
    
    for (var i = 0; i < _component_length; ++i)
    {
        var _name = buffer_read(_buffer, buffer_string);
        
        var _type = buffer_read(_buffer, buffer_u8);
        
        if (_type == FILE_COMPONENT_TYPE.NUMBER)
        {
            _tile.set_tile_component(_name, buffer_read(_buffer, buffer_f64));
        }
        else if (_type == FILE_COMPONENT_TYPE.STRING)
        {
            _tile.set_tile_component(_name, buffer_read(_buffer, buffer_string));
        }
    }
}