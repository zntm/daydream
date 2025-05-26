function tag_get(_data)
{
    if (!is_string(_data)) || (!string_starts_with(_data, "#"))
    {
        return _data;
    }
    
    return global.tag_data[$ _data];
}