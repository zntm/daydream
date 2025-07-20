#macro GUI_PAUSE_BLUR_RESIZE 4

function render_pause()
{
    static __u_direction  = shader_get_uniform(shd_Separable_Blur, "u_direction");
    static __u_blur_size  = shader_get_uniform(shd_Separable_Blur, "u_blur_size");
    static __u_texel_size = shader_get_uniform(shd_Separable_Blur, "u_texel_size");
    static __u_radius     = shader_get_uniform(shd_Separable_Blur, "u_radius");
    static __u_sigma      = shader_get_uniform(shd_Separable_Blur, "u_sigma");
    
    var _width  = ceil(global.gui_width  / GUI_PAUSE_BLUR_RESIZE);
    var _height = ceil(global.gui_height / GUI_PAUSE_BLUR_RESIZE);
    
    if (!surface_exists(surface_pause[@ 0]))
    {
        surface_pause[@ 0] = surface_create(_width, _height);
    }
    
    var _texel_width  = 1 / _width;
    var _texel_height = 1 / _height;
    
    surface_set_target(surface_pause[@ 0]);
    draw_clear_alpha(c_black, 0);
    
    shader_set(shd_Separable_Blur);
    
    shader_set_uniform_f(__u_direction, 1, 0);
    shader_set_uniform_f(__u_blur_size, 1);
    shader_set_uniform_f(__u_texel_size, _texel_width, _texel_height);
    shader_set_uniform_i(__u_radius, 3);
    shader_set_uniform_f(__u_sigma, 32);
    
    draw_surface_ext(application_surface, 0, 0, 1 / GUI_PAUSE_BLUR_RESIZE, 1 / GUI_PAUSE_BLUR_RESIZE, 0, c_white, 1);
    
    shader_reset();
    
    surface_reset_target();
    
    if (!surface_exists(surface_pause[@ 1]))
    {
        surface_pause[@ 1] = surface_create(_width, _height);
    }
    
    surface_set_target(surface_pause[@ 1]);
    draw_clear_alpha(c_black, 0);
    
    shader_set(shd_Separable_Blur);
    
    shader_set_uniform_f(__u_direction, 0, 1);
    shader_set_uniform_f(__u_blur_size, 1);
    shader_set_uniform_f(__u_texel_size, _texel_width, _texel_height);
    shader_set_uniform_i(__u_radius, 3);
    shader_set_uniform_f(__u_sigma, 32);
    
    draw_surface(surface_pause[@ 0], 0, 0);
    
    shader_reset();
    
    surface_reset_target();
}