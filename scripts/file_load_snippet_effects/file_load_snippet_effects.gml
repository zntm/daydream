function file_load_snippet_effects(_buffer, _inst)
{
    var _effects_length = buffer_read(_buffer, buffer_u16);
    
    if (_effects_length <= 0)
    {
        return undefined;
    }
    
    var _effects = _inst.effects;
    var _data = {}
    
    for (var i = 0; i < _effects_length; ++i)
    {
        var _name = buffer_read(_buffer, buffer_string);
        var _seek = buffer_read(_buffer, buffer_u32);
        
        var _level = buffer_read(_buffer, buffer_u8);
        
        if (_level <= 0) continue;
        
        var _boolean = buffer_read(_buffer, buffer_u64);
        var _time = buffer_read(_buffer, buffer_f64);
        
        _data[$ _name] = {
            level: _level,
            boolean: _boolean,
            time: _time
        }
    }
    
    return _data;
}