function chat_disable()
{
    if !(obj_Game_Control.is_opened & WORLD_OPENED_BOOL.MENU)
    {
        keyboard_string = "";
    }
    
    obj_Game_Control.chat_message = "";
    
    obj_Game_Control.is_opened &= ~WORLD_OPENED_BOOL.CHAT;
    
    chat_hide_choices();
}