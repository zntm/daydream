function file_save_snippet_component(_buffer, _tile)
{
    static __file_component_type = global.file_component_type;
    
    var _data = global.item_data[$ _tile.get_id()];
    
    var _component_length = _data.get_components_length();
    
    buffer_write(_buffer, buffer_u8, _component_length);
    
    if (_component_length > 0)
    {
        var _names = _data.get_components_names();
        
        for (var i = 0; i < _component_length; ++i)
        {
            var _name = _names[i];
            
            buffer_write(_buffer, buffer_string, _name);
            
            var _component = _tile.get_component(_name) ?? _data.get_component(_name)[$ "default"];
            
            var _type = __file_component_type[$ typeof(_component)];
            
            buffer_write(_buffer, buffer_u8, _type);
            
            if (_type == FILE_COMPONENT_TYPE.NUMBER)
            {
                buffer_write(_buffer, buffer_f64, _component);
            }
            else if (_type == FILE_COMPONENT_TYPE.STRING)
            {
            	buffer_write(_buffer, buffer_string, _component);
            }
        }
    }
}