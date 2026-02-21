function file_save_snippet_item_component(_buffer, _item)
{
    var _data = global.item_data[$ _item.get_id()];
    
    var _component_length = _data.get_item_components_length();
    
    buffer_write(_buffer, buffer_u8, _component_length);
    
    if (_component_length > 0)
    {
        var _names      = _data.get_item_components_names();
        var _components = _data.get_item_components();
        
        for (var i = 0; i < _component_length; ++i)
        {
            var _name          = _names[i];
            var _component_def = _components[$ _name];
            var _type_str      = _component_def[$ "type"];
            var _value         = _item.get_item_component(_name) ?? _component_def[$ "default"];
            
            buffer_write(_buffer, buffer_string, _name);
            
            var _type_id  = global.file_component_type[$ _type_str];
            var _is_array = _component_def[$ "is_array"] ?? false;
            
            /* if it's an array, add the array flag (0x80) */
            if (_is_array)
            {
                buffer_write(_buffer, buffer_u8, _type_id | 128); /* 128 is 0x80 */
                
                var _array_length = array_length(_value);
                
                buffer_write(_buffer, buffer_u16, _array_length);
                
                for (var j = 0; j < _array_length; ++j)
                {
                    file_save_snippet_component_value(_buffer, _type_id, _value[j]);
                }
            }
            else
            {
                buffer_write(_buffer, buffer_u8, _type_id);
                
                file_save_snippet_component_value(_buffer, _type_id, _value);
            }
        }
    }
}