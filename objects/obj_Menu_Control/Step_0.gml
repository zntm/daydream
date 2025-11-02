var _menu_data = global.menu_data;

if (!audio_is_playing(global.menu_music))
{
    var _music = choose_weighted(_menu_data.music);
    
    var _gain = _music.gain;
    
    show_debug_message(_music.id);
    show_debug_message(struct_get_names(global.sound_asset));
    
    global.menu_music_gain = _gain;
    global.menu_music = audio_play_sound(global.sound_asset[$ _music.id].get_sound(), 0, false, _gain);
}