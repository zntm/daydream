function Noise(_xoffset, _yoffset, _xsize, _ysize, _amplitude, _octave, _roughness, _seed) constructor
{
    static __u_noise  = shader_get_uniform(shd_Noise, "u_noise");
    static __u_offset = shader_get_uniform(shd_Noise, "u_offset");
    static __u_roughness = shader_get_uniform(shd_Noise, "u_roughness");
    
    ___xsize = _xsize;
    ___ysize = _ysize;
    
    ___amplitude = _amplitude / 255;
    
    var _surface = surface_create(_xsize, _ysize, surface_r8unorm);
    var _buffer = buffer_create(_xsize * _ysize, buffer_fast, 1);
    
    surface_set_target(_surface);
    shader_set(shd_Noise);
    
    shader_set_uniform_f(__u_noise, _octave, _seed / 0x8109);
    shader_set_uniform_f(__u_offset, _xoffset, _yoffset); 
    shader_set_uniform_i(__u_roughness, _roughness); 
    
    draw_sprite_ext(spr_Square, 0, 0, 0, _xsize, _ysize, 0, c_red, 1);
    
    surface_reset_target();
    shader_reset();
    
    buffer_get_surface(_buffer, _surface, 0);
    
    ___noise = array_create(___xsize * ___ysize);
    
    for (var i = 0; i < _xsize; ++i)
    {
        for (var j = 0; j < _ysize; ++j)
        {
            var _index = (j * _xsize) + i;
            
            ___noise[@ _index] = buffer_peek(_buffer, _index, buffer_u8) * ___amplitude;
        }
    }
    
    surface_free(_surface);
    buffer_delete(_buffer);
    
    static get = function(_x, _y)
    {
        return ___noise[(_y * ___xsize) + _x];
    }
}