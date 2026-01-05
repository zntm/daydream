/// @description Demo function to create a test UI menu using the new system

function ui_demo_create()
{
    // Create root container
    var _root = new UIBox("root")
        .set_size(960, 540)
        .set_background(make_colour_rgb(20, 20, 30), 1)
        .set_layout(UI_LAYOUT.FLEX_COLUMN, 16)
        .set_align(UI_ALIGN.CENTER)
        .set_justify(UI_ALIGN.CENTER)
        .set_padding(32);
    
    // Title
    var _title = new UIText("title", "New UI System Demo")
        .set_text_scale(2)
        .set_text_colour(c_white);
    
    _root.add_child(_title);
    
    // Button row
    var _button_row = new UIElement("button_row")
        .set_layout(UI_LAYOUT.FLEX_ROW, 16)
        .set_justify(UI_ALIGN.CENTER);
    
    var _btn_play = new UIButton("btn_play", "Play")
        .set_on_click(function(_self) {
            show_debug_message("Play clicked!");
        });
    
    var _btn_settings = new UIButton("btn_settings", "Settings")
        .set_on_click(function(_self) {
            show_debug_message("Settings clicked!");
        });
    
    var _btn_quit = new UIButton("btn_quit", "Quit")
        .set_on_click(function(_self) {
            show_debug_message("Quit clicked!");
        });
    
    _button_row.add_children([_btn_play, _btn_settings, _btn_quit]);
    _root.add_child(_button_row);
    
    // Slider section
    var _slider_box = new UIBox("slider_box")
        .set_background(make_colour_rgb(30, 30, 45), 0.8)
        .set_border(make_colour_rgb(60, 60, 90), 1)
        .set_corner_radius(8)
        .set_padding(16)
        .set_layout(UI_LAYOUT.FLEX_COLUMN, 12);
    
    var _slider_label = new UIText("slider_label", "Volume: 50")
        .set_text_colour(c_ltgray);
    
    var _slider = new UISlider("volume_slider", 0, 100, 50)
        .set_width(200)
        .set_on_value_change(function(_self, _value) {
            // Find the label and update it
            var _parent = _self.parent;
            if (_parent != undefined)
            {
                var _len = array_length(_parent.children);
                for (var i = 0; i < _len; ++i)
                {
                    if (_parent.children[i].id == "slider_label")
                    {
                        _parent.children[i].text = "Volume: " + string(round(_value));
                        break;
                    }
                }
            }
            show_debug_message("Volume: " + string(_value));
        });
    
    _slider_box.add_children([_slider_label, _slider]);
    _root.add_child(_slider_box);
    
    // Add HP Bar (Anchored Bottom-Center) using standard UIElement
    var _hp_bar = new UIElement("hp_bar")
        .set_size(300, 24)
        .set_anchor(UI_ALIGN.CENTER, UI_ALIGN.END)
        .set_margin(0, 0, 16, 0); // 16px from bottom
        
    // Attach custom draw method directly
    // Attach custom draw method directly (bound to the instance)
    _hp_bar.draw_self_content = method(_hp_bar, function()
    {
        var _abs_x = get_absolute_x();
        var _abs_y = get_absolute_y();
        var _w = _computed_width;
        var _h = _computed_height;
        
        var _hp = 0;
        var _hp_max = 100;
        
        if (instance_exists(obj_Player))
        {
            _hp = obj_Player.hp;
            _hp_max = obj_Player.hp_max;
        }
        
        var _hp_ratio = clamp(_hp / _hp_max, 0, 1);
        var _hp_colour = make_colour_rgb(255, 20, 147);
        var _bar_height = 8;
        
        // Draw Bar Background
        draw_set_colour(c_black);
        draw_rectangle(_abs_x, _abs_y + _h - _bar_height, _abs_x + _w, _abs_y + _h, false);
        
        // Draw HP Fill
        draw_set_colour(_hp_colour);
        if (_hp_ratio > 0)
        {
            draw_rectangle(_abs_x, _abs_y + _h - _bar_height, _abs_x + (_w * _hp_ratio), _abs_y + _h, false);
        }
        draw_set_colour(c_white);
        
        // Draw Heart Icon (Demonstration)
        var _heart_sprite = asset_get_index("spr_GUI_HP");
        if (_heart_sprite > -1)
        {
            // Draw slightly above and to the left of the bar
            draw_sprite_ext(_heart_sprite, 2, _abs_x - 4, _abs_y + _h - _bar_height/2 - 8, 1, 1, 0, c_white, 1);
        }
        
        // Draw Text
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        draw_text(_abs_x + _w / 2, _abs_y, $"{ceil(_hp)}/{ceil(_hp_max)}");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
    });
        
    _root.add_child(_hp_bar);
    
    // Create Tab Panel
    var _tab_panel = new UITabPanel("tabs")
        .set_width(400)
        .set_height(200)
        .set_margin(16);
        
    _tab_panel.add_tab("Tab 1", new UIText("t1", "Content 1").set_align(UI_ALIGN.CENTER));
    _tab_panel.add_tab("Tab 2", new UIText("t2", "Content 2").set_align(UI_ALIGN.CENTER));
    _tab_panel.enable_tab(0);
    
    _root.add_child(_tab_panel);
    
    // Set up the UI manager
    global.ui_manager.set_root(_root);
    global.ui_manager.layout();
    
    show_debug_message("UI Demo created! Use Tab to navigate, Enter to activate.");
    
    return _root;
}

/// @description Update and draw the demo UI (call from step/draw events)

function ui_demo_update()
{
    global.ui_manager.update();
}

function ui_demo_draw()
{
    global.ui_manager.draw();
}
