function sfx_play(_id, _gain = global.settings.audio_sfx)
{
    var _sfx_data = global.sfx_data;
    
    var _data = _sfx_data[$ _id];
    
    if (_data == undefined) exit;
    
    return audio_play_sound_ext({
        sound: array_choose(_data.get_asset()),
        pitch: smart_value(_data.get_pitch()),
        gain: clamp(global.settings.audio_master * _gain, 0, 1)
    });
}