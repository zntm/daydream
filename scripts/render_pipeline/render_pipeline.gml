// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function render_pipeline()
{
    var _texture = global.carbasa_surface_texture[$ "item"];
    
    for (var _z = 0; _z < CHUNK_DEPTH; ++_z)
    {
        var _bitmask = 1 << _z;
        
        with (obj_Chunk)
        {
            if (!is_in_view) || ((chunk_surface_display & _bitmask) == 0) continue;
            
            if (!vertex_buffer_exists(chunk_vertex_buffer[_z]))
            {
                render_chunk(global.carbasa_surface_uv[$ "item"], id, _z);
            }
            
            var _buffer = chunk_vertex_buffer[_z];
            
            if (chunk_render & _bitmask) && (vertex_buffer_exists(_buffer))
            {
                vertex_submit(_buffer, pr_trianglelist, _texture);
            }
        }
    }
}