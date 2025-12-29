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

// Gamepad Bind Logic
if (is_gamepad && cancel_timer == 0)
{
    var _slot = global.player_gamepad_slot;
    if (gamepad_is_connected(_slot))
    {
        // Check all possible gamepad buttons
        var _buttons = [gp_face1, gp_face2, gp_face3, gp_face4, 
                       gp_shoulderl, gp_shoulderr, gp_shoulderlb, gp_shoulderrb,
                       gp_start, gp_select, gp_stickl, gp_stickr,
                       gp_padu, gp_padd, gp_padl, gp_padr];
        
        for (var i = 0; i < array_length(_buttons); i++)
        {
            if (gamepad_button_check_pressed(_slot, _buttons[i]))
            {
                var _btn = _buttons[i];
                global.settings[$ setting_name] = _btn;
                file_save_settings();
                
                sfx_play("phantasia:sfx/menu/button/select", global.settings.audio_ui);
                
                if (button_id != undefined && instance_exists(button_id))
                {
                    button_id.text = input_get_gamepad_name(_btn);
                }
                
                instance_destroy();
                exit;
            }
        }
    }
}
// Keyboard Bind Logic
else if (!is_gamepad && cancel_timer == 0 && keyboard_check_released(vk_anykey))
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
