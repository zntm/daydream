if (mouse_check_button(mb_left))
{
    var _number = instance_number(obj_Menu_Button);
    
    for (var i = 0; i < _number; ++i)
    {
        with (obj_Menu_Button)
        {
            if (index != i) continue;
            
            if (point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom))
            {
                if !(boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
                {
                    boolean |= MENU_BUTTON_BOOLEAN.IS_SELECTED;
                }
            }
            else if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
            {
                boolean ^= MENU_BUTTON_BOOLEAN.IS_SELECTED;
            }
        }
    }
}
else if (mouse_check_button_released(mb_left))
{
    with (obj_Menu_Button)
    {
        if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
        {
            boolean ^= MENU_BUTTON_BOOLEAN.IS_SELECTED;
        }
    }
}