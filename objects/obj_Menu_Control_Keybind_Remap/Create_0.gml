setting_name = undefined;
button_id = undefined;
menu_layer = obj_Menu_Control_Button.menu_layer;

cancel_timer = 0;
cancel_threshold = 60; // 1 second?

// Create anchor for rendering
anchor = instance_create_layer(0, 0, layer, obj_Menu_Anchor);
anchor.menu_layer = menu_layer;
anchor.on_draw = method(id, function(_x, _y, _xscale, _yscale) {
    var _cx = display_get_gui_width() / 2;
    var _cy = display_get_gui_height() / 2;
    
    // Draw text
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var _display_name = loca_translate($"phantasia:settings.{setting_name}.name");
    
    // Main instruction
    render_text(_cx, _cy - 32, $"Remapping: {_display_name}", 2, 2, 0, c_white, 1);
    render_text(_cx, _cy + 16, "Press any key to bind", 1.5, 1.5, 0, c_ltgray, 1);
    
    // Cancel instruction
    var _cancel_col = (cancel_timer > 0) ? c_red : c_gray;
    render_text(_cx, _cy + 64, "Hold ESC to Cancel", 1, 1, 0, _cancel_col, 1);
    
    // Cancel progress
    if (cancel_timer > 0)
    {
        var _bar_w = 200;
        var _bar_h = 4;
        var _pct = cancel_timer / cancel_threshold;
        draw_rectangle_colour(_cx - _bar_w/2, _cy + 80, _cx - _bar_w/2 + (_bar_w * _pct), _cy + 80 + _bar_h, c_red, c_red, c_red, c_red, false);
    }
});
