function chat_disable()
{
    if !(obj_Game_Control.is_opened & IS_OPENED_BOOLEAN.MENU)
    {
        keyboard_string = "";
    }
    
    obj_Game_Control.chat_message = "";
    
    obj_Game_Control.is_opened &= ~IS_OPENED_BOOLEAN.CHAT;
    
    chat_hide_choices();
}