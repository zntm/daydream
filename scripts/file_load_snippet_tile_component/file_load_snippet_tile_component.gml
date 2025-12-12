function file_load_snippet_tile_component(_buffer, _tile)
{
    var _component_length = buffer_read(_buffer, buffer_u8);
    
    for (var i = 0; i < _component_length; ++i)
    {
        var _name = buffer_read(_buffer, buffer_string);
        var _type = buffer_read(_buffer, buffer_u8);
        var _value;
        
        switch (_type)
        {
            case FILE_COMPONENT_TYPE.U8:
                _value = buffer_read(_buffer, buffer_u8);
                break;
            case FILE_COMPONENT_TYPE.U16:
                _value = buffer_read(_buffer, buffer_u16);
                break;
            case FILE_COMPONENT_TYPE.U32:
                _value = buffer_read(_buffer, buffer_u32);
                break;
            case FILE_COMPONENT_TYPE.U64:
                _value = buffer_read(_buffer, buffer_u64);
                break;
            case FILE_COMPONENT_TYPE.S8:
                _value = buffer_read(_buffer, buffer_s8);
                break;
            case FILE_COMPONENT_TYPE.S16:
                _value = buffer_read(_buffer, buffer_s16);
                break;
            case FILE_COMPONENT_TYPE.S32:
                _value = buffer_read(_buffer, buffer_s32);
                break;
            case FILE_COMPONENT_TYPE.F16:
                _value = buffer_read(_buffer, buffer_f16);
                break;
            case FILE_COMPONENT_TYPE.F32:
                _value = buffer_read(_buffer, buffer_f32);
                break;
            case FILE_COMPONENT_TYPE.F64:
                _value = buffer_read(_buffer, buffer_f64);
                break;
            case FILE_COMPONENT_TYPE.STRING:
                _value = buffer_read(_buffer, buffer_string);
                break;
        }
        
        _tile.set_tile_component(_name, _value);
    }
}