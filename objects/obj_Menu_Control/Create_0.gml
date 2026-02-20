control_update_gui_size(window_get_width(), window_get_height());

if (!instance_exists(obj_Game_Control))
{
    global.gui_mouse_x = device_mouse_x_to_gui(0);
    global.gui_mouse_y = device_mouse_y_to_gui(0);
}