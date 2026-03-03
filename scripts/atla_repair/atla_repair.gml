function atla_repair(_page)
{
    var _atla_page = global.___atla_page[$ _page];
    
    if (_atla_page == undefined)
    {
        PRINT($"[ATLA] Page '{_page}' does not exist!");
        
        exit;
    }
    
    var _surface = global.___atla_surface[$ _page];
    
    if (!surface_exists(_surface))
    {
        var _surface_size = global.___atla_surface_size[$ _page];
        
        var _surface_width  = (_surface_size >> 0)  & 0xffff;
        var _surface_height = (_surface_size >> 16) & 0xffff;
        
        var _buffer = global.___atla_surface_buffer[$ _page];
        
        if (!buffer_exists(_buffer))
        {
            _buffer = buffer_create(_surface_width * _surface_height * 4, buffer_fast, 1);
        }
        
        _surface = surface_create(_surface_width, _surface_height);
        
        buffer_set_surface(_buffer, _surface, 0);
        
        var _texture = surface_get_texture(_surface);
        
        global.___atla_surface[$ _page] = _surface;
        global.___atla_surface_buffer[$ _page] = _buffer;
        global.___atla_surface_texture[$ _page] = _texture;
        global.___atla_surface_uvs[$ _page] = texture_get_uvs(_texture);
    }
}