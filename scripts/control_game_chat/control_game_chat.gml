/// @desc Handles all chat input for this frame: opening, sending messages, navigating history, autocomplete.
function control_game_chat()
{
    var _gc = obj_Game_Control;

    if (_gc.is_opened & WORLD_OPENED_BOOL.CHAT)
    {
        _gc.chat_message = keyboard_string;

        chat_refresh_suggestions();

        if (keyboard_check_pressed(vk_enter))
        {
            var _message = string_trim(_gc.chat_message);

            if (string_length(_message) > 0)
            {
                if (string_char_at(_message, 1) == CHAT_COMMAND_PREFIX)
                {
                    chat_command_execute(string_delete(_message, 1, 1));
                }
                else
                {
                    chat_user_push(global.current_player.name, _message);
                }

                array_insert(global.message_history, 0, _message);

                if (array_length(global.message_history) > 50)
                {
                    array_resize(global.message_history, 50);
                }
            }

            chat_disable();
        }
        else if (keyboard_check_pressed(vk_escape))
        {
            chat_disable();
        }
        else if (keyboard_check_pressed(vk_up))
        {
            if (global.gui_panel_choices != undefined) && (global.gui_panel_choices.visible)
            {
                global.gui_panel_choices.selected_index = max(0, global.gui_panel_choices.selected_index - 1);
            }
            else
            {
                var _history        = global.message_history;
                var _history_length = array_length(_history);

                if (_history_length > 0) && (_gc.chat_message_history_index > 0)
                {
                    _gc.chat_message_history_index--;
                    keyboard_string  = _history[_gc.chat_message_history_index];
                    _gc.chat_message = keyboard_string;
                }
            }
        }
        else if (keyboard_check_pressed(vk_down))
        {
            if (global.gui_panel_choices != undefined) && (global.gui_panel_choices.visible)
            {
                var _choice_count = array_length(global.gui_panel_choices.choices);

                global.gui_panel_choices.selected_index = min(_choice_count - 1, global.gui_panel_choices.selected_index + 1);
            }
            else
            {
                var _history        = global.message_history;
                var _history_length = array_length(_history);

                if (_gc.chat_message_history_index < _history_length - 1)
                {
                    _gc.chat_message_history_index++;
                    keyboard_string  = _history[_gc.chat_message_history_index];
                    _gc.chat_message = keyboard_string;
                }
                else
                {
                    _gc.chat_message_history_index = _history_length;
                    keyboard_string  = "";
                    _gc.chat_message = "";
                }
            }
        }
        else if (keyboard_check_pressed(vk_tab))
        {
            if (global.gui_panel_choices != undefined) && (global.gui_panel_choices.visible)
            {
                global.gui_panel_choices.select_choice(global.gui_panel_choices.selected_index);
            }
            else
            {
                chat_refresh_suggestions();
            }
        }

        exit;
    }

    if (keyboard_check_pressed(ord("T"))) && !(obj_Game_Control.is_opened & WORLD_OPENED_BOOL.MENU) && !(obj_Game_Control.is_opened & WORLD_OPENED_BOOL.INVENTORY)
    {
        chat_enable();

        exit;
    }

    if (keyboard_check_pressed(vk_divide) || keyboard_check_pressed(191)) && !(obj_Game_Control.is_opened & WORLD_OPENED_BOOL.MENU) && !(obj_Game_Control.is_opened & WORLD_OPENED_BOOL.INVENTORY)
    {
        chat_enable();
        keyboard_string  = "/";
        _gc.chat_message = "/";
        chat_refresh_suggestions();
    }
}
