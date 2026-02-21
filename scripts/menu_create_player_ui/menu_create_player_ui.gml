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
	
	/* Set initial data for a new player */
	global.current_player.name = "";
	global.current_player.uuid = file_generate_uuid();
	
	/* Note: attire components mapping:
	 * 0: Base Body/Color
	 * 1: Hair Type
	 * 2: Shirt Color
	 * 3: Voice Pitch
	 * 4: Voice Type
	 */
	// Ensure array has enough elements
	while (array_length(global.current_player.attire) < 5) {
	    array_push(global.current_player.attire, 0);
	}
	
	with (obj_Menu_Control)
	{
		title = loca_translate("phantasia:menu.players.create");
	}
	
	/* buttons */
	var _btn_back = _elements[$ "btn_back"];
	
	if (_btn_back != undefined)
	{
		_btn_back.text = loca_translate("phantasia:menu.generic.back");
		
		_btn_back.add_event_handler("on_select_release", function() {
			menu_transition_goto(rm_Menu_Players);
		});
	}
	
	var _btn_create_player = _elements[$ "btn_create_player"];
	
	if (_btn_create_player != undefined)
	{
		_btn_create_player.text = loca_translate("phantasia:menu.players.create");
		
		_btn_create_player.add_event_handler("on_select_release", function() {
			// Save using legacy system
			var _index = global.players_list_length;
			
			global.file_players[@ _index] = new FilePlayer(
                global.current_player.uuid,
                global.current_player.name,
                global.current_player.attire
            );
            
            var _data = global.file_players[_index];
            _data.save();
            
            global.player_statistics = {};
            global.player_achievements = {};
            
            file_write_directory(PROGRAM_DIRECTORY_PLAYERS);
            
			menu_transition_goto(rm_Menu_Worlds);
		});
	}
	
	var _input_name = _elements[$ "input_name"];
	if (_input_name != undefined)
	{
		_input_name.text = "";
		_input_name.placeholder_text = loca_translate("phantasia:menu.players.name");
		
		// Setup text box callbacks
		_input_name.on_deselect = method(_input_name, function() {
			global.current_player.name = self.text;
		});
		
		// Hack to constantly update the global struct for now
		_input_name.add_event_handler("on_step", method(_input_name, function() {
			if (global.current_player.name != self.text && instance_exists(obj_Input_Manager) && obj_Input_Manager.keyboard_focus == self) {
			    global.current_player.name = self.text;
			}
		}));
	}
	
	var _slider_pitch = _elements[$ "slider_pitch"];
	if (_slider_pitch != undefined)
	{
		_slider_pitch.value = global.current_player.attire[3] == 0 ? 1 : global.current_player.attire[3]; // Fallback to 1 if 0
		_slider_pitch.add_event_handler("on_value_change", method(_slider_pitch, function(_new_value) {
			global.current_player.attire[@ 3] = _new_value;
		}));
	}
	
	var _btn_voice = _elements[$ "btn_voice"];
	if (_btn_voice != undefined)
	{
		var _voices = ["boy", "girl"]; // Could be fetched dynamically but hardcoding for demo
		var _current_voice_index = global.current_player.attire[4];
		
		// Init translation text
		var _voice_str = loca_translate($"phantasia:menu.players.voice.{_voices[_current_voice_index]}");
		_btn_voice.text = $"{loca_translate("phantasia:menu.players.voice")}: {_voice_str}";
		
		_btn_voice.add_event_handler("on_select_release", method({ btn: _btn_voice, voices: _voices }, function() {
			var _v_index = global.current_player.attire[4];
			_v_index = (_v_index + 1) mod array_length(self.voices);
			global.current_player.attire[@ 4] = _v_index;
			
			var _v_str = loca_translate($"phantasia:menu.players.voice.{self.voices[_v_index]}");
			self.btn.text = $"{loca_translate("phantasia:menu.players.voice")}: {_v_str}";
			
			// Try playing sample
			var _snd = asset_get_index($"snd_Player_{self.voices[_v_index]}_Hurt_1");
			if (_snd != -1) {
				audio_play_sound_ext({ sound: _snd, pitch: global.current_player.attire[3] / 100 });
			}
		}));
	}
	
	var _renderer = _elements[$ "preview_renderer"];
	if (_renderer != undefined)
	{
		_renderer.add_event_handler("on_draw", method(_renderer, function(_x, _y, _xscale, _yscale) {
			// Center the sprite rendering in the renderer box
			var _rx = _x + (self.width * _xscale / 2);
			var _ry = _y + (self.height * _yscale / 2) + 32;
			
			render_attire_ext(global.current_player.attire, _rx, _ry, 8, 8, 0, c_white, 1);
		}));
	}
	
	// Right column - Design options
	var _design_list = _elements[$ "design_list"];
	if (_design_list != undefined)
	{
		var _y_pos = 0;
		var _spacing = 64;
		
		// Helper function to build a row of option buttons programmatically
		var _build_options_row = function(_parent, _y, _labelKey, _attireIndex, _maxOptions) {
			var _label = new UIText(0, _y, "");
			_label.text = loca_translate(_labelKey);
			_label.text_halign = "fa_left";
			_label.text_valign = "fa_middle";
			_label.parent = _parent;
			array_push(_parent.children, _label);
			
			var _btn_size = 48;
			var _btn_spacing = 16;
			
			for(var i=0; i<_maxOptions; i++) {
				var _btn_x = 220 + (i * (_btn_size + _btn_spacing));
				var _btn = new UIButton(_btn_x, _y - (_btn_size/2), _btn_size, _btn_size, "");
				
				_btn.parent = _parent;
				_btn.attire_index = _attireIndex;
				_btn.option_value = i;
				
				// Draw different things depending on what we're customizing
				_btn.add_event_handler("on_draw", method(_btn, function(_x, _y, _xs, _ys) {
					var _selected = global.current_player.attire[self.attire_index] == self.option_value;
					
					// Draw a highlight if selected
					if (_selected) {
						draw_sprite_ext(spr_Square, 0, _x, _y, _xs*(self.width/16), _ys*(self.height/16), 0, c_white, 0.2);
					}
					
					// Draw preview icon. (Using specific generic sprites)
					var _cx = _x + (self.width*_xs/2);
					var _cy = _y + (self.height*_ys/2);
					
					if (self.attire_index == 0) {
						// Body color
						var _c = global.player_var_colour_fill[self.option_value];
						draw_sprite_ext(spr_Player_Base, 0, _cx, _cy + 8, 2, 2, 0, _c, 1);
					} else if (self.attire_index == 1) {
						// Hair
						var _ha = global.player_var_attire_hair[self.option_value];
						draw_sprite_ext(_ha.sprite, 0, _cx, _cy + 8, 2, 2, 0, c_white, 1);
					} else if (self.attire_index == 2) {
						// Shirt
						var _sa = global.player_var_attire_shirt[self.option_value];
						draw_sprite_ext(_sa.sprite, 0, _cx, _cy + 8, 2, 2, 0, c_white, 1);
					}
				}));
				
				_btn.add_event_handler("on_select_release", method(_btn, function() {
					global.current_player.attire[@ self.attire_index] = self.option_value;
				}));
				
				array_push(_parent.children, _btn);
			}
			
			return _y + _spacing;
		};
		
		_y_pos = _build_options_row(_design_list, _y_pos + 48, "phantasia:menu.players.colour", 0, array_length(global.player_var_colour_fill));
		_y_pos = _build_options_row(_design_list, _y_pos + 16, "phantasia:menu.players.hair", 1, array_length(global.player_var_attire_hair));
		_y_pos = _build_options_row(_design_list, _y_pos + 16, "phantasia:menu.players.shirt", 2, array_length(global.player_var_attire_shirt));
		
		var _scroll = _elements[$ "design_scroll"];
		if (_scroll) {
			// Update bounds appropriately
			_design_list.height = _y_pos + 32;
		}
	}
}
