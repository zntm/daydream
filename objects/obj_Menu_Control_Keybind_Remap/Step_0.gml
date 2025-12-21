// Cancel Logic
if (keyboard_check(vk_escape))
{
    cancel_timer++;
    if (cancel_timer >= cancel_threshold)
    {
        // Cancelled
        sfx_play("phantasia:sfx/menu/button/deselect", global.settings.audio_ui);
        instance_destroy();
        exit;
    }
}
else
{
    cancel_timer = 0;
}

// Bind Logic
if (cancel_timer == 0 && keyboard_check_released(vk_anykey))
{
    var _key = keyboard_lastkey;
    
    global.settings[$ setting_name] = _key;
    file_save_settings();
    
    sfx_play("phantasia:sfx/menu/button/select", global.settings.audio_ui);
    
    if (button_id != undefined && instance_exists(button_id))
    {
        button_id.text = input_get_name(_key);
    }
    
    instance_destroy();
}
