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
