var _menu_data = global.menu_data;

if (!audio_array_is_playing(_menu_data.music_audio))
{
    var _music = choose_weighted(_menu_data.music);
    
    audio_play_sound(global.music_data[$ _music.id].get_audio(), 0, false, global.settings.audio_sfx * _music.gain);
}