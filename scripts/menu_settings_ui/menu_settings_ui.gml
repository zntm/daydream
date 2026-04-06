global.ui_settings_menu = undefined;
global.menu_settings_back_handler = undefined;
global.ui_settings_rebind = undefined;


function menu_settings_ui_load()
{
	menu_settings_ui_spawn(function() {
		menu_transition_goto(rm_Menu_Title);
	});
}


function menu_settings_ui_spawn(_back_handler = undefined, _clear_all = true)
{
	if (global.ui_settings_menu != undefined)
	{
		menu_settings_ui_close();
	}

	if (_clear_all)
	{
		menu_ui_clear_all();

		/* clean up legacy */
		instance_destroy(obj_Menu_Button);
		instance_destroy(obj_Menu_Anchor);
	}
	
	/* ensure gui_root exists */
	if (!variable_global_exists("gui_root")) || (global.gui_root == undefined)
	{
		global.gui_root = ui_create_root();
		global.gui_root.element_name = "gui_root";
	}
	
	/* cache reload */
	ui_invalidate_definition("ui/menu/settings.ui");
	
	var _def = ui_load("ui/menu/settings.ui");
	
	if (_def == undefined)
	{
		PRINT("[Menu Settings] failed to load ui/menu/settings.ui");
		exit;
	}
	
	var _instance = ui_spawn(_def, {
		link: {},
		parent: global.gui_root
	});
	
	global.ui_settings_menu = _instance;
	global.menu_settings_back_handler = _back_handler;
	global.settings_current_category = "general";
	
	menu_settings_ui_init();

	return _instance;
}


function menu_settings_ui_close()
{
	menu_settings_ui_close_rebind();

	if (global.ui_settings_menu != undefined)
	{
		ui_destroy(global.ui_settings_menu);
		global.ui_settings_menu = undefined;
	}

	global.menu_settings_back_handler = undefined;
}


function menu_settings_ui_init()
{
	var _instance = global.ui_settings_menu;

	if (_instance == undefined) exit;

	var _elements = _instance.elements;
	
	/* back button */
	var _btn_back = _elements[$ "btn_back"];
	
	if (_btn_back != undefined)
	{
		_btn_back.text = loca_translate("phantasia:menu.generic.back");
		
		_btn_back.add_event_handler("on_select_release", function() {
			menu_settings_ui_close_rebind();

			if (global.menu_settings_back_handler != undefined)
			{
				global.menu_settings_back_handler();
			}
			else
			{
				menu_transition_goto(rm_Menu_Title);
			}
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
				menu_settings_ui_populate_list();
			}));
		}
	}
	
	menu_settings_ui_populate_list();
}


function menu_settings_ui_populate_list()
{
	var _instance = global.ui_settings_menu;

	if (_instance == undefined) exit;

	var _elements = _instance.elements;
	var _list = _elements[$ "settings_list"];
	var _scroll = _elements[$ "settings_scroll"];
	var _list_width = (_list != undefined) ? _list.width : 640;
	var _row_width = max(400, _list_width - 24);
	var _value_width = 184;
	var _value_x = _row_width - _value_width - 16;
	
	if (_list == undefined) exit;
	
	/* clear existing settings */
	_list.children = [];
	if (_scroll != undefined) _scroll.scroll_offset = 0;
	
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
		var _toggle_btn = new UIButton(0, _ypos, _row_width, 40, "");
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
		
		_list.add_child(_toggle_btn);
		_ypos += 52;
	}
	
	for (var i = 0; i < _length; ++i)
    {
		var _name  = _category_data[i];
        var _data  = global.settings_data[$ _name];
        var _value = global.settings[$ _name];
        var _type  = _data.get_type();
		
		var _container = new UIArea(0, _ypos, _row_width, 72);
		
		/* setting label */
		var _label = new UIText(16, 16, loca_translate($"phantasia:settings.{_name}.name"));
		_label.halign = fa_left;
		_container.add_child(_label);
		
		/* setting description */
		var _desc = new UIText(16, 40, loca_translate($"phantasia:settings.{_name}.description"));
		_desc.halign = fa_left;
		_desc.text_scale = 0.75;
		_desc.colour = c_ltgray;
		_container.add_child(_desc);
		
		if (_type == SETTINGS_TYPE.SLIDER)
		{
			var _slider = new UISlider(_value_x, 24, _value_width, _data.get_range_min(), _data.get_range_max(), _value);
			_slider.setting_name = _name;
			
			_slider.add_event_handler("on_drag", method(_slider, function(_data) {
				var _new_value = _data.value;
				
				if (global.settings[$ self.setting_name] != _new_value)
				{
					var _on_update = global.settings_data[$ self.setting_name].get_on_update();
					if (_on_update != undefined) _on_update(self.setting_name, _new_value);
				}
				
				global.settings[$ self.setting_name] = _new_value;
			}));
			
			_slider.add_event_handler("on_value_change", method(_slider, function(_new_value) {
				if (global.settings[$ self.setting_name] != _new_value)
				{
					var _on_update = global.settings_data[$ self.setting_name].get_on_update();
                    if (_on_update != undefined) _on_update(self.setting_name, _new_value);
				}

				global.settings[$ self.setting_name] = _new_value;
				
				var _on_release = global.settings_data[$ self.setting_name].get_on_release();
				if (_on_release != undefined) _on_release(self.setting_name, _new_value);
				
				file_save_settings();
			}));
			
			_container.add_child(_slider);
		}
		else if (_type == SETTINGS_TYPE.SWITCH)
		{
			var _switch = new UIRadioButton(_row_width - 48, 28, "");
			_switch.width = 32;
			_switch.height = 16;
			_switch.set_selected(_value);
			_switch.setting_name = _name;
			
			_switch.add_event_handler("on_select_release", method(_switch, function() {
				var _new_value = self.selected;
				
				var _on_update = global.settings_data[$ self.setting_name].get_on_update();
                if (_on_update != undefined) _on_update(self.setting_name, _new_value);
                
                var _on_release = global.settings_data[$ self.setting_name].get_on_release();
                if (_on_release != undefined) _on_release(self.setting_name, _new_value);
				
				global.settings[$ self.setting_name] = _new_value;
				file_save_settings();
			}));
			
			_container.add_child(_switch);
		}
		else if (_type == SETTINGS_TYPE.HOTKEY)
		{
			var _is_gamepad = string_pos("gamepad", _name) > 0;
            var _key_name = _is_gamepad ? input_get_gamepad_name(_value) : input_get_name(_value);
			
			var _btn = new UIButton(_value_x, 20, _value_width, 32, _key_name);
			_btn.setting_name = _name;
			_btn.is_gamepad_setting = _is_gamepad;
			
			_btn.add_event_handler("on_select_release", method(_btn, function() {
				menu_settings_ui_open_rebind(self.setting_name, self, self.is_gamepad_setting);
			}));
			
			_container.add_child(_btn);
		}
		
		_list.add_child(_container);
		_ypos += 80;
	}
	
	_list.height = _ypos + 16;
}


function menu_settings_ui_open_rebind(_setting_name, _button, _is_gamepad)
{
	menu_settings_ui_close_rebind();

	ui_invalidate_definition("ui/menu/keybind_remap.ui");

	var _def = ui_load("ui/menu/keybind_remap.ui");

	if (_def == undefined) exit;

	var _instance = ui_spawn(_def, {
		link: {},
		parent: global.gui_root
	});

	global.ui_settings_rebind = {
		instance: _instance,
		setting_name: _setting_name,
		button: _button,
		is_gamepad: _is_gamepad
	}

	var _title = ui_get(_instance, "label_title");
	var _instruction = ui_get(_instance, "label_instruction");
	var _cancel = ui_get(_instance, "btn_cancel");
	var _display_name = loca_translate($"phantasia:settings.{_setting_name}.name");

	if (_title != undefined)
	{
		_title.text = $"Remapping: {_display_name}";
	}

	if (_instruction != undefined)
	{
		_instruction.text = _is_gamepad ? "Press any button to bind" : "Press any key to bind";
	}

	if (_cancel != undefined)
	{
		_cancel.text = loca_translate("phantasia:menu.generic.back");
		_cancel.add_event_handler("on_select_release", function() {
			menu_settings_ui_close_rebind();
		});
	}
}


function menu_settings_ui_close_rebind()
{
	if (global.ui_settings_rebind == undefined) exit;

	if (global.ui_settings_rebind.instance != undefined)
	{
		ui_destroy(global.ui_settings_rebind.instance);
	}

	global.ui_settings_rebind = undefined;
}


function menu_settings_ui_step_rebind()
{
	var _state = global.ui_settings_rebind;

	if (_state == undefined) exit;

	if (_state.is_gamepad)
	{
		var _slot = global.player_gamepad_slot;

		if (gamepad_is_connected(_slot))
		{
			var _buttons = [
				gp_face1, gp_face2, gp_face3, gp_face4,
				gp_shoulderl, gp_shoulderr, gp_shoulderlb, gp_shoulderrb,
				gp_start, gp_select, gp_stickl, gp_stickr,
				gp_padu, gp_padd, gp_padl, gp_padr
			];

			for (var i = 0; i < array_length(_buttons); ++i)
			{
				if (gamepad_button_check_pressed(_slot, _buttons[i]))
				{
					menu_settings_ui_commit_rebind(_buttons[i]);

					exit;
				}
			}
		}
	}
	else
	{
		if (keyboard_check_pressed(vk_escape))
		{
			menu_settings_ui_close_rebind();
			exit;
		}

		if (keyboard_check_released(vk_anykey))
		{
			var _key = keyboard_lastkey;

			if (_key != vk_escape)
			{
				menu_settings_ui_commit_rebind(_key);
			}
		}
	}
}


function menu_settings_ui_commit_rebind(_value)
{
	var _state = global.ui_settings_rebind;

	if (_state == undefined) exit;

	global.settings[$ _state.setting_name] = _value;
	file_save_settings();

	if (_state.button != undefined)
	{
		_state.button.text = _state.is_gamepad ? input_get_gamepad_name(_value) : input_get_name(_value);
	}

	sfx_play("phantasia:sfx/menu/button/select", global.settings.audio_ui);

	menu_settings_ui_close_rebind();
}
