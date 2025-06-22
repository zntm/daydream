global.delta_time = delta_time / 1_000_000;

var _window_focus = window_has_focus();

var _window_width  = window_get_width();
var _window_height = window_get_height();

if (global.window_width != _window_width) || (global.window_height != _window_height)
{
    global.window_width  = _window_width;
    global.window_height = _window_height;
    
    if (_window_width > 0) && (_window_height > 0)
    {
        room_set_viewport(room, 0, true, 0, 0, _window_width, _window_height);
        
        if (_window_width != surface_get_width(application_surface)) || (_window_height != surface_get_height(application_surface))
        {
            surface_resize(application_surface, _window_width, _window_height);
        }
        
        if (on_window_resize != undefined)
        {
            on_window_resize();
        }
    }
}
else
{
    if (!_window_focus)
    {
        global.window_focus = false;
        
        if (on_window_unfocus != undefined)
        {
            on_window_unfocus();
        }
    }
    else if (!global.window_focus)
    {
        global.window_focus = true;
        
        if (on_window_focus != undefined)
        {
            on_window_focus();
        }
    }
    
    if (keyboard_check_pressed(vk_f11))
    {
        window_set_fullscreen(!window_get_fullscreen());
    }
}