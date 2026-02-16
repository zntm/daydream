function file_load_snippet_component_value(_buffer, _type_id)
{
    switch (_type_id)
    {
        case FILE_COMPONENT_TYPE.U8:
            return buffer_read(_buffer, buffer_u8);
        
        case FILE_COMPONENT_TYPE.U16:
            return buffer_read(_buffer, buffer_u16);
        
        case FILE_COMPONENT_TYPE.U32:
            return buffer_read(_buffer, buffer_u32);
        
        case FILE_COMPONENT_TYPE.U64:
            return buffer_read(_buffer, buffer_u64);
        
        case FILE_COMPONENT_TYPE.S8:
            return buffer_read(_buffer, buffer_s8);
        
        case FILE_COMPONENT_TYPE.S16:
            return buffer_read(_buffer, buffer_s16);
        
        case FILE_COMPONENT_TYPE.S32:
            return buffer_read(_buffer, buffer_s32);
        
        case FILE_COMPONENT_TYPE.F16:
            return buffer_read(_buffer, buffer_f16);
        
        case FILE_COMPONENT_TYPE.F32:
            return buffer_read(_buffer, buffer_f32);
        
        case FILE_COMPONENT_TYPE.F64:
            return buffer_read(_buffer, buffer_f64);
        
        case FILE_COMPONENT_TYPE.STRING:
            return buffer_read(_buffer, buffer_string);
        
        default:
            return undefined;
    }
}
