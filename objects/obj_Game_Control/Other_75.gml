var _id = async_load[? "id"];
var _status = async_load[? "status"];

if (variable_global_exists("async_save_map"))
{
    var _buffer = global.async_save_map[$ string(_id)];
    
    if (_buffer != undefined)
    {
        buffer_delete(_buffer);
        struct_remove(global.async_save_map, string(_id));
        
        if (_status < 0)
        {
            show_debug_message("[Backup] Async save failed for ID: " + string(_id));
        }
    }
}

if (variable_global_exists("async_chunk_save_map"))
{
    var _chunk = global.async_chunk_save_map[$ string(_id)];
    
    if (_chunk != undefined)
    {
        struct_remove(global.async_chunk_save_map, string(_id));
        
        _chunk.boolean &= ~CHUNK_BOOLEAN.SAVING;
        
        var _is_active = false;
        
        for (var i = chunk_in_view_length - 1; i >= 0; --i)
        {
            if (chunk_in_view[i] == _chunk)
            {
                _is_active = true;
                break;
            }
        }
        
        if (!_is_active)
        {
            global.chunk_pool.release(_chunk);
        }
        
        if (_status < 0)
        {
            show_debug_message("[Save] Async chunk save failed for ID: " + string(_id));
        }
    }
}
