function file_save_player_game(_directory, _hp, _hp_max, _effects = 0, _hotbar = 0)
{
    var _buffer = buffer_create(0xff, buffer_grow, 1);
    
    buffer_write(_buffer, buffer_u8, PROGRAM_VERSION_MAJOR);
    buffer_write(_buffer, buffer_u8, PROGRAM_VERSION_MINOR);
    buffer_write(_buffer, buffer_u8, PROGRAM_VERSION_PATCH);
    buffer_write(_buffer, buffer_u8, PROGRAM_VERSION_TYPE);
    
    buffer_write(_buffer, buffer_u16, _hp);
    buffer_write(_buffer, buffer_u16, _hp_max);
    
    var _effects_names  = struct_get_names(_effects);
    var _effects_length = array_length(_effects_names);
    
    buffer_write(_buffer, buffer_u16, _effects_length);
    
    for (var i = 0; i < _effects_length; ++i)
    {
        var _name = _effects_names[i];
        
        buffer_write(_buffer, buffer_string, _name);
        
        var _seek = buffer_tell(_buffer);
        
        buffer_write(_buffer, buffer_u32, 0);
        
        var _effect = _effects[$ _name];
        
        if (_effect == undefined)
        {
            buffer_write(_buffer, buffer_u8, 0);
            
            continue;
        }
        
        buffer_write(_buffer, buffer_u8, (_effect.has_particle << 7) | _effect.level);
        buffer_write(_buffer, buffer_f32, _effect.timer);
        
        buffer_poke(_buffer, _seek, buffer_u32, buffer_tell(_buffer));
    }
    
    buffer_write(_buffer, buffer_u8, _hotbar);
    
    buffer_save_compressed(_buffer, $"{_directory}/game.dat");
    
    buffer_delete(_buffer);
}