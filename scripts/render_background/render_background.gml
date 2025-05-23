function render_background(_in_biome)
{
    static __u_colour = shader_get_uniform(shd_Background, "u_colour");
    static __u_strength = shader_get_uniform(shd_Background, "u_strength");
    
    var _in_biome_data = global.biome_data[$ _in_biome.id];
    
    var _player_x = obj_Player.x;
    var _player_y = obj_Player.y;
    
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    var _camera_width  = global.camera_width;
    var _camera_height = global.camera_height;
    
    var _sky_colour_base = _in_biome_data.get_sky_colour_base("day");
    var _sky_colour_gradient = _in_biome_data.get_sky_colour_gradient("day");
    
    draw_sprite_ext(
        spr_Square,
        0,
        _camera_x,
        _camera_y,
        _camera_width,
        _camera_height,
        0,
        _sky_colour_base,
        1
    );
    
    draw_sprite_general(
        spr_Glow_Corner,
        0,
        0,
        0,
        128,
        1,
        _camera_x,
        _camera_y + _camera_height,
        _camera_height / 128,
        _camera_width,
        90,
        _sky_colour_gradient,
        _sky_colour_gradient,
        _sky_colour_gradient,
        _sky_colour_gradient,
        1
    );
    
    shader_set(shd_Background);
    
    shader_set_uniform_f(__u_colour, ((_sky_colour_base >> 0) & 0xff) / 0xff, ((_sky_colour_base >> 8) & 0xff) / 0xff, ((_sky_colour_base >> 16) & 0xff) / 0xff);
    
    var _background_data = global.background_data;
    
    var _in_biome_background = _background_data[$ _in_biome_data.get_background()];
    var _in_biome_background_length = _in_biome_background.get_sprite_length();
    
    for (var i = 0; i < _in_biome_background_length; ++i)
    {
        shader_set_uniform_f(__u_strength, 0.1 * (_in_biome_background_length - i + 1));
        
        var _sprite_width  = _in_biome_background.get_sprite_width(i);
        var _sprite_height = _in_biome_background.get_sprite_height(i);
        
        var _xoffset = (_player_x * (i + 1) * 0.05) % _sprite_width;
        
        var _xsize = ceil(_camera_width / _sprite_width) + 1;
        
        render_background_parallax(_in_biome_background.get_sprite(i), _player_x + _xoffset, _camera_y + _camera_height, _sprite_width, _sprite_height, _xsize, 0, c_white, 1);
    }
    
    shader_reset();
}