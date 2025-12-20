function file_load_snippet_item_component(_buffer, _item)
{
    var _component_length = buffer_read(_buffer, buffer_u8);
    
    for (var i = 0; i < _component_length; ++i)
    {
        var _name = buffer_read(_buffer, buffer_string);
        var _type_header = buffer_read(_buffer, buffer_u8);
        
        var _is_array = (_type_header & 128) != 0;
        var _type_id = _type_header & 127; // Mask out the array flag
        
        var _value;
        
        if (_is_array)
        {
            var _array_length = buffer_read(_buffer, buffer_u16);
            _value = array_create(_array_length);
            
            for (var j = 0; j < _array_length; ++j)
            {
                _value[@ j] = file_load_snippet_component_value(_buffer, _type_id);
            }
        }
        else
        {
            _value = file_load_snippet_component_value(_buffer, _type_id);
        }
        
        _item.set_item_component(_name, _value);
    }
}