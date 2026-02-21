function menu_create_player_ui_load()
{
	menu_ui_clear_all();
	
	/* clean up legacy */
	instance_destroy(obj_Menu_Button);
	instance_destroy(obj_Menu_Anchor);
	instance_destroy(obj_Menu_Textbox);
	
	/* ensure gui_root exists */
	if (!variable_global_exists("gui_root")) || (global.gui_root == undefined)
	{
		global.gui_root = new UIElement(0, 0, 960, 540);
		global.gui_root.element_name = "gui_root";
	}
	
	/* cache reload */
	if (variable_global_exists("ui_definitions"))
	{
		var _full_path = "resources/data/ui/menu/create_player.ui";
		if (struct_exists(global.ui_definitions, _full_path))
		{
			struct_remove(global.ui_definitions, _full_path);
		}
	}
	
	var _def = ui_load("ui/menu/create_player.ui");
	
	if (_def == undefined)
	{
		show_debug_message("[Menu Create Player] failed to load ui/menu/create_player.ui");
		exit;
	}
	
	var _instance = ui_spawn(_def, {
		link: {},
		parent: global.gui_root
	});
	
	global.ui_create_player_menu = _instance;
	
	menu_create_player_ui_init();
}

function menu_create_player_ui_init()
{
	var _instance = global.ui_create_player_menu;
	var _elements = _instance.elements;
	
	/* set initial data for a new player */
	global.current_player.name = "";
	global.current_player.uuid = uuid_generate(irandom(0xffffffff));
	
	/* ensure attire array has enough elements */
	if (!is_array(global.current_player.attire))
	{
	    global.current_player.attire = [];
	}
	
	while (array_length(global.current_player.attire) < 5)
	{
	    array_push(global.current_player.attire, 0);
	}

	
	with (obj_Menu_Control)
	{
		title = loca_translate("phantasia:menu.players.create");
	}
	
	/* back button */
	var _btn_back = _elements[$ "btn_back"];
	
	if (_btn_back != undefined)
	{
		_btn_back.text = loca_translate("phantasia:menu.generic.back");
		
		_btn_back.add_event_handler("on_select_release", function() {
			menu_transition_goto(rm_Menu_Players);
		});
	}
	
	/* create player button */
	var _btn_create_player = _elements[$ "btn_create_player"];
	
	if (_btn_create_player != undefined)
	{
		_btn_create_player.text = loca_translate("phantasia:menu.players.create");
		
		_btn_create_player.add_event_handler("on_select_release", function() {
			var _index = array_length(global.file_players);
			
			global.file_players[@ _index] = new FilePlayer(
                global.current_player.uuid,
                global.current_player.name,
                unix_to_datetime(datetime_to_unix())
            );
            
            var _data = global.file_players[_index];
            _data.set_attire(global.current_player.attire);
            _data.set_hp(global.current_player.hp, global.current_player.hp_max);
            _data.save();
            
            global.player_statistics = {};
            global.player_achievements = {};
            
			menu_transition_goto(rm_Menu_Worlds);
		});
	}
	
	/* name input */
	var _input_name = _elements[$ "input_name"];
	
	if (_input_name != undefined)
	{
		_input_name.text = "";
		_input_name.placeholder_text = loca_translate("phantasia:menu.players.name");
		
		_input_name.on_deselect = method(_input_name, function() {
			global.current_player.name = self.text;
		});
		
		_input_name.add_event_handler("on_step", method(_input_name, function() {
			if (global.current_player.name != self.text) && (instance_exists(obj_Input_Manager)) && (obj_Input_Manager.keyboard_focus == self)
			{
			    global.current_player.name = self.text;
			}
		}));
	}
	
	/* age input (placeholder for now) */
	var _input_age = _elements[$ "input_age"];
	
	if (_input_age != undefined)
	{
		_input_age.text = "";
		_input_age.placeholder_text = "Age";
	}
	
	/* plan input (placeholder for now) */
	var _input_plan = _elements[$ "input_plan"];
	
	if (_input_plan != undefined)
	{
		_input_plan.text = "";
		_input_plan.placeholder_text = "Plan";
	}
	
	/* avatar preview */
	var _renderer = _elements[$ "preview_renderer"];
	
	if (_renderer != undefined)
	{
		_renderer.add_event_handler("on_draw", method(_renderer, function(_x, _y, _xscale, _yscale) {
			var _rx = _x + (self.width * _xscale / 2);
			var _ry = _y + (self.height * _yscale / 2) + 32;
			
			render_attire(global.current_player.attire, 0, _rx, _ry, 8, 8);
		}));
	}
	
	/* body design row */
	var _body_design_row = _elements[$ "body_design_row"];
	
	if (_body_design_row != undefined)
	{
		menu_create_player_ui_build_option_row(
			_body_design_row,
			1,
			array_length(global.attire_data.hair)
		);
	}
	
	/* colour row */
	var _colour_row = _elements[$ "colour_row"];
	
	if (_colour_row != undefined)
	{
		menu_create_player_ui_build_colour_row(
			_colour_row,
			0,
			array_length(global.attire_colour_data)
		);
	}
	
	/* additional design options (shirt, etc.) */
	var _design_list = _elements[$ "design_list"];
	
	if (_design_list != undefined)
	{
		var _y_pos = 0;
		var _spacing = 64;
		
		_y_pos = menu_create_player_ui_build_labeled_row(
			_design_list, _y_pos, "phantasia:menu.players.shirt", 2,
			array_length(global.attire_data.shirt)
		);
		
		/* voice button */
		var _btn_voice = new UIButton(0, _y_pos + 8, 200, 28, "");
		var _voices = ["boy", "girl"];
		var _current_voice_index = global.current_player.attire[4];
		var _voice_str = loca_translate($"phantasia:menu.players.voice.{_voices[_current_voice_index]}");
		
		_btn_voice.text = $"{loca_translate("phantasia:menu.players.voice")}: {_voice_str}";
		_btn_voice.parent = _design_list;
		
		_btn_voice.add_event_handler("on_select_release", method({ btn: _btn_voice, voices: _voices }, function() {
			var _v_index = global.current_player.attire[4];
			_v_index = (_v_index + 1) mod array_length(self.voices);
			global.current_player.attire[@ 4] = _v_index;
			
			var _v_str = loca_translate($"phantasia:menu.players.voice.{self.voices[_v_index]}");
			self.btn.text = $"{loca_translate("phantasia:menu.players.voice")}: {_v_str}";
		}));
		
		array_push(_design_list.children, _btn_voice);

		_y_pos += 44;
		
		/* pitch slider */
		var _pitch_label = new UIText(0, _y_pos, "");
		_pitch_label.text = "Pitch";
		_pitch_label.text_halign = "fa_left";
		_pitch_label.parent = _design_list;

		array_push(_design_list.children, _pitch_label);
		
		var _slider_pitch = new UISlider(120, _y_pos, 160, 16, 0.5, 1.5, 1.0);
		_slider_pitch.parent = _design_list;
		_slider_pitch.value = global.current_player.attire[3] == 0 ? 1 : global.current_player.attire[3];
		
		_slider_pitch.add_event_handler("on_value_change", method(_slider_pitch, function(_new_value) {
			global.current_player.attire[@ 3] = _new_value;
		}));
		
		array_push(_design_list.children, _slider_pitch);

		_y_pos += 32;
		
		_design_list.height = _y_pos + 16;
	}
}


/// @desc Builds a row of body-design option buttons (hair styles, etc.)
function menu_create_player_ui_build_option_row(_parent, _attire_index, _max_options)
{
	var _btn_size    = 40;
	var _btn_spacing = 4;
	
	for (var i = 0; i < _max_options; ++i)
	{
		var _btn = new UIButton(i * (_btn_size + _btn_spacing), 0, _btn_size, _btn_size, "");
		
		_btn.parent       = _parent;
		_btn.attire_index = _attire_index;
		_btn.option_value = i;
		
		_btn.add_event_handler("on_draw", method(_btn, function(_x, _y, _xs, _ys) {
			var _selected = global.current_player.attire[self.attire_index] == self.option_value;
			
			if (_selected)
			{
				draw_sprite_ext(spr_Square, 0, _x, _y, _xs * (self.width / 16), _ys * (self.height / 16), 0, c_white, 0.2);
			}
			
			var _cx = _x + (self.width * _xs / 2);
			var _cy = _y + (self.height * _ys / 2);
			
			if (self.attire_index == 1)
			{
				var _ha = global.attire_data.hair[self.option_value];
				var _sprite_asset = _ha.get_sprite_colour();
				var _sprite = is_array(_sprite_asset) ? _sprite_asset[0].get_sprite() : _sprite_asset.get_sprite();

				draw_sprite_ext(_sprite, 0, _cx, _cy + 8, 2, 2, 0, c_white, 1);
			}
			else if (self.attire_index == 2)
			{
				var _sa = global.attire_data.shirt[self.option_value];
				var _sprite_asset = _sa.get_sprite_colour();
				var _sprite = is_array(_sprite_asset) ? _sprite_asset[0].get_sprite() : _sprite_asset.get_sprite();

				draw_sprite_ext(_sprite, 0, _cx, _cy + 8, 2, 2, 0, c_white, 1);
			}
		}));
		
		_btn.add_event_handler("on_select_release", method(_btn, function() {
			global.current_player.attire[@ self.attire_index] = self.option_value;
		}));
		
		array_push(_parent.children, _btn);
	}
}


/// @desc Builds a row of color swatch buttons.
function menu_create_player_ui_build_colour_row(_parent, _attire_index, _max_options)
{
	var _btn_size    = 32;
	var _btn_spacing = 4;
	
	for (var i = 0; i < _max_options; ++i)
	{
		var _btn = new UIButton(i * (_btn_size + _btn_spacing), 4, _btn_size, _btn_size, "");
		
		_btn.parent       = _parent;
		_btn.attire_index = _attire_index;
		_btn.option_value = i;
		
		_btn.add_event_handler("on_draw", method(_btn, function(_x, _y, _xs, _ys) {
			var _selected = global.current_player.attire[self.attire_index] == self.option_value;
			var _palette = global.attire_colour_data[self.option_value];
			var _c = _palette[0];
			
			var _w = self.width * _xs;
			var _h = self.height * _ys;
			
			draw_rectangle_colour(_x + 2, _y + 2, _x + _w - 2, _y + _h - 2, _c, _c, _c, _c, false);
			
			if (_selected)
			{
				draw_rectangle_colour(_x, _y, _x + _w, _y + _h, c_white, c_white, c_white, c_white, true);
			}
		}));
		
		_btn.add_event_handler("on_select_release", method(_btn, function() {
			global.current_player.attire[@ self.attire_index] = self.option_value;
		}));
		
		array_push(_parent.children, _btn);
	}
}


/// @desc Builds a labeled row of option buttons with a text label.
function menu_create_player_ui_build_labeled_row(_parent, _y, _label_key, _attire_index, _max_options)
{
	var _label = new UIText(0, _y, "");
	_label.text = loca_translate(_label_key);
	_label.text_halign = "fa_left";
	_label.text_scale = 0.8;
	_label.colour = c_ltgray;
	_label.parent = _parent;

	array_push(_parent.children, _label);
	
	var _btn_size    = 40;
	var _btn_spacing = 4;
	var _row_y = _y + 20;
	
	for (var i = 0; i < _max_options; ++i)
	{
		var _btn = new UIButton(i * (_btn_size + _btn_spacing), _row_y, _btn_size, _btn_size, "");
		
		_btn.parent       = _parent;
		_btn.attire_index = _attire_index;
		_btn.option_value = i;
		
		_btn.add_event_handler("on_draw", method(_btn, function(_x, _y, _xs, _ys) {
			var _selected = global.current_player.attire[self.attire_index] == self.option_value;
			
			if (_selected)
			{
				draw_sprite_ext(spr_Square, 0, _x, _y, _xs * (self.width / 16), _ys * (self.height / 16), 0, c_white, 0.2);
			}
			
			var _cx = _x + (self.width * _xs / 2);
			var _cy = _y + (self.height * _ys / 2);
			
			if (self.attire_index == 2)
			{
				var _sa = global.attire_data.shirt[self.option_value];
				var _sprite_asset = _sa.get_sprite_colour();
				var _sprite = is_array(_sprite_asset) ? _sprite_asset[0].get_sprite() : _sprite_asset.get_sprite();

				draw_sprite_ext(_sprite, 0, _cx, _cy + 8, 2, 2, 0, c_white, 1);
			}
			else if (self.attire_index == 0)
			{
				var _palette = global.attire_colour_data[self.option_value];
				var _c = _palette[0];

				draw_sprite_ext(spr_Player_Base, 0, _cx, _cy + 8, 2, 2, 0, _c, 1);
			}
			else if (self.attire_index == 1)
			{
				var _ha = global.attire_data.hair[self.option_value];
				var _sprite_asset = _ha.get_sprite_colour();
				var _sprite = is_array(_sprite_asset) ? _sprite_asset[0].get_sprite() : _sprite_asset.get_sprite();

				draw_sprite_ext(_sprite, 0, _cx, _cy + 8, 2, 2, 0, c_white, 1);
			}
		}));
		
		_btn.add_event_handler("on_select_release", method(_btn, function() {
			global.current_player.attire[@ self.attire_index] = self.option_value;
		}));
		
		array_push(_parent.children, _btn);
	}
	
	return _row_y + _btn_size + 8;
}

