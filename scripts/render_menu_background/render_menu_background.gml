function render_menu_background(_id, _colour)
{
    gpu_set_blendmode_ext_sepalpha(bm_src_alpha, bm_inv_src_alpha, bm_src_alpha, bm_one);
    
    static __u_colour = shader_get_uniform(shd_Background, "u_colour");
    static __u_strength = shader_get_uniform(shd_Background, "u_strength");
    
    // Color lookups now handle IDs robustly
    
    var _sky_colour = worldgen_get_sky_colour(_id, _colour);
    var _light_colour = worldgen_get_light_colour(_id, _colour);
    
    var _sky_colour_base = _sky_colour;
    var _sky_colour_gradient = _sky_colour;
    
    draw_sprite_ext(spr_Square, 0, 0, 0, room_width, room_height, 0, _sky_colour_base, 1);
    draw_sprite_general(spr_Glow_Corner, 0, 0, 0, 128, 1, 0, room_height, room_height / 128, room_width, 90, _sky_colour_gradient, _sky_colour_gradient, _sky_colour_gradient, _sky_colour_gradient, 1);
    
    if (global.settings.display_background)
    {
        var _offset = global.menu_background_offset;
        
        var _background = worldgen_get_background(_id);
        if (_background == undefined) exit;
        
        var _background_sprites = global.sprite_asset[$ _background.id];
        if (_background_sprites == undefined)
        {
            PRINT($"render_menu_background: Background asset not found: {_background.id}");
            exit;
        }
        
        var _background_blend  = _background.blend;
        var _background_length = array_length(_background_sprites);
        
        shader_set(shd_Background);
        
        shader_set_uniform_f(__u_colour, (_sky_colour_base & 0xff) / 0xff, ((_sky_colour_base >> 8) & 0xff) / 0xff, ((_sky_colour_base >> 16) & 0xff) / 0xff);
        
        for (var i = 0; i < _background_length; ++i)
        {
            shader_set_uniform_f(__u_strength, _background_blend * (1 - ((i + 1) / _background_length)));
            
            var _sprite_asset = _background_sprites[i];
            if (_sprite_asset != undefined)
            {
                render_background_parallax(_sprite_asset.get_sprite(), i, _offset, 0, 0, 0, room_width, room_height, c_white, 1);
            }
        }
        
        shader_reset();
    }
    
    gpu_set_blendmode_ext(bm_dest_colour, bm_zero);
    
    draw_sprite_ext(spr_Square, 0, 0, 0, room_width, room_height, 0, _light_colour, 1);
    
    gpu_set_blendmode(bm_normal);
}