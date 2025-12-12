global.sfx_temp_emitters = [];

function sfx_emitter_cleanup()
{
    var _emitters = global.sfx_temp_emitters;
    var _length = array_length(_emitters);
    
    for (var i = _length - 1; i >= 0; --i)
    {
        var _entry = _emitters[i];
        
        if (!audio_is_playing(_entry.sound))
        {
            if (audio_emitter_exists(_entry.emitter))
            {
                audio_emitter_free(_entry.emitter);
            }
            
            array_delete(_emitters, i, 1);
        }
    }
}

function sfx_emitter_track(_emitter, _sound)
{
    array_push(global.sfx_temp_emitters, {
        emitter: _emitter,
        sound: _sound
    });
}