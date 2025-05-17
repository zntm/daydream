if (room != rm_World)
{
    var _handle = call_later(1, time_source_units_frames, menu_init_button_depth);
}

offset = 1;
goto   = undefined;

on_draw = undefined;
on_escape = undefined;
on_escape_activated = false;

on_exit = undefined;

surface = [ -1 ];

shader = [ undefined ];
shader_function = [ undefined ];

xoffset = 0;
yoffset = 0;