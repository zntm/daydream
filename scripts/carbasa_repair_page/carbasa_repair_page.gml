function carbasa_repair_page(_page)
{
    var _surface = global.carbasa_surface[$ _page];
    
    if (!surface_exists(_surface))
    {
        var _size = global.carbasa_surface_size[$ _page];
        
        _surface = surface_create(_size & 0xffff, (_size >> 16) & 0xffff);
        
        buffer_set_surface(global.carbasa_surface_buffer[$ _page], _surface, 0);
        
        global.carbasa_surface[$ _page] = _surface;
    }
    
    var _texture = global.carbasa_surface_texture[$ _page];
    
    if (!surface_exists(_texture))
    {
        _texture = surface_get_texture(_surface);
        
        global.carbasa_surface_texture[$ _page] = _texture;
        global.carbasa_surface_uv[$ _page] = texture_get_uvs(_texture);
    }
}