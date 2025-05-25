function render_background()
{
    static __u_colour = shader_get_uniform(shd_Background, "u_colour");
    static __u_strength = shader_get_uniform(shd_Background, "u_strength");
    
    var _world = global.world;
    var _world_time = _world.time;
    
    var _world_data = global.world_data[$ _world.dimension];
    
    var _in_biome_data = global.biome_data[$ in_biome];
    var _in_biome_transition_data = global.biome_data[$ in_biome_transition];
    
    var _player_x = obj_Player.x;
    var _player_y = obj_Player.y;
    
    var _camera_x = global.camera_x;
    var _camera_y = global.camera_y;
    
    var _camera_width  = global.camera_width;
    var _camera_height = global.camera_height;
    
    var _sky_colour_base = c_black;
    var _sky_colour_gradient = c_black;
    
    var _time_diurnal_length = _world_data.get_time_diurnal_length();
    
    for (var i = 0; i < _time_diurnal_length; ++i)
    {
        var _name_from = _world_data.get_time_diurnal_name(i);
        
        var _start_from = _world_data.get_time_diurnal_start(_name_from);
        var _end_from = _world_data.get_time_diurnal_end(_name_from);
        
        if (_world_time >= _start_from) && (_world_time < _end_from)
        {
            var _name_to = _world_data.get_time_diurnal_name((i + 1) % _time_diurnal_length);
            
            var _start_to = _world_data.get_time_diurnal_start(_name_to);
            var _end_to = _world_data.get_time_diurnal_end(_name_to);
            
            var _colour_base_from = _in_biome_data.get_sky_colour_base(_name_from);
            var _colour_base_to = _in_biome_data.get_sky_colour_base(_name_to);
            
            var _colour_gradient_from = _in_biome_data.get_sky_colour_gradient(_name_from);
            var _colour_gradient_to = _in_biome_data.get_sky_colour_gradient(_name_to);
            
            var _t = normalize(_world_time, _start_from, _end_from);
            
            if (in_biome_transition_value <= 0)
            {
                _sky_colour_base = merge_colour(_colour_base_from, _colour_base_to, _t);
                _sky_colour_gradient = merge_colour(_colour_gradient_from, _colour_gradient_to, _t);
            }
            else
            {
                var _transition_colour_base_from = _in_biome_transition_data.get_sky_colour_base(_name_from);
                var _transition_colour_base_to = _in_biome_transition_data.get_sky_colour_base(_name_to);
                
                var _transition_colour_gradient_from = _in_biome_transition_data.get_sky_colour_gradient(_name_from);
                var _transition_colour_gradient_to = _in_biome_transition_data.get_sky_colour_gradient(_name_to);
                
                var _base = merge_colour(_colour_base_from, _colour_base_to, _t);
                var _gradient = merge_colour(_colour_gradient_from, _colour_gradient_to, _t);
                
                var _transition_base = merge_colour(_transition_colour_base_from, _transition_colour_base_to, _t);
                var _transition_gradient = merge_colour(_transition_colour_gradient_from, _transition_colour_gradient_to, _t);
                
                _sky_colour_base = merge_colour(_base, _transition_base, in_biome_transition_value);
                _sky_colour_gradient = merge_colour(_gradient, _transition_gradient, in_biome_transition_value);
            }
            
            break;
        }
    }
    
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
    
    var _in_biome_background = _in_biome_data.get_background();
    var _in_biome_background_data = _background_data[$ _in_biome_data.get_background()];
    
    var _in_biome_background_blend  = _in_biome_background_data.get_blend();
    var _in_biome_background_length = _in_biome_background_data.get_sprite_length();
    
    var _in_biome_transition_background = _in_biome_transition_data.get_background();
    var _in_biome_transition_background_data = _background_data[$ _in_biome_transition_data.get_background()];
    
    var _in_biome_transition_background_blend  = _in_biome_transition_background_data.get_blend();
    var _in_biome_transition_background_length = _in_biome_transition_background_data.get_sprite_length();
    
    if (in_biome_transition_value <= 0) || (_in_biome_background == _in_biome_background_data)
    {
        for (var i = 0; i < _in_biome_background_length; ++i)
        {
            shader_set_uniform_f(__u_strength, _in_biome_background_blend * (_in_biome_background_length - i + 1));
            
            render_background_parallax(_in_biome_background_data, i, _player_x, _camera_y, _camera_width, _camera_height, c_white, 1);
        }
    }
    else
    {
        var _length = max(_in_biome_background_length, _in_biome_transition_background_length);
        
        for (var i = 0; i < _length; ++i)
        {
            if (i < _in_biome_background_length)
            {
                shader_set_uniform_f(__u_strength, _in_biome_background_blend * (_in_biome_background_length - i + 1));
                
                render_background_parallax(_in_biome_background_data, i, _player_x, _camera_y, _camera_width, _camera_height, c_white, 1 - in_biome_transition_value);
            }
            
            if (i < _in_biome_transition_background_length)
            {
                shader_set_uniform_f(__u_strength, _in_biome_transition_background_blend * (_in_biome_transition_background_length - i + 1));
                
                render_background_parallax(_in_biome_transition_background_data, i, _player_x, _camera_y, _camera_width, _camera_height, c_white, in_biome_transition_value);
            }
        }
    }
    
    shader_reset();
}