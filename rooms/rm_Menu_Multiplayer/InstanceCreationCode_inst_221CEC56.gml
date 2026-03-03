menu_anchor_position(x, y, GUI_ANCHOR.BOTTOM, room_width, room_height);

text = loca_translate("phantasia:menu.multiplayer.connect");

on_select_release = function()
{
    // Find invite code textbox
    var _code_textbox = noone;
    
    with (obj_Menu_Textbox)
    {
        if (placeholder == loca_translate("menu.multiplayer.textbox.invite_code"))
        {
            _code_textbox = id;
        }
    }
    
    if (_code_textbox != noone)
    {
        var _code = _code_textbox.text;
        
        // Remove dashes if formatted (e.g., "C0A8-0164-19E6" -> "C0A80164-19E6")
        _code = string_replace_all(_code, "-", "");
        _code = string_replace_all(_code, " ", "");
        
        if (string_length(_code) > 0)
        {
            PRINT($"[MENU] Joining session with code: {_code}");
            
            if (global.relay_manager.join_session(_code))
            {
                // Connection initiated
                PRINT("[MENU] Connection initiated...");
            }
            else
            {
                PRINT("[MENU] Failed to join session - invalid code?");
            }
        }
        else
        {
            PRINT("[MENU] Please enter an invite code");
        }
    }
    else
    {
        PRINT("[MENU] Could not find invite code textbox!");
    }
}