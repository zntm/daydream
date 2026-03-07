/// @desc Handles developer-mode network keybinds: F5 host, F6 join, F7 leave.
function control_game_debug_network()
{
    if (IS_MULTIPLAYER_ENABLED) && (keyboard_check_pressed(vk_f5))
    {
        if (global.relay == undefined) || (global.relay.role == RELAY_ROLE.NONE)
        {
            var _code = global.relay_manager.host_session(6510);

            if (_code != "")
            {
                chat_system_push($"Hosting session! Invite code: {invite_code_format(_code)}");
                invite_code_copy();
                chat_system_push("Invite code copied to clipboard");
            }
            else
            {
                chat_system_push("Failed to start session");
            }
        }
        else
        {
            chat_system_push("Already in a session");
        }
    }

    if (IS_MULTIPLAYER_ENABLED) && (keyboard_check_pressed(vk_f6))
    {
        if (global.relay == undefined) || (global.relay.role == RELAY_ROLE.NONE)
        {
            var _code = get_string("Enter Invite Code:", "");

            if (_code != "")
            {
                if (global.relay_manager.join_session(_code))
                {
                    chat_system_push("Connecting...");
                }
                else
                {
                    chat_system_push("Failed to join session - invalid code?");
                }
            }
        }
        else
        {
            chat_system_push("Already in a session");
        }
    }

    if (keyboard_check_pressed(vk_f7))
    {
        if (global.relay != undefined) && (global.relay.role != RELAY_ROLE.NONE)
        {
            global.relay_manager.leave_session();
            chat_system_push("Left session");
        }
    }
}
