global.settings = {}

global.settings_data = {}
global.settings_data_category = {}

function init_setting(_category, _type, _setting)
{
    global.settings_data[$ _type] = _setting;
    
    global.settings_data_category[$ _category] ??= [];
    
    array_push(global.settings_data_category[$ _category], _type);
    
    global.settings[$ _type] = _setting.get_default_value();
}

var _loca = file_read_directory($"{PROGRAM_DIRECTORY_RESOURCES}\\loca");

#region General

init_setting("general", "discord_rpc", new SettingsData(SETTINGS_TYPE.SWITCH, true)
    .set_on_press(function(_name, _value) {
    }));

init_setting("general", "menu_toast", new SettingsData(SETTINGS_TYPE.SWITCH, true));

init_setting("general", "menu_profanity_filter", new SettingsData(SETTINGS_TYPE.SWITCH, true));

init_setting("general", "menu_skip_epilepsy", new SettingsData(SETTINGS_TYPE.SWITCH, false));

#endregion

#region Graphics

init_setting("graphics", "display_background", new SettingsData(SETTINGS_TYPE.SWITCH, true));

init_setting("graphics", "display_coloured_lighting", new SettingsData(SETTINGS_TYPE.SWITCH, true));

init_setting("graphics", "display_blur", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

init_setting("graphics", "particles", new SettingsData(SETTINGS_TYPE.ARROW, 1));

init_setting("graphics", "weather", new SettingsData(SETTINGS_TYPE.ARROW, 1));

init_setting("graphics", "window_gui_size", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

init_setting("graphics", "window_fullscreen", new SettingsData(SETTINGS_TYPE.SWITCH, false)
    .set_on_press(function(_name, _value)
    {
    }));

init_setting("graphics", "window_borderless", new SettingsData(false, SETTINGS_TYPE.SWITCH)
    .set_on_press(function(_name, _value)
    {
    }));

init_setting("graphics", "window_vsync", new SettingsData(true, SETTINGS_TYPE.SWITCH)
    .set_on_press(function(_name, _value)
    {
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

#region Audio

init_setting("audio", "audio_master", new SettingsData(SETTINGS_TYPE.SLIDER, 1)
    .set_on_update(function(_name, _value)
    {
    }));

init_setting("audio", "audio_music", new SettingsData(SETTINGS_TYPE.SLIDER, 1)
    .set_on_update(function(_name, _value)
    {
    }));

init_setting("audio", "audio_sfx", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

init_setting("audio", "audio_ui", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

init_setting("audio", "audio_tile", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

init_setting("audio", "audio_creature_passive", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

init_setting("audio", "audio_creature_hostile", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

#endregion

if (file_exists("settings.dat"))
{
    var _buffer = buffer_load_decompressed("settings.dat");
    
    var _version_major = buffer_read(_buffer, buffer_u8);
    var _version_minor = buffer_read(_buffer, buffer_u8);
    var _version_patch = buffer_read(_buffer, buffer_u8);
    var _version_type  = buffer_read(_buffer, buffer_u8);
    
    var _length = buffer_read(_buffer, buffer_u16);
    
    repeat (_length)
    {
        var _name = buffer_read(_buffer, buffer_string);
        
        global.settings[$ _name] = buffer_read(_buffer, buffer_f32);
    }
    
    buffer_delete(_buffer);
}

init_loca($"{PROGRAM_DIRECTORY_RESOURCES}\\loca\\{_loca[0]}", "phantasia");