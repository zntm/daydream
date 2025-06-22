global.delta_time = delta_time / 1_000_000;

surface_resize(application_surface, global.window_width, global.window_height);

on_window_resize = undefined;

on_window_focus   = undefined;
on_window_unfocus = undefined;