function render_menu_background(_id, _colour)
{
    static __u_colour = shader_get_uniform(shd_Background, "u_colour");
    static __u_strength = shader_get_uniform(shd_Background, "u_strength");
    
    var _biome_data = global.biome_data[$ _id];
    
    var _sky_colour_base = _biome_data.get_sky_colour_base(_colour);
    var _sky_colour_gradient = _biome_data.get_sky_colour_gradient(_colour);
    
    draw_sprite_ext(spr_Square, 0, 0, 0, room_width, room_height, 0, _sky_colour_base, 1);
    draw_sprite_general(spr_Glow_Corner, 0, 0, 0, 128, 1, 0, room_height, room_height / 128, room_width, 90, _sky_colour_gradient, _sky_colour_gradient, _sky_colour_gradient, _sky_colour_gradient, 1);
    
    if (global.settings.display_background)
    {
        var _light_colour = _biome_data.get_light_colour(_colour);
        
        var _background = _biome_data.get_background();
        var _background_data = global.background_data[$ _background];
        
        var _background_blend  = _background_data.get_blend();
        var _background_length = _background_data.get_sprite_length();
        
        shader_set(shd_Background);
        
        shader_set_uniform_f(__u_colour, (_sky_colour_base & 0xff) / 0xff, ((_sky_colour_base >> 8) & 0xff) / 0xff, ((_sky_colour_base >> 16) & 0xff) / 0xff);
        
        for (var i = 0; i < _background_length; ++i)
        {
            shader_set_uniform_f(__u_strength, _background_blend * (1 - ((i + 1) / _background_length)));
            
            render_background_parallax(_background_data, i, offset, 0, 0, 0, room_width, room_height, _light_colour, 1);
        }
        
        shader_reset();
    }
}