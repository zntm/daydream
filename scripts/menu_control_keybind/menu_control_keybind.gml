function menu_control_keybind()
{
    with (obj_Menu_Button)
    {
        // Only process buttons that are currently "selected" (waiting for input)
        // and have a 'setting_name' variable, indicating they are keybind buttons.
        if !(boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED) || (variable_instance_get(id, "setting_name") == undefined) continue;
        
        // If Escape is pressed, cancel the remapping
        if (keyboard_check_pressed(vk_escape))
        {
            sfx_play("phantasia:sfx/menu/button/deselect", global.settings.audio_ui);
            boolean ^= MENU_BUTTON_BOOLEAN.IS_SELECTED;
            
            // Revert text to original just in case (though it shouldn't have changed yet)
            var _current_key = global.settings[$ setting_name];
            var _key_name = input_get_name(_current_key);
            text = $"{display_text}: {_key_name}";
            
            exit;
        }
        
        // Determine text to show while waiting
        // We can just pulse or show "..." or similar if we want, but for now we'll stick to the current text or maybe "Press any key..."
        // actually let's make it obvious
        text = $"{display_text}: ...";
        
        if (keyboard_check_pressed(vk_anykey))
        {
            var _new_key = keyboard_lastkey;
            
            // Prevent binding to Escape since it's used for pause/cancel
            if (_new_key == vk_escape) 
            {
                exit; 
            }
            
            // Update setting
            global.settings[$ setting_name] = _new_key;
            
            // Save settings
            file_save_settings();
            
            // Update button text
            var _key_name = input_get_name(_new_key);
            text = $"{display_text}: {_key_name}";
            
            // Deselect
            boolean ^= MENU_BUTTON_BOOLEAN.IS_SELECTED;
            
            // Play success sound
            sfx_play("phantasia:sfx/menu/button/select", global.settings.audio_ui);
            
            exit;
        }
    }
}
