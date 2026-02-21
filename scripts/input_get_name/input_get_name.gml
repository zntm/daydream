function input_get_name(_key)
{
    switch (_key)
    {
        case vk_space:
            return "Space";
        
        case vk_shift:
            return "Shift";
        
        case vk_control:
            return "Ctrl";
        
        case vk_alt:
            return "Alt";
        
        case vk_enter:
            return "Enter";
        
        case vk_up:
            return "Up";
        
        case vk_down:
            return "Down";
        
        case vk_left:
            return "Left";
        
        case vk_right:
            return "Right";
        
        case vk_backspace:
            return "Backspace";
        
        case vk_tab:
            return "Tab";
        
        case vk_home:
            return "Home";
        
        case vk_end:
            return "End";
        
        case vk_delete:
            return "Delete";
        
        case vk_insert:
            return "Insert";
        
        case vk_pageup:
            return "Page Up";
        
        case vk_pagedown:
            return "Page Down";
        
        case vk_printscreen:
            return "Print Screen";
        
        case vk_pause:
            return "Pause";
        
        case vk_escape:
            return "Escape";
        
        case vk_numpad0:
            return "Num 0";
        
        case vk_numpad1:
            return "Num 1";
        
        case vk_numpad2:
            return "Num 2";
        
        case vk_numpad3:
            return "Num 3";
        
        case vk_numpad4:
            return "Num 4";
        
        case vk_numpad5:
            return "Num 5";
        
        case vk_numpad6:
            return "Num 6";
        
        case vk_numpad7:
            return "Num 7";
        
        case vk_numpad8:
            return "Num 8";
        
        case vk_numpad9:
            return "Num 9";
        
        case vk_multiply:
            return "Num *";
        
        case vk_divide:
            return "Num /";
        
        case vk_add:
            return "Num +";
        
        case vk_subtract:
            return "Num -";
        
        case vk_decimal:
            return "Num .";
        
        case -1:
            return "None";
        
        default:
            return chr(_key);
    }
}
