function bg_play_music(_music)
{
    music_current    = audio_play_sound(global.music_data[$ _music].get_audio(), 0, false, 0);
    music_current_id = _music;
    
    audio_sound_gain(music_current, global.settings.audio_master * global.settings.audio_music, BACKGROUND_MUSIC_FADE_TIME);
}