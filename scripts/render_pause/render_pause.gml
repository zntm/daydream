function render_pause()
{
    static __u_direction  = shader_get_uniform(shd_Separable_Blur, "u_direction");
    static __u_blur_size  = shader_get_uniform(shd_Separable_Blur, "u_blur_size");
    static __u_texel_size = shader_get_uniform(shd_Separable_Blur, "u_texel_size");
    static __u_radius     = shader_get_uniform(shd_Separable_Blur, "u_radius");
    static __u_sigma      = shader_get_uniform(shd_Separable_Blur, "u_sigma");
    
    if (!surface_exists(surface_pause))
    {
        surface_pause = surface_create(window_width, window_height);
    }
    
    var _texel_width  = 1 / window_width;
    var _texel_height = 1 / window_height;
    
    surface_set_target(surface_pause);
    draw_clear_alpha(c_black, 0);
    
    shader_set(shd_Separable_Blur);
    
    shader_set_uniform_f(__u_direction, 1, 0);
    shader_set_uniform_f(__u_blur_size, 2);
    shader_set_uniform_f(__u_texel_size, _texel_width, _texel_height);
    shader_set_uniform_i(__u_radius, 12);
    shader_set_uniform_f(__u_sigma, 8);
    
    draw_surface(application_surface, 0, 0);
    
    shader_reset();
    
    surface_reset_target();
    
    shader_set(shd_Separable_Blur);
    
    shader_set_uniform_f(__u_direction, 0, 1);
    shader_set_uniform_f(__u_blur_size, 2);
    shader_set_uniform_f(__u_texel_size, _texel_width, _texel_height);
    shader_set_uniform_i(__u_radius, 12);
    shader_set_uniform_f(__u_sigma, 8);
    
    draw_surface(surface_pause, 0, 0);
    
    shader_reset();
}