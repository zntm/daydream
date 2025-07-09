function file_save_snippet_effects(_buffer, _effects)
{
    if (_effects == undefined)
    {
        buffer_write(_buffer, buffer_u16, 0);
        
        exit;
    }
    
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
        
        buffer_write(_buffer, buffer_u8, _effect.has_particle);
        buffer_write(_buffer, buffer_u8, _effect.level);
        buffer_write(_buffer, buffer_f32, _effect.timer);
        
        buffer_poke(_buffer, _seek, buffer_u32, buffer_tell(_buffer));
    }
    
}