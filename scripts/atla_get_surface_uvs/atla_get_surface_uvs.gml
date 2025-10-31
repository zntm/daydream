function atla_get_surface_uvs(_page, _name)
{
    var _surface_texture = global.___atla_surface_texture[$ _page];
    
    if (_surface_texture != undefined) || (!surface_exists(_surface_texture))
    {
        show_debug_message($"[ATLA] Surface '{_page}' does not exist!");
        
        exit;
    }
    
    return global.___atla_surface_uvs[$ _page];
}