function file_load_snippet_tile(_buffer, _item_data)
{
    var _id = buffer_read(_buffer, buffer_string);
    
    if (_id == "")
    {
        return undefined;
    }
    
    var _seed = buffer_read(_buffer, buffer_u32);
    
    var _value = buffer_read(_buffer, buffer_u32);
}