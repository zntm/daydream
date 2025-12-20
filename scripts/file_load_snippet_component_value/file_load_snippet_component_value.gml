function file_load_snippet_component_value(_buffer, _type_id)
{
    var _value = undefined;
    
    switch (_type_id)
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
    
    return _value;
}
