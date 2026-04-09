global.ui_settings_menu = undefined;
global.menu_settings_back_handler = undefined;
global.ui_settings_rebind = undefined;
global.menu_settings_scroll_offsets = {};


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
	global.menu_settings_scroll_offsets = {};
	
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

	var _title = _elements[$ "title"];
	if (_title != undefined)
	{
		_title.text = menu_ui_localize_or_default("phantasia:menu.settings.title", "Settings");
	}

	/* back button */
	var _btn_back = _elements[$ "btn_back"];
	if (_btn_back != undefined)
	{
		_btn_back.text = menu_ui_localize_or_default("phantasia:menu.generic.back", "Back");
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
	var _categories = ["general", "graphics", "controls", "audio", "accessibility"];
	
	for (var i = 0; i < array_length(_categories); ++i)
	{
		var _category = _categories[i];
		var _button = _elements[$ "btn_cat_" + _category];

		if (_button != undefined)
		{
			_button.text = menu_settings_ui_get_category_label(_category);
			_button.setting_category = _category;
			_button.add_event_handler("on_select_release", method(_button, function() {
				menu_settings_ui_store_scroll_offset();
				global.settings_current_category = self.setting_category;
				menu_settings_ui_populate_list();
			}));
		}
	}

	menu_settings_ui_populate_list();
}


function menu_settings_ui_store_scroll_offset()
{
	var _instance = global.ui_settings_menu;
	if (_instance == undefined) exit;

	var _scroll = ui_get(_instance, "settings_scroll");
	if (_scroll == undefined) exit;

	var _resolved = menu_settings_ui_resolve_category(global.settings_current_category);
	global.menu_settings_scroll_offsets[$ _resolved] = _scroll.scroll_offset;
}


function menu_settings_ui_populate_list()
{
	var _instance = global.ui_settings_menu;
	if (_instance == undefined) exit;

	var _list = ui_get(_instance, "settings_list");
	var _scroll = ui_get(_instance, "settings_scroll");
	var _category_title = ui_get(_instance, "category_title");

	if (_list == undefined || _scroll == undefined) exit;

	_list.children = [];
	_scroll.scroll_offset = 0;

	var _resolved_category = menu_settings_ui_resolve_category(global.settings_current_category);
	var _row_width = _list.width;
	var _y = 0;
	var _sections = menu_settings_ui_get_sections(_resolved_category);

	if (_category_title != undefined)
	{
		var _title_key = (global.settings_current_category == "controls") ? "controls" : _resolved_category;
		_category_title.text = menu_settings_ui_get_category_label(_title_key);
	}

	menu_settings_ui_refresh_category_buttons();

	if (_resolved_category == "controls" || _resolved_category == "controls_gamepad")
	{
		_y = menu_settings_ui_add_input_mode_row(_list, _row_width, _y);
	}

	for (var i = 0; i < array_length(_sections); ++i)
	{
		var _section = _sections[i];
		_y = menu_settings_ui_add_section_header(_list, _row_width, _y, _section.title);

		for (var j = 0; j < array_length(_section.items); ++j)
		{
			_y = menu_settings_ui_add_setting_row(_list, _row_width, _y, _section.items[j]);
		}
	}

	_list.height = _y;
	if (struct_exists(_scroll, "recalculate_content_size"))
	{
		_scroll.recalculate_content_size();
	}
	_scroll.scroll_offset = clamp(global.menu_settings_scroll_offsets[$ _resolved_category] ?? 0, 0, _scroll.get_max_scroll());
}


function menu_settings_ui_get_category_label(_category)
{
	switch (_category)
	{
		case "general": return menu_ui_localize_or_default("phantasia:menu.settings.general", "General");
		case "graphics": return menu_ui_localize_or_default("phantasia:menu.settings.graphics", "Graphics");
		case "controls":
		case "controls_gamepad":
		case "controls_touch":
			return menu_ui_localize_or_default("phantasia:menu.settings.controls", "Controls");
		case "audio": return menu_ui_localize_or_default("phantasia:menu.settings.audio", "Audio");
		case "accessibility": return menu_ui_localize_or_default("phantasia:menu.settings.accessibility", "Accessibility");
	}

	return string(_category);
}


function menu_settings_ui_refresh_category_buttons()
{
	var _instance = global.ui_settings_menu;
	if (_instance == undefined) exit;

	var _categories = ["general", "graphics", "controls", "audio", "accessibility"];

	for (var i = 0; i < array_length(_categories); ++i)
	{
		var _category = _categories[i];
		var _button = ui_get(_instance, "btn_cat_" + _category);

		if (_button != undefined)
		{
			_button.sprite_index = (_category == global.settings_current_category) ? spr_Menu_Button_Secondary : spr_Menu_Button_Main;
		}
	}
}


function menu_settings_ui_resolve_category(_category)
{
	if (_category == "controls") || (_category == "controls_gamepad") || (_category == "controls_touch")
	{
		var _resolved = "controls_" + global.controls_input_type;
		if (global.controls_input_type == "keyboard") _resolved = "controls";
		return _resolved;
	}

	return _category;
}


function menu_settings_ui_get_sections(_resolved_category)
{
	switch (_resolved_category)
	{
		case "general":
			return [
				{ title: "Platform", items: ["discord_rpc"] },
				{ title: "Menu", items: ["menu_toast", "menu_profanity_filter", "menu_skip_epilepsy"] }
			];

		case "graphics":
			return [
				{ title: "Scene", items: ["display_background", "display_coloured_lighting", "display_blur", "display_strength_particles", "display_strength_weather"] },
				{ title: "Window", items: ["window_gui_size", "window_fullscreen", "window_borderless", "window_vsync"] },
				{ title: "Transitions", items: ["graphics_chunk_fade_time", "graphics_background_transition_speed", "graphics_menu_transition_fade_speed"] }
			];

		case "controls":
			return [
				{ title: "Movement", items: ["input_keyboard_left", "input_keyboard_right", "input_keyboard_jump", "input_keyboard_climb_up", "input_keyboard_climb_down"] },
				{ title: "Interface", items: ["input_keyboard_pause", "input_keyboard_inventory", "input_keyboard_drop"] }
			];

		case "controls_gamepad":
			return [
				{ title: "Actions", items: ["input_gamepad_jump", "input_gamepad_attack", "input_gamepad_use", "input_gamepad_mount"] },
				{ title: "Interface", items: ["input_gamepad_pause", "input_gamepad_inventory"] }
			];

		case "audio":
			return [
				{ title: "Master", items: ["audio_master", "audio_music"] },
				{ title: "Effects", items: ["audio_sfx", "audio_ui", "audio_tile", "audio_creature_passive", "audio_creature_hostile"] }
			];

		case "accessibility":
			return [
				{ title: "Performance", items: ["global_refresh_rate"] },
				{ title: "Language", items: ["global_localization"] }
			];
	}

	var _fallback = global.settings_data_category[$ _resolved_category] ?? [];
	return [{ title: "Settings", items: _fallback }];
}


function menu_settings_ui_add_section_header(_list, _row_width, _y, _title)
{
	var _header = new UIArea(0, _y, _row_width, 28);
	_header.parent = _list;

	var _label = new UIText(0, 10, _title);
	_label.halign = fa_left;
	_label.valign = fa_middle;
	_label.text_scale = 0.88;
	_label.colour = c_white;
	_label.parent = _header;
	array_push(_header.children, _label);

	var _line = new UILine(0, 0);
	_line.start_x = 124;
	_line.start_y = 11;
	_line.end_x = _row_width;
	_line.end_y = 11;
	_line.thickness = 1;
	_line.colour = menu_ui_get_metrics().card_border;
	_line.parent = _header;
	array_push(_header.children, _line);

	array_push(_list.children, _header);

	return _y + 34;
}


function menu_settings_ui_add_input_mode_row(_list, _row_width, _y)
{
	var _metrics = menu_ui_get_metrics();
	var _container = new UIArea(0, _y, _row_width, 76);
	_container.background_color = _metrics.card_background;
	_container.border_color = _metrics.card_border;
	_container.parent = _list;

	var _label = new UIText(12, 16, "Input Mode");
	_label.halign = fa_left;
	_label.valign = fa_top;
	_label.parent = _container;
	array_push(_container.children, _label);

	var _desc = new UIText(12, 38, "Choose which control profile to edit.");
	_desc.halign = fa_left;
	_desc.valign = fa_top;
	_desc.text_scale = 0.72;
	_desc.colour = _metrics.text_dim;
	_desc.parent = _container;
	array_push(_container.children, _desc);

	var _dropdown = new UIDropdown(_row_width - 196, 24, 184, 24);
	_dropdown.parent = _container;
	_dropdown.set_choices(["Keyboard", "Gamepad"]);
	_dropdown.set_selected((global.controls_input_type == "gamepad") ? 1 : 0);
	_dropdown.add_event_handler("on_change", method(_dropdown, function(_data) {
		global.controls_input_type = (self.choice_index == 1) ? "gamepad" : "keyboard";
		menu_settings_ui_populate_list();
	}));
	array_push(_container.children, _dropdown);

	array_push(_list.children, _container);

	return _y + 88;
}


function menu_settings_ui_add_setting_row(_list, _row_width, _y, _name)
{
	var _metrics = menu_ui_get_metrics();
	var _data = global.settings_data[$ _name];
	if (_data == undefined) return _y;

	var _value = global.settings[$ _name];
	var _type = _data.get_type();
	var _control_width = 184;
	var _control_x = _row_width - _control_width - 12;
	var _container = new UIArea(0, _y, _row_width, 76);
	_container.background_color = _metrics.card_background;
	_container.border_color = _metrics.card_border;
	_container.parent = _list;

	var _label = new UIText(12, 16, loca_translate($"phantasia:settings.{_name}.name"));
	_label.halign = fa_left;
	_label.valign = fa_top;
	_label.parent = _container;
	array_push(_container.children, _label);

	var _desc = new UIText(12, 38, loca_translate($"phantasia:settings.{_name}.description"));
	_desc.halign = fa_left;
	_desc.valign = fa_top;
	_desc.text_scale = 0.72;
	_desc.colour = _metrics.text_dim;
	_desc.parent = _container;
	array_push(_container.children, _desc);

	switch (_type)
	{
		case SETTINGS_TYPE.SLIDER:
			var _slider = new UISlider(_control_x, 30, _control_width, _data.get_range_min(), max(_data.get_range_max(), 1), _value);
			_slider.setting_name = _name;
			if (_data.get_step() != undefined) _slider.step = _data.get_step();
			_slider.parent = _container;
			_slider.add_event_handler("on_drag", method(_slider, function(_payload) {
				var _new_value = _payload.value;
				var _on_update = global.settings_data[$ self.setting_name].get_on_update();
				if (_on_update != undefined) _on_update(self.setting_name, _new_value);
				global.settings[$ self.setting_name] = _new_value;
			}));
			_slider.add_event_handler("on_value_change", method(_slider, function(_new_value) {
				var _on_update = global.settings_data[$ self.setting_name].get_on_update();
				if (_on_update != undefined) _on_update(self.setting_name, _new_value);
				global.settings[$ self.setting_name] = _new_value;
				
				var _on_release = global.settings_data[$ self.setting_name].get_on_release();
				if (_on_release != undefined) _on_release(self.setting_name, _new_value);
				
				file_save_settings();
			}));
			array_push(_container.children, _slider);
			break;

		case SETTINGS_TYPE.SWITCH:
			var _switch = new UIRadioButton(_row_width - 44, 30, "");
			_switch.width = 32;
			_switch.height = 16;
			_switch.set_selected(_value);
			_switch.setting_name = _name;
			_switch.parent = _container;
			_switch.add_event_handler("on_select_release", method(_switch, function() {
				var _new_value = self.selected;
				var _on_update = global.settings_data[$ self.setting_name].get_on_update();
				if (_on_update != undefined) _on_update(self.setting_name, _new_value);
				
				var _on_release = global.settings_data[$ self.setting_name].get_on_release();
				if (_on_release != undefined) _on_release(self.setting_name, _new_value);
				
				global.settings[$ self.setting_name] = _new_value;
				file_save_settings();
			}));
			array_push(_container.children, _switch);
			break;

		case SETTINGS_TYPE.HOTKEY:
			var _is_gamepad = string_pos("gamepad", _name) > 0;
			var _key_name = _is_gamepad ? input_get_gamepad_name(_value) : input_get_name(_value);
			var _button = new UIButton(_control_x, 22, _control_width, 32, _key_name);
			_button.setting_name = _name;
			_button.is_gamepad_setting = _is_gamepad;
			_button.parent = _container;
			_button.add_event_handler("on_select_release", method(_button, function() {
				menu_settings_ui_open_rebind(self.setting_name, self, self.is_gamepad_setting);
			}));
			array_push(_container.children, _button);
			break;

		case SETTINGS_TYPE.ARROW:
			var _dropdown = new UIDropdown(_control_x, 22, _control_width, 24);
			_dropdown.setting_name = _name;
			_dropdown.parent = _container;
			_dropdown.set_choices(menu_settings_ui_get_choice_labels(_name));
			_dropdown.set_selected(_value);
			_dropdown.add_event_handler("on_change", method(_dropdown, function(_payload) {
				var _new_index = self.choice_index;
				var _on_update = global.settings_data[$ self.setting_name].get_on_update();
				if (_on_update != undefined) _on_update(self.setting_name, _new_index);
				global.settings[$ self.setting_name] = _new_index;

				var _on_release = global.settings_data[$ self.setting_name].get_on_release();
				if (_on_release != undefined) _on_release(self.setting_name, _new_index);

				file_save_settings();
			}));
			array_push(_container.children, _dropdown);
			break;
	}

	array_push(_list.children, _container);

	return _y + 88;
}


function menu_settings_ui_get_choice_labels(_setting_name)
{
	var _data = global.settings_data[$ _setting_name];
	var _values = (_data != undefined) ? (_data.get_values() ?? []) : [];
	var _labels = [];

	for (var i = 0; i < array_length(_values); ++i)
	{
		var _value = _values[i];

		if (_setting_name == "global_refresh_rate")
		{
			array_push(_labels, string(_value) + " FPS");
		}
		else
		{
			array_push(_labels, menu_ui_format_option_label(_value));
		}
	}

	return _labels;
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
