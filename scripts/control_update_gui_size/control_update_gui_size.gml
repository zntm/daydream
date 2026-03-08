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

    /* update camera dimensions based on aspect ratio (base height = 540) */
    var _aspect_ratio = _width / _height;
    var _cam_h = 540;
    var _cam_w = _cam_h * _aspect_ratio;

    var _cam_w_prev = variable_global_exists("camera_width") ? global.camera_width : _cam_w;
    var _cam_h_prev = variable_global_exists("camera_height") ? global.camera_height : _cam_h;

    global.camera_width  = _cam_w;
    global.camera_height = _cam_h;

    global.camera_width_base  = _cam_w;
    global.camera_height_base = _cam_h;

    /* adjust camera pos to keep center stable if it exists */
    if (variable_global_exists("camera_x")) && (variable_global_exists("camera_y"))
    {
        global.camera_x -= (_cam_w - _cam_w_prev) / 2;
        global.camera_y -= (_cam_h - _cam_h_prev) / 2;
        
        control_camera_pos(global.camera_x, global.camera_y, true);
    }

    camera_set_view_size(view_camera[0], _cam_w, _cam_h);

    /* update gui_root to use logical dimensions (Width = WindowWidth / Scale, Height = 540) */
    if (variable_global_exists("gui_root")) && (global.gui_root != undefined)
    {
        var _s = _height / 540;

        global.gui_root.width  = _width / _s;
        global.gui_root.height = 540;
        global.gui_root.recalculate_layout();
        
        /* mark declarative UI instances as dirty to force re-render with new positions */
        if (variable_global_exists("ui_hotbar"))    ui_mark_dirty(global.ui_hotbar);
        if (variable_global_exists("ui_inventory")) ui_mark_dirty(global.ui_inventory);
        if (variable_global_exists("ui_crafting"))  ui_mark_dirty(global.ui_crafting);
    }
}