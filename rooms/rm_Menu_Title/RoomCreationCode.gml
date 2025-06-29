var _audio = global.music_data[$ "phantasia:phantasia"].get_audio();

if (!audio_is_playing(_audio))
{
    audio_play_sound(_audio, 0, true, global.settings.audio_music);
}