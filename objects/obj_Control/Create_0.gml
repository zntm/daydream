global.delta_time = delta_time / 1_000_000;

global.window_width  = window_get_width();
global.window_height = window_get_height();

surface_resize(application_surface, global.window_width, global.window_height);

on_window_resize = undefined;

on_window_focus   = undefined;
on_window_unfocus = undefined;

// Initialize network globals ONLY if not already in a session
if (global.relay == undefined || global.relay.role == RELAY_ROLE.NONE)
{
    relay_manager_init();
}