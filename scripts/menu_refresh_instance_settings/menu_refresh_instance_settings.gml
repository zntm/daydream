function menu_refresh_instance_settings()
{
    static __text = function(_x, _y, _xscale, _yscale)
    {
        var _data = global.settings_data[$ name];
        
        var _x2 = x * _xscale;
        var _y2 = y * _yscale;
        
        render_text(_x2, _y2, loca_translate($"phantasia:settings.{name}.name"), _xscale, _yscale);
        render_text(_x2, _y2 + (24 * _yscale), loca_translate($"phantasia:settings.{name}.description"), _xscale * 0.75, _yscale * 0.75, 0, c_ltgray, 0.5);
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
            
            name = _name;
            
            on_draw = method(id, __text);
        }
        
        var _type = _data.get_type();
        
        if (_type == SETTINGS_TYPE.ARROW)
        {
            
        }
        else if (_type == SETTINGS_TYPE.HOTKEY)
        {
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
                
                name = _name;
                
                image_yscale = 2;
                
                x = _menu_settings_xoffset + ((_value) ? room_width - 64 : room_width - 64 - 32);
                
                on_select_release = method(id, __slider_on_select_release);
                
                on_draw_behind = method(id, __switch_on_draw_behind);
            }
        }
    }
}