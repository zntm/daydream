var _names  = struct_get_names(global.carbasa_surface_buffer);
var _length = array_length(_names);

for (var i = 0; i < _length; ++i)
{
    var _page = _names[i];
    
    if (!surface_exists(global.carbasa_surface[$ _page]))
    {
        var _size = global.carbasa_surface_size[$ _page];
        
        global.carbasa_surface[$ _page] = surface_create(_size & 0xffff, (_size >> 16) & 0xffff);
        
        buffer_set_surface(global.carbasa_surface_buffer[$ _page], global.carbasa_surface[$ _page], 0);
        
        global.carbasa_surface_texture[$ _page] = surface_get_texture(global.carbasa_surface[$ _page]);
        
        global.carbasa_surface_uv[$ _page] = texture_get_uvs(global.carbasa_surface_texture[$ _page]);
    }
    
    show_debug_message(global.carbasa_surface[$ _page])
}