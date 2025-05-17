global.settings = {}

global.settings_data = {}
global.settings_data_category = {}

function init_setting(_category, _type, _setting)
{
    global.settings_data_category[$ _category] ??= [];
    
    array_push(global.settings_data_category[$ _category], _type);
    
    global.settings_data[$ _type] = _setting;
}

#region General

init_setting("general", "discord_rpc", new SettingsData(SETTINGS_TYPE.SWITCH, true)
    .set_on_press(function(_name, _value) {
    }));

init_setting("general", "toast_notification", new SettingsData(SETTINGS_TYPE.SWITCH, true));

init_setting("general", "profanity_filter", new SettingsData(SETTINGS_TYPE.SWITCH, true));

init_setting("general", "skip_warning", new SettingsData(SETTINGS_TYPE.SWITCH, false));

#endregion

#region Graphics

init_setting("graphics", "display_background", new SettingsData(SETTINGS_TYPE.SWITCH, true));

init_setting("graphics", "particles", new SettingsData(SETTINGS_TYPE.ARROW, SETTINGS_LEVEL.MAX)
    .add_values(SETTINGS_LEVEL.NONE, SETTINGS_LEVEL.MIN, SETTINGS_LEVEL.MAX));

init_setting("graphics", "weather", new SettingsData(SETTINGS_TYPE.ARROW, SETTINGS_LEVEL.MAX)
    .add_values(SETTINGS_LEVEL.NONE, SETTINGS_LEVEL.MIN, SETTINGS_LEVEL.MAX));

init_setting("graphics", "display_coloured_lighting", new SettingsData(SETTINGS_TYPE.SWITCH, true));

init_setting("graphics", "window_gui_size", new SettingsData(SETTINGS_TYPE.ARROW, "960x540")
    .add_values("960x540", "1280x720", "1366x768", "1920x1080"));

init_setting("graphics", "window_fullscreen", new SettingsData(SETTINGS_TYPE.SWITCH, false)
    .set_on_press(function(_name, _value)
    {
    }));

init_setting("graphics", "borderless", new SettingsData(false, SETTINGS_TYPE.SWITCH)
    .set_on_press(function(_name, _value)
    {
    }));

init_setting("graphics", "vsync", new SettingsData(false, SETTINGS_TYPE.SWITCH)
    .set_on_press(function(_name, _value)
    {
    }));

#endregion

#region Conrols

init_setting("controls", "key_left",       new SettingsData(SETTINGS_TYPE.HOTKEY, ord("A")));

init_setting("controls", "key_right",      new SettingsData(SETTINGS_TYPE.HOTKEY, ord("W")));

init_setting("controls", "key_jump",       new SettingsData(SETTINGS_TYPE.HOTKEY, vk_space));

init_setting("controls", "key_climb_up",   new SettingsData(SETTINGS_TYPE.HOTKEY, ord("Q")));

init_setting("controls", "key_climb_down", new SettingsData(SETTINGS_TYPE.HOTKEY, ord("A")));

init_setting("controls", "key_pause",      new SettingsData(SETTINGS_TYPE.HOTKEY, vk_escape));

init_setting("controls", "key_inventory",  new SettingsData(SETTINGS_TYPE.HOTKEY, ord("Q")));

init_setting("controls", "key_drop",       new SettingsData(SETTINGS_TYPE.HOTKEY, ord("Q")));

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

init_setting("audio", "audio_blocks", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

init_setting("audio", "audio_creature_passive", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

init_setting("audio", "audio_creature_hostile", new SettingsData(SETTINGS_TYPE.SLIDER, 1));

#endregion