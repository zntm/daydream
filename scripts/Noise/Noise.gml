function Noise(_xoffset, _yoffset, _xsize, _ysize, _amplitude, _octave, _roughness, _seed) constructor
{
    static __u_noise  = shader_get_uniform(shd_Noise, "u_noise");
    static __u_offset = shader_get_uniform(shd_Noise, "u_offset");
    
    static __u_roughness = shader_get_uniform(shd_Noise, "u_roughness");
    
    static __surface = -1;
    static __surface_xsize = -1;
    static __surface_ysize = -1;
    
    if (!surface_exists(__surface))
    {
        __surface = surface_create(_xsize, _ysize, surface_r8unorm);
        
        __surface_xsize = _xsize;
        __surface_ysize = _ysize;
    }
    else if (_xsize != __surface_xsize) || (_ysize != __surface_ysize)
    {
        surface_resize(__surface, _xsize, _ysize);
        
        __surface_xsize = _xsize;
        __surface_ysize = _ysize;
    }
    
    ___xsize = _xsize;
    ___ysize = _ysize;
    
    ___amplitude = _amplitude / 255;
    
    ___buffer = buffer_create(_xsize * _ysize, buffer_fast, 1);
    
    surface_set_target(__surface);
    shader_set(shd_Noise);
    
    shader_set_uniform_f(__u_noise, _octave, _seed / 0x2109);
    shader_set_uniform_f(__u_offset, _xoffset, _yoffset); 
    shader_set_uniform_i(__u_roughness, _roughness); 
    
    draw_sprite_ext(spr_Square, 0, 0, 0, _xsize, _ysize, 0, c_red, 1);
    
    surface_reset_target();
    shader_reset();
    
    buffer_get_surface(___buffer, __surface, 0);
    
    static get = function(_x, _y)
    {
        return buffer_peek(___buffer, (_y * ___xsize) + _x, buffer_u8) * ___amplitude;
    }
    
    static __free = function()
    {
        buffer_delete(___buffer);
    }
}