function bg_play_music(_music)
{
    var _audio = global.music_data[$ _music.id].get_audio();
    
    music_current    = audio_play_sound(_audio, 0, false, 0);
    music_current_id = _music;
    
    audio_sound_gain(music_current, global.settings.audio_music * _music.gain, BACKGROUND_MUSIC_FADE_TIME);
}