function menu_settings_ui_load()
{
	menu_ui_clear_all();
	
	/* clean up legacy */
	instance_destroy(obj_Menu_Button);
	instance_destroy(obj_Menu_Anchor);
	
	/* ensure gui_root exists */
	if (!variable_global_exists("gui_root")) || (global.gui_root == undefined)
	{
		global.gui_root = new UIElement(0, 0, 960, 540);
		global.gui_root.element_name = "gui_root";
	}
	
	/* cache reload */
	if (variable_global_exists("ui_definitions"))
	{
		var _full_path = "resources/data/ui/menu/settings.ui";
		if (struct_exists(global.ui_definitions, _full_path))
		{
			struct_remove(global.ui_definitions, _full_path);
		}
	}
	
	var _def = ui_load("ui/menu/settings.ui");
	
	if (_def == undefined)
	{
		show_debug_message("[Menu Settings] failed to load ui/menu/settings.ui");
		exit;
	}
	
	var _instance = ui_spawn(_def, {
		link: {},
		parent: global.gui_root
	});
	
	global.ui_settings_menu = _instance;
	
	/* set initial category */
	global.settings_current_category = "general";
	
	menu_settings_ui_init();
}

function menu_settings_ui_init()
{
	var _instance = global.ui_settings_menu;
	var _elements = _instance.elements;
	
	/* back button */
	var _btn_back = _elements[$ "btn_back"];
	
	if (_btn_back != undefined)
	{
		_btn_back.text = loca_translate("phantasia:menu.generic.back");
		
		_btn_back.add_event_handler("on_select_release", function() {
			menu_transition_goto(rm_Menu_Title);
		});
	}
	
	/* categories */
	var _cats = ["general", "graphics", "controls", "audio", "accessibility"];
	
	for (var i = 0; i < array_length(_cats); ++i)
	{
		var _cat = _cats[i];
		var _btn = _elements[$ "btn_cat_" + _cat];
		
		if (_btn != undefined)
		{
			_btn.text = loca_translate($"phantasia:menu.settings.{_cat}");
			_btn.setting_category = _cat;
			
			_btn.add_event_handler("on_select_release", method(_btn, function() {
				global.settings_current_category = self.setting_category;

				/* refresh the list */
				menu_settings_ui_populate_list();
			}));
		}
	}
	
	/* initial populate */
	menu_settings_ui_populate_list();
}

function menu_settings_ui_populate_list()
{
	var _instance = global.ui_settings_menu;
	var _elements = _instance.elements;
	var _list     = _elements[$ "settings_list"];
	var _scroll   = _elements[$ "settings_scroll"];
	
	if (_list == undefined) exit;
	
	/* clear existing settings */
	_list.children = [];
	
	var _actual_category = global.settings_current_category;
	
    if (_actual_category == "controls") || (_actual_category == "controls_gamepad") || (_actual_category == "controls_touch")
    {
        _actual_category = "controls_" + global.controls_input_type;
        if (global.controls_input_type == "keyboard") _actual_category = "controls";
    }
	
	var _category_data = global.settings_data_category[$ _actual_category];
	
	if (_category_data == undefined)
	{
		exit;
	}
	
    var _length = array_length(_category_data);
	var _ypos = 0;
	
	/* input toggle for controls */
    if (_actual_category == "controls") || (_actual_category == "controls_gamepad") || (_actual_category == "controls_touch")
	{
		var _toggle_btn = new UIButton(0, _ypos, 400, 48, "");
		var _type = global.controls_input_type;
        var _mode_text = string_upper(string_char_at(_type, 1)) + string_copy(_type, 2, string_length(_type) - 1);
		_toggle_btn.text = $"Mode: {_mode_text}";
		
		_toggle_btn.add_event_handler("on_select_release", function() {
			static __input_types = ["keyboard", "gamepad"];
            var _current = global.controls_input_type;
            var _index = array_get_index(__input_types, _current);
            _index = (_index + 1) mod array_length(__input_types);
            global.controls_input_type = __input_types[_index];
			
			menu_settings_ui_populate_list();
		});
		
		_toggle_btn.parent = _list;

		array_push(_list.children, _toggle_btn);

		_ypos += 56;
	}
	
	for (var i = 0; i < _length; ++i)
    {
		var _name  = _category_data[i];
        var _data  = global.settings_data[$ _name];
        var _value = global.settings[$ _name];
        var _type  = _data.get_type();
		
		var _container = new UIArea(0, _ypos, 400, 64);
		_container.parent = _list;
		
		/* setting label */
		var _label = new UIText(16, 16, "");
		_label.text = loca_translate($"phantasia:settings.{_name}.name");
		_label.text_halign = "fa_left";
		_label.parent = _container;

		array_push(_container.children, _label);
		
		/* setting description */
		var _desc = new UIText(16, 40, "");
		_desc.text = loca_translate($"phantasia:settings.{_name}.description");
		_desc.text_halign = "fa_left";
		_desc.text_scale = 0.75;
		_desc.colour = c_ltgray;
		_desc.parent = _container;

		array_push(_container.children, _desc);
		
		if (_type == SETTINGS_TYPE.SLIDER)
		{
			var _slider = new UISlider(200, 24, 180, 16, _data.get_range_min(), _data.get_range_max(), _value);
			_slider.setting_name = _name;
			
			_slider.add_event_handler("on_value_change", method(_slider, function(_new_value) {
				if (global.settings[$ self.setting_name] != _new_value)
				{
					var _on_update = global.settings_data[$ self.setting_name].get_on_update();
                    if (_on_update != undefined) _on_update(self.setting_name, _new_value);
				}

				global.settings[$ self.setting_name] = _new_value;
			}));
			
			_slider.parent = _container;

			array_push(_container.children, _slider);
		}
		else if (_type == SETTINGS_TYPE.SWITCH)
		{
			var _switch = new UIRadioButton(360, 24, "");
			_switch.size = [32, 16];
			_switch.selected = _value;
			_switch.setting_name = _name;
			
			_switch.add_event_handler("on_select_release", method(_switch, function() {
				var _new_value = self.selected;
				
				var _on_update = global.settings_data[$ self.setting_name].get_on_update();
                if (_on_update != undefined) _on_update(self.setting_name, _new_value);
                
                var _on_release = global.settings_data[$ self.setting_name].get_on_release();
                if (_on_release != undefined) _on_release(self.setting_name, _new_value);
				
				global.settings[$ self.setting_name] = _new_value;
			}));
			
			_switch.parent = _container;

			array_push(_container.children, _switch);
		}
		else if (_type == SETTINGS_TYPE.HOTKEY)
		{
			var _is_gamepad = string_pos("gamepad", _name) > 0;
            var _key_name = _is_gamepad ? input_get_gamepad_name(_value) : input_get_name(_value);
			
			var _btn = new UIButton(200, 16, 180, 32, _key_name);
			_btn.setting_name = _name;
			_btn.is_gamepad_setting = _is_gamepad;
			
			_btn.add_event_handler("on_select_release", method(_btn, function() {
                with (instance_create_layer(-64, -64, "Settings", obj_Menu_Control_Keybind_Remap))
                {
                    menu_layer = 1;
                    surface_index = 2;
                    setting_name = other.setting_name;
                    button_id = undefined;
                    is_gamepad = other.is_gamepad_setting;
                }
			}));
			
			_btn.parent = _container;

			array_push(_container.children, _btn);
		}
		
		array_push(_list.children, _container);

		_ypos += 72;
	}
	
	_list.height = _ypos + 16;
}
