var _menu_layer = menu_layer;

var _number = instance_number(obj_Menu_Button);

for (var i = 0; i < _number; ++i)
{
    var _has_selected = false;
    
    with (obj_Menu_Button)
    {
        if (_menu_layer != menu_layer) || !(boolean & (MENU_BUTTON_BOOLEAN.IS_SELECTED | MENU_BUTTON_BOOLEAN.IS_HOLDING)) continue;
        
        _has_selected = true;
        
        break;
    }
    
    if (!_has_selected)
    {
        with (obj_Menu_Button)
        {
            if (index != i) || (boolean & MENU_BUTTON_BOOLEAN.IS_HOLDING) continue;
            
            if (_menu_layer == menu_layer) && (point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom))
            {
                boolean |= MENU_BUTTON_BOOLEAN.IS_HOVER;
                
                if (mouse_check_button_pressed(mb_left))
                {
                    boolean |= MENU_BUTTON_BOOLEAN.IS_HOLDING;
                }
                
                if (mouse_check_button(mb_left))
                {
                    if !(boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
                    {
                        boolean |= MENU_BUTTON_BOOLEAN.IS_SELECTED;
                        
                        sfx_play("phantasia:menu.button.select");
                        
                        if (on_select != undefined)
                        {
                            on_select();
                        }
                    }
                }
            }
            else
            {
                if (boolean & MENU_BUTTON_BOOLEAN.IS_HOVER)
                {
                    boolean ^= MENU_BUTTON_BOOLEAN.IS_HOVER;
                }
                
                if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
                {
                    sfx_play("phantasia:menu.button.deselect");
                    
                    boolean ^= MENU_BUTTON_BOOLEAN.IS_SELECTED;
                }
            }
        }
        
        with (obj_Menu_Dropdown)
        {
            if (index != i) || (boolean & MENU_BUTTON_BOOLEAN.IS_HOLDING) continue;
            
            if (point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom))
            {
                if (_menu_layer == menu_layer)
                {
                    boolean |= MENU_BUTTON_BOOLEAN.IS_HOVER;
                    
                    if (mouse_check_button_pressed(mb_left))
                    {
                        boolean |= MENU_BUTTON_BOOLEAN.IS_HOLDING;
                    }
                    
                    if (mouse_check_button(mb_left))
                    {
                        if !(boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
                        {
                            boolean |= MENU_BUTTON_BOOLEAN.IS_SELECTED;
                            
                            sfx_play("phantasia:menu.button.select");
                            
                            if (on_select != undefined)
                            {
                                on_select();
                            }
                        }
                    }
                }
                else
                {
                    if (boolean & MENU_BUTTON_BOOLEAN.IS_HOVER)
                    {
                        boolean ^= MENU_BUTTON_BOOLEAN.IS_HOVER;
                    }
                    
                    if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
                    {
                        sfx_play("phantasia:menu.button.deselect");
                        
                        boolean ^= MENU_BUTTON_BOOLEAN.IS_SELECTED;
                    }
                }
            }
        }
        
        with (obj_Menu_Textbox)
        {
            if (index != i) || (boolean & MENU_BUTTON_BOOLEAN.IS_HOLDING) continue;
            
            if (_menu_layer == menu_layer) && (point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom))
            {
                boolean |= MENU_BUTTON_BOOLEAN.IS_HOVER;
                
                if (mouse_check_button_pressed(mb_left))
                {
                    if !(boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
                    {
                        boolean |= MENU_BUTTON_BOOLEAN.IS_SELECTED;
                        
                        sfx_play("phantasia:menu.button.select");
                        
                        if (on_select != undefined)
                        {
                            on_select();
                        }
                        
                        keyboard_string = text;
                    }
                }
            }
            else
            {
                if (boolean & MENU_BUTTON_BOOLEAN.IS_HOVER)
                {
                    boolean ^= MENU_BUTTON_BOOLEAN.IS_HOVER;
                }
            }
        }
    }
}

with (obj_Menu_Button)
{
    if (boolean & MENU_BUTTON_BOOLEAN.IS_HOLDING) && (on_select_hold != undefined)
    {
        on_select_hold();
    }
}

with (obj_Menu_Textbox)
{
    if (boolean & MENU_BUTTON_BOOLEAN.IS_HOLDING) && (on_select_hold != undefined)
    {
        on_select_hold();
    }
}

if (mouse_check_button_released(mb_left))
{
    with (obj_Menu_Button)
    {
        if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
        {
            sfx_play("phantasia:menu.button.deselect");
            
            boolean ^= MENU_BUTTON_BOOLEAN.IS_SELECTED;
            
            if (point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom)) && (on_select_release != undefined)
            {
                on_select_release();
            }
        }
        
        if (boolean & MENU_BUTTON_BOOLEAN.IS_HOLDING)
        {
            boolean ^= MENU_BUTTON_BOOLEAN.IS_HOLDING;
        }
    }
    
    with (obj_Menu_Dropdown)
    {
        if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED) && (!point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom))
        {
            boolean ^= MENU_BUTTON_BOOLEAN.IS_SELECTED;
            
            if (on_select_release != undefined)
            {
                on_select_release();
            }
            
            var _has_selected = false;
            
            var _choices_length = array_length(choices);
            
            if (_choices_length > 0)
            {
                var _button_width  = (image_xscale / 2) * 16;
                var _button_height = (image_yscale / 2) * 16;
                
                for (var j = 0; j < _choices_length; ++j)
                {
                    var _x1 = x - (_button_width / 2);
                    var _y1 = y + ((j + 1) * _button_height) - (_button_height / 2);
                    
                    var _x2 = x + (_button_width / 2);
                    var _y2 = y + ((j + 1) * _button_height) + (_button_height / 2);
                    
                    if (point_in_rectangle(mouse_x, mouse_y, _x1, _y1, _x2, _y2))
                    {
                        choice_index = j;
                        
                        _has_selected = true;
                        
                        break;
                    }
                }
            }
            
            if (_has_selected)
            {
                sfx_play("phantasia:menu.button.select");
            }
            else
            {
            	sfx_play("phantasia:menu.button.deselect");
            }
        }
        
        if (boolean & MENU_BUTTON_BOOLEAN.IS_HOLDING)
        {
            boolean ^= MENU_BUTTON_BOOLEAN.IS_HOLDING;
        }
    }
}

if (mouse_check_button_pressed(mb_left))
{
    with (obj_Menu_Textbox)
    {
        if (!point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom)) && (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
        {
            sfx_play("phantasia:menu.button.deselect");
            
            boolean ^= MENU_BUTTON_BOOLEAN.IS_SELECTED;
            
            if (on_select_release != undefined)
            {
                on_select_release();
            }
        }
    }
}

if (keyboard_check_pressed(vk_escape))
{
    with (obj_Menu_Textbox)
    {
        if (boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
        {
            sfx_play("phantasia:menu.button.deselect");
            
            boolean ^= MENU_BUTTON_BOOLEAN.IS_SELECTED;
            
            if (on_select_release != undefined)
            {
                on_select_release();
            }
        }
    }
}

menu_control_textbox();