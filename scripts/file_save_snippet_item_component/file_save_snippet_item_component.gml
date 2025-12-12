function file_save_snippet_item_component(_buffer, _item)
{
    var _data = global.item_data[$ _item.get_id()];
    
    var _component_length = _data.get_item_components_length();
    
    buffer_write(_buffer, buffer_u8, _component_length);
    
    if (_component_length > 0)
    {
        var _names = _data.get_item_components_names();
        var _components = _data.get_item_components();
        
        for (var i = 0; i < _component_length; ++i)
        {
            var _name = _names[i];
            var _component_def = _components[$ _name];
            var _type_str = _component_def[$ "type"];
            var _value = _item.get_item_component(_name) ?? _component_def[$ "default"];
            
            buffer_write(_buffer, buffer_string, _name);
            
            switch (_type_str)
            {
                case "u8":
                    buffer_write(_buffer, buffer_u8, FILE_COMPONENT_TYPE.U8);
                    buffer_write(_buffer, buffer_u8, _value);
                    break;
                case "u16":
                    buffer_write(_buffer, buffer_u8, FILE_COMPONENT_TYPE.U16);
                    buffer_write(_buffer, buffer_u16, _value);
                    break;
                case "u32":
                    buffer_write(_buffer, buffer_u8, FILE_COMPONENT_TYPE.U32);
                    buffer_write(_buffer, buffer_u32, _value);
                    break;
                case "u64":
                    buffer_write(_buffer, buffer_u8, FILE_COMPONENT_TYPE.U64);
                    buffer_write(_buffer, buffer_u64, _value);
                    break;
                case "s8":
                    buffer_write(_buffer, buffer_u8, FILE_COMPONENT_TYPE.S8);
                    buffer_write(_buffer, buffer_s8, _value);
                    break;
                case "s16":
                    buffer_write(_buffer, buffer_u8, FILE_COMPONENT_TYPE.S16);
                    buffer_write(_buffer, buffer_s16, _value);
                    break;
                case "s32":
                    buffer_write(_buffer, buffer_u8, FILE_COMPONENT_TYPE.S32);
                    buffer_write(_buffer, buffer_s32, _value);
                    break;
                case "f16":
                    buffer_write(_buffer, buffer_u8, FILE_COMPONENT_TYPE.F16);
                    buffer_write(_buffer, buffer_f16, _value);
                    break;
                case "f32":
                    buffer_write(_buffer, buffer_u8, FILE_COMPONENT_TYPE.F32);
                    buffer_write(_buffer, buffer_f32, _value);
                    break;
                case "f64":
                    buffer_write(_buffer, buffer_u8, FILE_COMPONENT_TYPE.F64);
                    buffer_write(_buffer, buffer_f64, _value);
                    break;
                case "string":
                    buffer_write(_buffer, buffer_u8, FILE_COMPONENT_TYPE.STRING);
                    buffer_write(_buffer, buffer_string, _value);
                    break;
            }
        }
    }
}