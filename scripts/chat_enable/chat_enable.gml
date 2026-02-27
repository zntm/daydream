function chat_enable(_message = "")
{
    if !(obj_Game_Control.is_opened & WORLD_OPENED_BOOL.GUI) exit;
    
    obj_Game_Control.is_opened |= WORLD_OPENED_BOOL.CHAT;
    
    keyboard_string = _message;
    obj_Game_Control.chat_message = _message;
    
    obj_Game_Control.chat_message_history_index = array_length(global.message_history);
}