function control_update_gui_size()
{
    var _width  = global.window_width;
    var _height = global.window_height;

    display_set_gui_size(_width, _height);

    /* scale menu elements individually via render controller */
    var _gui_scale = global.gui_scale;

    if (instance_exists(obj_Menu_Control_Render))
    {
        obj_Menu_Control_Render.xscale = _gui_scale;
        obj_Menu_Control_Render.yscale = _gui_scale;
    }

    /* update gui_root to use logical dimensions (Width = WindowWidth / Scale, Height = 540) */
    if (variable_global_exists("gui_root")) && (global.gui_root != undefined)
    {
        var _s = _height / 540;

        global.gui_root.width  = _width / _s;
        global.gui_root.height = 540;
        global.gui_root.recalculate_layout();
    }
}