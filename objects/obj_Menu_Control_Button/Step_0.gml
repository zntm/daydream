if (menu_transition_is_active()) exit;

var _menu_layer = menu_layer;

var _check_boundary = function(_surface_index)
{
    if (_surface_index < 0) || (_surface_index >= array_length(obj_Menu_Control_Render.surface_index_boundary))
    {
        return true;
    }
    
    var _struct = obj_Menu_Control_Render.surface_index_boundary[_surface_index];
    
    if (!is_struct(_struct))
    {
        return true;
    }
    
    var _gui_mouse_x = global.gui_mouse_x;
    var _gui_mouse_y = global.gui_mouse_y;
    
    return (_gui_mouse_x >= _struct.x_min) && (_gui_mouse_y >= _struct.y_min) && (_gui_mouse_x < _struct.x_max) && (_gui_mouse_y < _struct.y_max);
}

var _number = instance_number(obj_Menu_Button);

for (var i = 0; i < _number; ++i)
{
    var _has_selected = false;
    
    with (obj_Menu_Button)
    {
        if (_menu_layer != menu_layer) || !(boolean & (MENU_BUTTON_BOOLEAN.IS_SELECTED | MENU_BUTTON_BOOLEAN.IS_HOLDING)) continue;
        
        var _surface_index = (variable_instance_exists(id, "surface_index") ? surface_index : menu_layer);
        
        if (!_check_boundary(_surface_index)) continue;
        
        _has_selected = true;
        
        break;
    }
    
    if (!_has_selected)
    {
        with (obj_Menu_Button)
        {
            if (index != i) || (boolean & MENU_BUTTON_BOOLEAN.IS_HOLDING) continue;
            
            var _surface_index = (variable_instance_exists(id, "surface_index") ? surface_index : menu_layer);
            
            if (_menu_layer == menu_layer) && (point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom)) && (_check_boundary(_surface_index))
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
                        
                        sfx_play("phantasia:sfx/menu/button/select", global.settings.audio_ui);
                        
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
                    sfx_play("phantasia:sfx/menu/button/deselect", global.settings.audio_ui);
                    
                    boolean ^= MENU_BUTTON_BOOLEAN.IS_SELECTED;
                }
            }
        }
        
        with (obj_Menu_Dropdown)
        {
            if (index != i) || (boolean & MENU_BUTTON_BOOLEAN.IS_HOLDING) continue;
            
            var _surface_index = (variable_instance_exists(id, "surface_index") ? surface_index : menu_layer);
            
            if (point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom)) && (_check_boundary(_surface_index))
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
                            
                            sfx_play("phantasia:sfx/menu/button/select", global.settings.audio_ui);
                            
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
                        sfx_play("phantasia:sfx/menu/button/deselect", global.settings.audio_ui);
                        
                        boolean ^= MENU_BUTTON_BOOLEAN.IS_SELECTED;
                    }
                }
            }
        }
        
        with (obj_Menu_Textbox)
        {
            if (index != i) || (boolean & MENU_BUTTON_BOOLEAN.IS_HOLDING) continue;
            
            var _surface_index = (variable_instance_exists(id, "surface_index") ? surface_index : menu_layer);
            
            if (_menu_layer == menu_layer) && (point_in_rectangle(mouse_x, mouse_y, bbox_left, bbox_top, bbox_right, bbox_bottom)) && (_check_boundary(_surface_index))
            {
                boolean |= MENU_BUTTON_BOOLEAN.IS_HOVER;
                
                if (mouse_check_button_pressed(mb_left))
                {
                    if !(boolean & MENU_BUTTON_BOOLEAN.IS_SELECTED)
                    {
                        boolean |= MENU_BUTTON_BOOLEAN.IS_SELECTED;
                        
                        sfx_play("phantasia:sfx/menu/button/select", global.settings.audio_ui);
                        
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
            sfx_play("phantasia:sfx/menu/button/deselect", global.settings.audio_ui);
            
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
                sfx_play("phantasia:sfx/menu/button/select", global.settings.audio_ui);
            }
            else
            {
            	sfx_play("phantasia:sfx/menu/button/deselect", global.settings.audio_ui);
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
            sfx_play("phantasia:sfx/menu/button/deselect", global.settings.audio_ui);
            
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
            sfx_play("phantasia:sfx/menu/button/deselect", global.settings.audio_ui);
            
            boolean ^= MENU_BUTTON_BOOLEAN.IS_SELECTED;
            
            if (on_select_release != undefined)
            {
                on_select_release();
            }
        }
    }
}

with (obj_Menu_Button)
{
    if (on_step != undefined)
    {
        on_step();
    }
}

menu_control_textbox();