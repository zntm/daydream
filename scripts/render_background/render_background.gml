function render_background(_camera_x, _camera_y, _camera_width, _camera_height)
{
    static __u_colour = shader_get_uniform(shd_Background, "u_colour");
    static __u_strength = shader_get_uniform(shd_Background, "u_strength");
    
    var _background_data = global.background_data;
    var _player_x = obj_Player.x;
    var _player_y = obj_Player.y;
    
    shader_set(shd_Background);
    
    shader_set_uniform_f(__u_colour, (sky_colour_base & 0xff) / 0xff, ((sky_colour_base >> 8) & 0xff) / 0xff, ((sky_colour_base >> 16) & 0xff) / 0xff);
    
<<<<<<< HEAD
    if (_in_biome_data == undefined) || (_in_biome_transition_data == undefined)
    {
        shader_reset();
        return;
    }
    
    var _in_biome_background = _in_biome_data.get_background();
    // var _in_biome_background_data = _background_data[$ _in_biome_background];
=======
    var _in_biome_background = worldgen_get_background(in_biome);
    if (_in_biome_background == undefined) return;
>>>>>>> region
    
    var _in_biome_background_id = _in_biome_background.id;
    var _in_biome_background_blend = _in_biome_background.blend;
    var _in_biome_background_data = global.sprite_asset[$ _in_biome_background_id];
    
    var _in_biome_background_length = array_length(_in_biome_background_data);
    
    var _in_biome_transition_background = worldgen_get_background(in_biome_transition);
    if (_in_biome_transition_background == undefined) return;
    
    var _in_biome_transition_background_id = _in_biome_transition_background.id;
    var _in_biome_transition_background_blend = _in_biome_transition_background.blend;
    var _in_biome_transition_background_data = global.sprite_asset[$ _in_biome_transition_background_id];
    
    var _in_biome_transition_background_length = array_length(_in_biome_transition_background_data);
    
    if (in_biome_transition_value <= 0) || (_in_biome_background_id == _in_biome_transition_background_id)
    {
        for (var i = 0; i < _in_biome_background_length; ++i)
        {
            shader_set_uniform_f(__u_strength, _in_biome_background_blend * (1 - ((i + 1) / _in_biome_background_length)));
            
            render_background_parallax(_in_biome_background_data[i].get_sprite(), i, _player_x, _camera_y, _camera_x, _camera_y, _camera_width, _camera_height, c_white, 1);
        }
    }
    else
    {
        var _length = max(_in_biome_background_length, _in_biome_transition_background_length);
        
        for (var i = 0; i < _length; ++i)
        {
            if (i < _in_biome_background_length)
            {
                shader_set_uniform_f(__u_strength, _in_biome_background_blend * (1 - ((i + 1) / _in_biome_background_length)));
                
                render_background_parallax(_in_biome_background_data[i].get_sprite(), i, _player_x, _camera_y, _camera_x, _camera_y, _camera_width, _camera_height, c_white, 1 - in_biome_transition_value);
            }
            
            if (i < _in_biome_transition_background_length)
            {
                shader_set_uniform_f(__u_strength, _in_biome_transition_background_blend * (1 - ((i + 1) / _in_biome_transition_background_length)));
                
                render_background_parallax(_in_biome_transition_background_data[i].get_sprite(), i, _player_x, _camera_y, _camera_x, _camera_y, _camera_width, _camera_height, c_white, in_biome_transition_value);
            }
        }
    }
    
    shader_reset();
}