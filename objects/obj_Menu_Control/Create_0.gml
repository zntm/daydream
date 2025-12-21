display_set_gui_size(room_width, room_height);

if (!instance_exists(obj_Game_Control))
{
    global.gui_width = display_get_gui_width();
    global.gui_height = display_get_gui_height();
    
    global.gui_mouse_x = device_mouse_x_to_gui(0);
    global.gui_mouse_y = device_mouse_y_to_gui(0);
}