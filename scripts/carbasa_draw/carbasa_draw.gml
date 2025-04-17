function carbasa_draw(_page, _name, _index, _x, _y, _xscale, _yscale, _rotation, _colour, _alpha)
{
    static __u_colour       = shader_get_uniform(Shader1, "u_colour");
    static __u_rotation     = shader_get_uniform(Shader1, "u_rotation");
    static __u_scale        = shader_get_uniform(Shader1, "u_scale");
    static __u_translation  = shader_get_uniform(Shader1, "u_translation");
    static __u_translation_offset = shader_get_uniform(Shader1, "u_translation_offset");
    
    var _carbasa_page = global.carbasa_page[$ _page];
    
    if (_carbasa_page == undefined)
    {
        show_debug_message($"[CARBASA] - Page '{_page}' does not exist!");
        
        exit;
    }
    
    var _data = _carbasa_page[$ _name];
    
    if (_data == undefined)
    {
        show_debug_message($"[CARBASA] - Data for '{_name}' in page '{_page}' does not exist!");
        
        exit;
    }
    
    var _surface = global.carbasa_surface[$ _page];
    /*
    if (!surface_exists(_surface))
    {
        show_debug_message($"[CARBASA] - Surface '{_page}' does not exist!");
        
        var _size = global.carbasa_surface_size[$ _name];
        
        global.carbasa_surface[$ _page] = surface_create(_size, _size);
        
        buffer_set_surface(global.carbasa_surface_buffer[$ _page], global.carbasa_surface[$ _page], 0);
        
        _surface = global.carbasa_surface[$ _page];
    }
    */
    
    var _sprite_index = _data.sprite[_index];
    
    var _position = global.carbasa_page_position[$ _page][_sprite_index];
    
    var _xoffset = _position.get_xoffset();
    var _yoffset = _position.get_yoffset();
    
    shader_set(Shader1);
    
    shader_set_uniform_f(
        __u_translation,
        _x,
        _y
    );
    
    shader_set_uniform_f(
        __u_translation_offset,
        _xoffset,
        _yoffset
    );
    
    shader_set_uniform_f(
        __u_scale,
        _xscale,
        _yscale
    );
    
    shader_set_uniform_f(
        __u_rotation,
        _rotation * (pi / 180)
    );
    
    shader_set_uniform_f(
        __u_colour,
        ((_colour >>  0) & 0xff) / 255,
        ((_colour >>  8) & 0xff) / 255,
        ((_colour >> 16) & 0xff) / 255,
        _alpha
    );
    
    vertex_submit_ext(
        global.carbasa_page_vertex_buffer[$ _page],
        pr_trianglelist,
        global.carbasa_surface_texture[$ _page],
        _sprite_index * 6,
        6
    );
    
    shader_reset();
}