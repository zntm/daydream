var _menu_data = global.menu_data;

if (!audio_is_playing(global.menu_music))
{
    var _music = choose_weighted(_menu_data.music);
    
    var _gain = _music.gain;
    
    global.menu_music_gain = _gain;
    global.menu_music = audio_play_sound(global.music_data[$ _music.id].get_audio(), 0, false, _gain);
}