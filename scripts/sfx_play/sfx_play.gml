function sfx_play(_id, _gain = 1)
{
    var _data = global.sound_asset[$ _id];
    
    if (_data == undefined) exit;
    
    return audio_play_sound_ext({
        sound: is_array_choose(_data).get_sound(),
        // pitch: smart_value(_data.get_pitch()),
        gain: _gain// * _data.get_gain()
    });
}