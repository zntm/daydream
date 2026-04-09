input_bindings_init();

resource_rebuild_registry("phantasia");

global.settings = {}

global.settings_data = {}
global.settings_data_category = {}

function init_setting(_category, _type, _data)
{
    global.settings_data[$ _type] = _data;

    global.settings_data_category[$ _category] ??= [];

    array_push(global.settings_data_category[$ _category], _type);

    global.settings[$ _type] = _data.get_default_value();
}

global.loca_directories = resource_collect_loca_directories();

if (array_length(global.loca_directories) <= 0)
{
    global.loca_directories = [ "1. English (American)" ];
}
var _loca = global.loca_directories;

#region General

init_setting("general", "discord_rpc", new SettingsData(SETTINGS_TYPE.SWITCH, true)
    .set_on_press(function(_name, _value) {
    }));

init_setting("general", "menu_toast", new SettingsData(SETTINGS_TYPE.SWITCH, true));

init_setting("general", "menu_profanity_filter", new SettingsData(SETTINGS_TYPE.SWITCH, true));

init_setting("general", "menu_skip_epilepsy", new SettingsData(SETTINGS_TYPE.SWITCH, true));

init_setting("accessibility", "global_refresh_rate", new SettingsData(SETTINGS_TYPE.ARROW, 0)
    .add_values(60, 120, 144, 165, 240, 360)
    .set_on_update(function(_name, _value)
    {
        game_set_speed(global.settings_data[$ _name].get_value(_value), gamespeed_fps);
    }));

init_setting("accessibility", "global_localization", new SettingsData(SETTINGS_TYPE.ARROW, 0)
    .add_values(array_map(_loca, function(_value)
    {
        var _split = string_split(_value, ". ");
        return (array_length(_split) > 1) ? _split[1] : _value;
    }))
    .set_on_update(function(_name, _value)
    {
        resource_reload_loca(global.loca_directories[_value]);
    }));

#endregion

#region Graphics

init_setting("graphics", "display_background", new SettingsData(SETTINGS_TYPE.SWITCH, true));

init_setting("graphics", "display_coloured_lighting", new SettingsData(SETTINGS_TYPE.SWITCH, true));

init_setting("graphics", "display_blur", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

init_setting("graphics", "display_strength_particles", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

init_setting("graphics", "display_strength_weather", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

init_setting("graphics", "window_gui_size", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

init_setting("graphics", "window_fullscreen", new SettingsData(SETTINGS_TYPE.SWITCH, false)
    .set_on_release(function(_name, _value)
    {
        window_set_fullscreen(_value);
    }));

init_setting("graphics", "graphics_chunk_fade_time", new SettingsData(SETTINGS_TYPE.SLIDER, 0.5)
    .set_range(0, 3));

init_setting("graphics", "graphics_background_transition_speed", new SettingsData(SETTINGS_TYPE.SLIDER, 3)
    .set_range(0, 5));

init_setting("graphics", "graphics_menu_transition_fade_speed", new SettingsData(SETTINGS_TYPE.SLIDER, 0.35)
    .set_range(0, 5));

init_setting("graphics", "window_borderless", new SettingsData(SETTINGS_TYPE.SWITCH, false)
    .set_on_release(function(_name, _value)
    {
        window_set_showborder(!_value);
    }));

init_setting("graphics", "window_vsync", new SettingsData(SETTINGS_TYPE.SWITCH, true)
    .set_on_release(function(_name, _value)
    {
        display_reset(0, _value);
    }));

#endregion

#region Conrols

init_setting("controls", "input_keyboard_left",       new SettingsData(SETTINGS_TYPE.HOTKEY, ord("A")));

init_setting("controls", "input_keyboard_right",      new SettingsData(SETTINGS_TYPE.HOTKEY, ord("D")));

init_setting("controls", "input_keyboard_jump",       new SettingsData(SETTINGS_TYPE.HOTKEY, vk_space));

init_setting("controls", "input_keyboard_climb_up",   new SettingsData(SETTINGS_TYPE.HOTKEY, ord("W")));

init_setting("controls", "input_keyboard_climb_down", new SettingsData(SETTINGS_TYPE.HOTKEY, ord("S")));

init_setting("controls", "input_keyboard_pause",      new SettingsData(SETTINGS_TYPE.HOTKEY, vk_escape));

init_setting("controls", "input_keyboard_inventory",  new SettingsData(SETTINGS_TYPE.HOTKEY, ord("E")));

init_setting("controls", "input_keyboard_drop",       new SettingsData(SETTINGS_TYPE.HOTKEY, ord("Q")));

#endregion

#region Controls Gamepad

// Input type to show in controls menu: "keyboard", "gamepad", "touch"
global.controls_input_type = "keyboard";

init_setting("controls_gamepad", "input_gamepad_jump",       new SettingsData(SETTINGS_TYPE.HOTKEY, gp_face1));

init_setting("controls_gamepad", "input_gamepad_attack",     new SettingsData(SETTINGS_TYPE.HOTKEY, gp_face3));

init_setting("controls_gamepad", "input_gamepad_use",        new SettingsData(SETTINGS_TYPE.HOTKEY, gp_face2));

init_setting("controls_gamepad", "input_gamepad_mount",      new SettingsData(SETTINGS_TYPE.HOTKEY, gp_face4));

init_setting("controls_gamepad", "input_gamepad_pause",      new SettingsData(SETTINGS_TYPE.HOTKEY, gp_start));

init_setting("controls_gamepad", "input_gamepad_inventory",  new SettingsData(SETTINGS_TYPE.HOTKEY, gp_select));

#endregion

#region Audio

init_setting("audio", "audio_master", new SettingsData(SETTINGS_TYPE.SLIDER, 1)
    .set_on_update(function(_name, _value)
    {
        audio_master_gain(_value);
    }));

init_setting("audio", "audio_music", new SettingsData(SETTINGS_TYPE.SLIDER, 1)
    .set_on_update(function(_name, _value)
    {
        var _music = global.menu_music;

        if (audio_is_playing(_music))
        {
            audio_sound_gain(_music, global.menu_music_gain * _value, 0);
        }

        if (instance_exists(obj_Game_Control_Background))
        {
            with (obj_Game_Control_Background)
            {
                if (music_current != undefined) && audio_is_playing(music_current)
                {
                    audio_sound_gain(music_current, music_current_gain * _value, 0);
                }
            }
        }
    }));

init_setting("audio", "audio_sfx", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

init_setting("audio", "audio_ui", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

init_setting("audio", "audio_tile", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

init_setting("audio", "audio_creature_passive", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

init_setting("audio", "audio_creature_hostile", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

#endregion

#region Multiplayer

init_setting("multiplayer", "mp_host_port", new SettingsData(SETTINGS_TYPE.SLIDER, 6510)
    .set_range(1024, 65535));

init_setting("multiplayer", "mp_host_max_players", new SettingsData(SETTINGS_TYPE.SLIDER, 4)
    .set_range(2, 8));

init_setting("multiplayer", "mp_host_default_permission", new SettingsData(SETTINGS_TYPE.ARROW, SETTINGS_LEVEL.MIN)
    .add_values(SETTINGS_LEVEL.NONE, SETTINGS_LEVEL.MIN, SETTINGS_LEVEL.MAX));

init_setting("multiplayer", "mp_host_auto_forward", new SettingsData(SETTINGS_TYPE.SWITCH, true));

init_setting("multiplayer", "mp_host_advertise_public_ip", new SettingsData(SETTINGS_TYPE.SWITCH, true));

init_setting("multiplayer", "mp_host_allow_build", new SettingsData(SETTINGS_TYPE.SWITCH, true));

init_setting("multiplayer", "mp_host_allow_containers", new SettingsData(SETTINGS_TYPE.SWITCH, true));

#endregion

if (file_exists("settings.dat"))
{
    var _buffer = buffer_load_decompressed("settings.dat");

    var _version = buffer_read(_buffer, buffer_u32);

    var _length = buffer_read(_buffer, buffer_u16);

    repeat (_length)
    {
        var _name = buffer_read(_buffer, buffer_string);

        global.settings[$ _name] = buffer_read(_buffer, buffer_f32);
    }

    buffer_delete(_buffer);
}

audio_set_master_gain(0, global.settings.audio_master);

if (global.settings.global_localization >= array_length(global.loca_directories))
{
    global.settings.global_localization = 0;
}

resource_reload_loca(global.loca_directories[global.settings.global_localization]);
