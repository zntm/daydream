// Unregister from spatial hash map
chunk_map_unregister(id);

var _length = array_length(chunk_vertex_buffer);

for (var i = 0; i < _length; ++i)
{
    if (vertex_buffer_exists(chunk_vertex_buffer[i]))
    {
        vertex_delete_buffer(chunk_vertex_buffer[i]);
        
        chunk_vertex_buffer[i] = -1;
    }
}

if (surface_exists(surface_lighting))
{
    surface_free(surface_lighting);
}

if (surface_exists(chunk_covered_surface))
{
    surface_free(chunk_covered_surface);
}
