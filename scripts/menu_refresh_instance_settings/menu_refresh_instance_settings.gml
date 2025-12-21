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
    
    var _category = global.settings_data_category[$ category];
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
    };
    
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
                
                with (instance_create_layer(0, 0, layer, obj_Menu_Control_Keybind_Remap))
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
                }
            }

            var _key_name = input_get_name(_value);

            with (instance_create_layer(_menu_settings_xoffset + 64, _menu_settings_yoffset + _y, "Settings", obj_Menu_Button))
            {
                is_setting = true;
                surface_index = _fade_layer;
                menu_layer = 0; // Explicitly set to 0 for input

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
                
                var _t = normalize(_x, slider_x_min, slider_x_max);
                
                if (global.settings[$ name] != _t)
                {
                    var _on_update = global.settings_data[$ name].get_on_update();
                    
                    if (_on_update != undefined)
                    {
                        _on_update(name, _t);
                    }
                }
                
                global.settings[$ name] = _t;
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
                
                x = lerp(slider_x_min, slider_x_max, _value);
                
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