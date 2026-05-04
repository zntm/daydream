function buffer_load_json(_directory)
{
    try
    {
        var _text = buffer_load_text(_directory);
        
        return json_parse(_text);
    }
    catch (_error)
    {
        return -1;
    }
}
