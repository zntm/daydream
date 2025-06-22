function sfx_play(_id, _gain = 1)
{
    var _sfx_data = global.sfx_data;
    
    var _data = _sfx_data[$ _id];
    
    if (_data == undefined) exit;
    
    return audio_play_sound_ext({
        sound: array_choose(_data.get_asset()),
        pitch: smart_value(_data.get_pitch()),
        gain: _gain
    });
}