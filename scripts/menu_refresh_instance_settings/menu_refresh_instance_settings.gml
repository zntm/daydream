global.settings_list_offset = 0;
global.settings_list_length = 0;
global.settings_list_size = 0;

function menu_refresh_instance_settings()
{
    static __text = function(_x, _y, _xscale, _yscale)
    {
        var _data = global.settings_data[$ name];
        
        var _x2 = x * _xscale;
        var _y2 = y * _yscale;
        
        var _halign = draw_get_halign();
        var _valign = draw_get_valign();
        
        draw_set_align(fa_left, fa_middle);
        
        render_text(_x2, _y2, loca_translate($"phantasia:settings.{name}.name"), _xscale, _yscale);
        render_text(_x2, _y2 + (24 * _yscale), loca_translate($"phantasia:settings.{name}.description"), _xscale * 0.75, _yscale * 0.75, 0, c_ltgray, 0.5);
        
        draw_set_align(_halign, _valign);
    }
    
    with (all)
    {
        if (id[$ "is_setting"])
        {
            instance_destroy();
            
            continue;
        }
        
        if (id[$ "category"] != undefined)
        {
            sprite_index = spr_Menu_Button_Main;
        }
    }
    
    sprite_index = spr_Menu_Button_Secondary;
    
    var _menu_settings_xoffset = global.menu_settings_xoffset;
    var _menu_settings_yoffset = global.menu_settings_yoffset;
    
    var _settings = global.settings;
    var _settings_data = global.settings_data;
    
    // Handle controls category with input type toggle (keyboard, gamepad, touch)
    var _actual_category = category;
    if (category == "controls" || category == "controls_gamepad" || category == "controls_touch")
    {
        _actual_category = "controls_" + global.controls_input_type;
        // keyboard uses "controls" not "controls_keyboard"
        if (global.controls_input_type == "keyboard") _actual_category = "controls";
    }
    
    var _category = global.settings_data_category[$ _actual_category];
    var _length = array_length(_category);
    
    var _inst_slider = global.settings_inst_slider;
    
	if (_length <= 5)
	{
		_inst_slider.x = -64;
		_inst_slider.y = -64;
	}
	else
	{
		global.settings_list_offset = 0;
		
		global.settings_list_length = _length;
		global.settings_list_size = max(0, (_length - 5) * 64);
		
		_inst_slider.x = _menu_settings_xoffset + _inst_slider.xstart;
		_inst_slider.y = _menu_settings_yoffset + _inst_slider.ystart;
	}
    
    var _base_layer = obj_Menu_Control_Button.menu_layer;
    var _fade_layer = _base_layer + 1;
    
    obj_Menu_Control_Render.surface_index_length = _fade_layer + 1;
    obj_Menu_Control_Render.surface_index_shader[@ _fade_layer] = {
        id: shd_Menu_Settings_Fade,
        u_FadeStart: 0.45, 
        u_FadeEnd: 0.85,
        no_dim: true
    }
    
    obj_Menu_Control_Render.surface_index_boundary[@ _fade_layer] = {
        y_min: global.gui_height * 0.45,
        y_max: global.gui_height * 0.85
    }
    
    // Add input type toggle when viewing controls (keyboard, gamepad, touch)
    if (_actual_category == "controls" || _actual_category == "controls_gamepad" || _actual_category == "controls_touch")
    {
        // List of available input types to cycle through
        static __toggle_on_select_release = function()
        {
            static __input_types = ["keyboard", "gamepad"]; // Add "touch" when implemented
            
            var _current = global.controls_input_type;
            var _index = array_get_index(__input_types, _current);
            _index = (_index + 1) mod array_length(__input_types);
            global.controls_input_type = __input_types[_index];
            with (obj_Menu_Control_Button)
            {
                menu_refresh_instance_settings();
            }
        }
        
        with (instance_create_layer(_menu_settings_xoffset + 64, _menu_settings_yoffset + 128, "Settings", obj_Menu_Button))
        {
            is_setting = true;
            surface_index = _fade_layer;
            menu_layer = 0;
            
            // Capitalize first letter for display
            var _type = global.controls_input_type;
            var _mode_text = string_upper(string_char_at(_type, 1)) + string_copy(_type, 2, string_length(_type) - 1);
            text = $"Mode: {_mode_text}";
            
            image_xscale = 16;
            image_yscale = 2;
            
            x = _menu_settings_xoffset + room_width / 2 - (image_xscale * 8 / 2);
            
            on_select_release = method(id, __toggle_on_select_release);
        }
    }
    
    for (var i = 0; i < _length; ++i)
    {
        var _name = _category[i];
        var _data = _settings_data[$ _name];
        
        var _value = _settings[$ _name];
        
        // var _y = inst_981AC84.y + (64 * i);
        var _y = 192 + (64 * i);
        
        with (instance_create_layer(64, _y, "Settings", obj_Menu_Anchor))
        {
            is_setting = true;
            surface_index = _fade_layer;
            menu_layer = 0; // Explicitly set to 0 for input
            
            name = _name;
            
            on_draw = method(id, __text);
        }
        
        var _type = _data.get_type();
        
        if (_type == SETTINGS_TYPE.ARROW)
        {
            
        }
        else if (_type == SETTINGS_TYPE.HOTKEY)
        {
            static __hotkey_on_draw_behind = function(_x, _y, _xscale, _yscale)
            {
                var _width = (room_width - 64 - 16) * _xscale; // Adjust width as needed
                 draw_sprite_ext(spr_Menu_Indent, 0, (room_width - 64 - 16) * _xscale, (y - global.menu_settings_yoffset) * _yscale, 32 / 8, 16 / 8, 0, c_white, 1); 
            }
            
            static __hotkey_on_select_release = function()
            {
                obj_Menu_Control_Button.menu_layer++;
                
                with (instance_create_layer(-64, -64, layer, obj_Menu_Control_Keybind_Remap))
                {
                    menu_layer = 1;
                    surface_index = other.surface_index + 1; // Render on top of settings (Layer 2)
                    obj_Menu_Control_Render.surface_index_length = surface_index + 1;
                    
                    if (variable_instance_exists(id, "anchor"))
                    {
                        anchor.surface_index = surface_index;
                    }
                    
                    setting_name = other.setting_name;
                    button_id = other.id; // Pass the button ID
                    is_gamepad = other.is_gamepad_setting; // Pass gamepad flag
                }
            }

            // Check if this is a gamepad setting
            var _is_gamepad = string_pos("gamepad", _name) > 0;
            var _key_name = _is_gamepad ? input_get_gamepad_name(_value) : input_get_name(_value);

            with (instance_create_layer(_menu_settings_xoffset + 64, _menu_settings_yoffset + _y, "Settings", obj_Menu_Button))
            {
                is_setting = true;
                surface_index = _fade_layer;
                menu_layer = 0; // Explicitly set to 0 for input
                is_gamepad_setting = _is_gamepad; // Store gamepad flag

                setting_name = _name;
                display_text = loca_translate($"phantasia:settings.{_name}.name");
                text = _key_name; // Just the key name

                image_xscale = 12; // Bigger button
                image_yscale = 2;
                
                 x = _menu_settings_xoffset + room_width - 64 - (image_xscale * 8); // Align right based on width
               
                on_draw_behind = method(id, __hotkey_on_draw_behind);
                on_select_release = method(id, __hotkey_on_select_release);
            }
        }
        else if (_type == SETTINGS_TYPE.SLIDER)
        {
            static __slider_on_draw_behind = function(_x, _y, _xscale, _yscale)
            {
                var _width = (slider_x_max - slider_x_min) * _xscale;
                
                draw_sprite_ext(spr_Menu_Indent, 0, ((slider_x_min - global.menu_settings_xoffset) * _xscale) + (_width / 2), (y - global.menu_settings_yoffset) * _yscale, _width / 8, 16 / 8, 0, c_white, 1); 
            }
            
            static __slider_on_select = function()
            {
                xoffset = x - mouse_x;
            }
            
            static __slider_on_select_hold = function()
            {
                var _x = mouse_x + xoffset;
                
                x = clamp(_x, slider_x_min, slider_x_max);
                
                var _t_pos = normalize(_x, slider_x_min, slider_x_max);
                
                var _data = global.settings_data[$ name];
                var _min = _data.get_range_min();
                var _max = _data.get_range_max();
                
                if (_min == 0) && (_max == 0) _max = 1;
                
                var _val = lerp(_min, _max, _t_pos);
                
                if (global.settings[$ name] != _val)
                {
                    var _on_update = global.settings_data[$ name].get_on_update();
                    
                    if (_on_update != undefined)
                    {
                        _on_update(name, _val);
                    }
                }
                
                global.settings[$ name] = _val;
            }
            
            with (instance_create_layer(_menu_settings_xoffset + 64, _menu_settings_yoffset + _y, "Settings", obj_Menu_Button))
            {
                is_setting = true;
                surface_index = _fade_layer;
                
                name = _name;
                
                slider_x_min = _menu_settings_xoffset + room_width - 64 - 256;
                slider_x_max = _menu_settings_xoffset + room_width - 64;
                
                image_yscale = 2;
                
                xoffset = 0;
                
                var _min = _data.get_range_min();
                var _max = _data.get_range_max();
                
                if (_min == 0) && (_max == 0) _max = 1;
                
                var _t = normalize(_value, _min, _max);
                
                x = lerp(slider_x_min, slider_x_max, _t);
                
                on_select = method(id, __slider_on_select);
                on_select_hold = method(id, __slider_on_select_hold);
                
                on_draw_behind = method(id, __slider_on_draw_behind);
            }
        }
        else if (_type == SETTINGS_TYPE.SWITCH)
        {
            static __switch_on_draw_behind = function(_x, _y, _xscale, _yscale)
            {
                draw_sprite_ext(spr_Menu_Indent, 0, (room_width - 64 - 16) * _xscale, (y - global.menu_settings_yoffset) * _yscale, 32 / 8, 16 / 8, 0, c_white, 1); 
            }
            
            static __slider_on_select_release = function()
            {
                var _value = !global.settings[$ name];
                
                x = ((_value) ? room_width - 64 : room_width - 64 - 32);
                
                var _on_update = global.settings_data[$ name].get_on_update();
                
                if (_on_update != undefined)
                {
                    _on_update(name, _value);
                }
                
                global.settings[$ name] = _value;
            }
            
            with (instance_create_layer(_menu_settings_xoffset + 64, _menu_settings_yoffset + _y, "Settings", obj_Menu_Button))
            {
                is_setting = true;
                surface_index = _fade_layer;
                
                name = _name;
                
                image_yscale = 2;
                
                x = _menu_settings_xoffset + ((_value) ? room_width - 64 : room_width - 64 - 32);
                
                on_select_release = method(id, __slider_on_select_release);
                
                on_draw_behind = method(id, __switch_on_draw_behind);
            }
        }
    }
}