function buffer_load_json(_directory)
{
    try
    {
        return json_parse(buffer_load_text(_directory));
    }
    catch (_error)
    {
        return -1;
    }
}