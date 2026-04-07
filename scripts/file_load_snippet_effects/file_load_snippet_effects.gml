/// @function file_load_snippet_effects(_buffer)
/// @desc Load effect data from a buffer using the new format
/// @param {Id.Buffer} _buffer - The buffer to read from
/// @returns {Struct|undefined} Effect data struct or undefined if no effects
function file_load_snippet_effects(_buffer)
{
    var _effects_length = buffer_read(_buffer, buffer_u16);
    
    if (_effects_length <= 0)
    {
        return undefined;
    }
    
    var _data = {}
    
    for (var i = 0; i < _effects_length; ++i)
    {
        var _name  = buffer_read(_buffer, buffer_string);
        var _seek  = buffer_read(_buffer, buffer_u32);
        var _level = buffer_read(_buffer, buffer_u8);
        
        if (_level <= 0) continue;
        
        var _timer    = buffer_read(_buffer, buffer_f64);
        var _particle = buffer_read(_buffer, buffer_bool);
        
        _data[$ _name] = {
            level: _level,
            timer: _timer,
            duration_max: _timer,
            particle: _particle
        }
    }
    
    return _data;
}
