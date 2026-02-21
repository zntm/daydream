function file_save_snippet_component_value(_buffer, _type_id, _value)
{
    switch (_type_id)
    {
        case FILE_COMPONENT_TYPE.U8:
            buffer_write(_buffer, buffer_u8, _value);
            
            break;
        
        case FILE_COMPONENT_TYPE.U16:
            buffer_write(_buffer, buffer_u16, _value);
            
            break;
        
        case FILE_COMPONENT_TYPE.U32:
            buffer_write(_buffer, buffer_u32, _value);
            
            break;
        
        case FILE_COMPONENT_TYPE.U64:
            buffer_write(_buffer, buffer_u64, _value);
            
            break;
        
        case FILE_COMPONENT_TYPE.S8:
            buffer_write(_buffer, buffer_s8, _value);
            
            break;
        
        case FILE_COMPONENT_TYPE.S16:
            buffer_write(_buffer, buffer_s16, _value);
            
            break;
        
        case FILE_COMPONENT_TYPE.S32:
            buffer_write(_buffer, buffer_s32, _value);
            
            break;
        
        case FILE_COMPONENT_TYPE.F16:
            buffer_write(_buffer, buffer_f16, _value);
            
            break;
        
        case FILE_COMPONENT_TYPE.F32:
            buffer_write(_buffer, buffer_f32, _value);
            
            break;
        
        case FILE_COMPONENT_TYPE.F64:
            buffer_write(_buffer, buffer_f64, _value);
            
            break;
        
        case FILE_COMPONENT_TYPE.STRING:
            buffer_write(_buffer, buffer_string, _value);
            
            break;
    }
}
