function chat_enable(_message = "")
{
    if !(obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.GUI) exit;
    
    obj_Game_Control.is_opened |= IS_OPENED_BOOLEAN.CHAT;
    
    keyboard_string = _message;
    obj_Game_Control.chat_message = _message;
    
    obj_Game_Control.chat_message_history_index = array_length(global.message_history);
}