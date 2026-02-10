var _menu_data = global.menu_data;

if (!audio_is_playing(global.menu_music))
{
    var _music = choose_weighted(_menu_data.music);
    
    var _gain = _music.gain;
    
    global.menu_music_gain = _gain;
    global.menu_music = audio_play_sound(global.sound_asset[$ _music.id].get_sound(), 0, false, _gain);
}

// Ensure GUI variables are set (since obj_Game_Control might not be present)
global.gui_mouse_x = device_mouse_x_to_gui(0);
global.gui_mouse_y = device_mouse_y_to_gui(0);

// Update menu transition animation
menu_transition_update();
