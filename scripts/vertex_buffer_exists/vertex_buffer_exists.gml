function vertex_buffer_exists(_buffer)
{
    try
    {
        return (typeof(_buffer) == "ref") && !!(vertex_get_buffer_size(_buffer));
    }
    catch (_error)
    {
        return false;
    }
}