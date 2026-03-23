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
		global.gui_root = ui_create_root();
		global.gui_root.element_name = "gui_root";
	}
	
	/* cache reload */
	ui_invalidate_definition("ui/menu/create_player.ui");
	
	var _def = ui_load("ui/menu/create_player.ui");
	
	if (_def == undefined)
	{
		PRINT("[Menu Create Player] failed to load ui/menu/create_player.ui");
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
	global.current_player.attire = [33, 1, 0, 1.0, 0];
	global.menu_create_player_tab = "all";
	
	with (obj_Menu_Control)
	{
		title = loca_translate("phantasia:menu.players.create");
	}

	var _title = _elements[$ "title"];

	if (_title != undefined)
	{
		_title.text = loca_translate("phantasia:menu.players.create");
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
            
            global.player_statistics = {}
            global.player_achievements = {}
            
			menu_transition_goto(rm_Menu_Worlds);
		});
	}
	
	/* name input */
	var _input_name = _elements[$ "input_name"];
	
	if (_input_name != undefined)
	{
		_input_name.placeholder = loca_translate("phantasia:menu.players.name");
		_input_name.set_value(global.current_player.name);

		_input_name.add_event_handler("on_input", method(_input_name, function(_data) {
			global.current_player.name = self.text;
		}));

		_input_name.add_event_handler("on_change", method(_input_name, function(_data) {
			global.current_player.name = self.text;
		}));

		_input_name.add_event_handler("on_submit", method(_input_name, function(_data) {
			global.current_player.name = self.text;
		}));
	}

	/* voice dropdown */
	var _input_voice = _elements[$ "input_voice"];

	if (_input_voice != undefined)
	{
		var _voices = [
			loca_translate("phantasia:menu.players.voice.boy"),
			loca_translate("phantasia:menu.players.voice.girl")
		];

		_input_voice.set_choices(_voices);
		_input_voice.set_selected(global.current_player.attire[4]);

		_input_voice.add_event_handler("on_change", method(_input_voice, function(_data) {
			global.current_player.attire[@ 4] = self.choice_index;
		}));
	}

	/* pitch slider */
	var _input_pitch = _elements[$ "input_pitch"];

	if (_input_pitch != undefined)
	{
		_input_pitch.step = 1;
		_input_pitch.set_value(round((global.current_player.attire[3] - 1) * 100));

		_input_pitch.add_event_handler("on_drag", method(_input_pitch, function(_data) {
			global.current_player.attire[@ 3] = 1 + (self.value / 100);
		}));

		_input_pitch.add_event_handler("on_value_change", method(_input_pitch, function(_new_value) {
			global.current_player.attire[@ 3] = 1 + (self.value / 100);
		}));
	}
	
	/* avatar preview */
	var _renderer = _elements[$ "preview_renderer"];
	
	if (_renderer != undefined)
	{
		_renderer.on_draw = method(_renderer, function(_x, _y, _xscale, _yscale) {
			var _rx = _x + (self.width * _xscale / 2);
			var _ry = _y + (self.height * _yscale / 2) + (32 * _yscale);
			
			render_attire(global.current_player.attire, 0, _rx, _ry, 8 * _xscale, 8 * _yscale);
		});
	}

	menu_create_player_ui_build_tabs();
	menu_create_player_ui_build_colour_row(ui_get(_instance, "colour_row"), 0, array_length(global.attire_colour_data));
	menu_create_player_ui_refresh_options();
}


function menu_create_player_ui_build_tabs()
{
	var _tabs = ui_get(global.ui_create_player_menu, "type_tabs");

	if (_tabs == undefined) exit;

	_tabs.children = [];

	var _definitions = [
		{ id: "all", text: "All" },
		{ id: "hair", text: "Hair" },
		{ id: "shirt", text: "Shirt" }
	];

	for (var i = 0; i < array_length(_definitions); ++i)
	{
		var _definition = _definitions[i];
		var _btn = new UIButton(0, 0, 133, 28, _definition.text);

		_btn.tab_id = _definition.id;
		_btn.sprite_index = (global.menu_create_player_tab == _definition.id) ? spr_Menu_Button_Secondary : spr_Menu_Button_Main;
		_btn.add_event_handler("on_select_release", method(_btn, function() {
			global.menu_create_player_tab = self.tab_id;
			menu_create_player_ui_refresh_options();
		}));

		_tabs.add_child(_btn);
	}

	_tabs.layout_children();
}


function menu_create_player_ui_refresh_options()
{
	var _instance = global.ui_create_player_menu;

	if (_instance == undefined) exit;

	var _style_row = ui_get(_instance, "style_row");
	var _design_list = ui_get(_instance, "design_list");
	var _design_scroll = ui_get(_instance, "design_scroll");
	var _label_style = ui_get(_instance, "label_style");
	var _label_design = ui_get(_instance, "label_design");
	var _label_colour = ui_get(_instance, "label_colour");
	var _type_tabs = ui_get(_instance, "type_tabs");

	if (_style_row == undefined) || (_design_list == undefined) || (_design_scroll == undefined) exit;

	_style_row.children = [];
	_design_list.children = [];
	_design_list.height = 0;
	_design_scroll.scroll_offset = 0;

	if (_type_tabs != undefined)
	{
		for (var i = array_length(_type_tabs.children) - 1; i >= 0; --i)
		{
			var _tab = _type_tabs.children[i];

			if (instanceof(_tab) == "UIButton")
			{
				_tab.sprite_index = (_tab.tab_id == global.menu_create_player_tab) ? spr_Menu_Button_Secondary : spr_Menu_Button_Main;
			}
		}
	}

	var _style_kind = "hair";
	var _style_label = "Hair";
	var _design_kind = "shirt";
	var _design_label = "Shirt";
	var _style_start = 0;
	var _design_start = 0;

	switch (global.menu_create_player_tab)
	{
		case "hair":
			_style_kind = "hair";
			_style_label = "Hair";
			_design_kind = "hair";
			_design_label = "More Hair";
			_design_start = 6;
			break;

		case "shirt":
			_style_kind = "shirt";
			_style_label = "Shirt";
			_design_kind = "shirt";
			_design_label = "More Shirts";
			_design_start = 6;
			break;
	}

	if (_label_style != undefined) _label_style.text = _style_label;
	if (_label_design != undefined) _label_design.text = _design_label;
	if (_label_colour != undefined) _label_colour.text = "Colour";

	menu_create_player_ui_build_attire_buttons(_style_row, _style_kind, _style_start, 6);

	var _design_data = global.attire_data[$ _design_kind];
	var _design_count = max(0, array_length(_design_data) - _design_start);

	if (_design_count > 0)
	{
		menu_create_player_ui_build_attire_buttons(_design_list, _design_kind, _design_start, _design_count);
		_design_list.height = ceil(_design_count / 6) * 50;
		_design_scroll.visible = true;

		if (_label_design != undefined) _label_design.visible = true;
	}
	else
	{
		_design_scroll.visible = false;

		if (_label_design != undefined) _label_design.visible = false;
	}

	_style_row.layout_children();
	_design_list.layout_children();
}


function menu_create_player_ui_build_attire_buttons(_parent, _kind, _start, _count)
{
	if (_parent == undefined) exit;

	var _attire_data = global.attire_data[$ _kind];
	var _attire_index = (_kind == "hair") ? 1 : 2;
	var _max_count = array_length(_attire_data);

	for (var i = 0; i < _count; ++i)
	{
		var _option_value = _start + i;

		if (_option_value >= _max_count) break;

		var _btn = new UIButton(0, 0, 62, 44, "");

		_btn.option_kind = _kind;
		_btn.attire_index = _attire_index;
		_btn.option_value = _option_value;
		_btn.on_draw = method(_btn, function(_x, _y, _xs, _ys) {
			var _selected = global.current_player.attire[self.attire_index] == self.option_value;
			var _w = self.width * _xs;
			var _h = self.height * _ys;
			var _cx = _x + (_w / 2);
			var _cy = _y + (_h / 2) + (8 * _ys);

			if (_selected)
			{
				draw_rectangle_colour(_x + 1, _y + 1, _x + _w - 1, _y + _h - 1, c_white, c_white, c_white, c_white, true);
			}

			if (self.option_kind == "hair")
			{
				var _ha = global.attire_data.hair[self.option_value];
				var _sprite_asset = _ha.get_sprite_colour();
				var _sprite = is_array(_sprite_asset) ? _sprite_asset[0].get_sprite() : _sprite_asset.get_sprite();

				draw_sprite_ext(_sprite, 0, _cx, _cy, 2 * _xs, 2 * _ys, 0, c_white, 1);
			}
			else
			{
				var _sa = global.attire_data.shirt[self.option_value];
				var _shirt_asset = _sa.get_sprite_colour();
				var _shirt_sprite = is_array(_shirt_asset) ? _shirt_asset[0].get_sprite() : _shirt_asset.get_sprite();

				draw_sprite_ext(_shirt_sprite, 0, _cx, _cy, 2 * _xs, 2 * _ys, 0, c_white, 1);
			}
		});

		_btn.add_event_handler("on_select_release", method(_btn, function() {
			global.current_player.attire[@ self.attire_index] = self.option_value;
		}));

		_parent.add_child(_btn);
	}
}


/// @desc Builds a row of color swatch buttons.
function menu_create_player_ui_build_colour_row(_parent, _attire_index, _max_options)
{
	if (_parent == undefined) exit;

	_parent.children = [];
	
	for (var i = 0; i < _max_options; ++i)
	{
		var _btn = new UIButton(0, 0, 62, 44, "");
		
		_btn.attire_index = _attire_index;
		_btn.option_value = i;
		_btn.on_draw = method(_btn, function(_x, _y, _xs, _ys) {
			var _selected = global.current_player.attire[self.attire_index] == self.option_value;
			var _palette = global.attire_colour_data[self.option_value];
			var _c = _palette[0];
			
			var _w = self.width * _xs;
			var _h = self.height * _ys;
			
			draw_rectangle_colour(_x + 4, _y + 4, _x + _w - 4, _y + _h - 4, _c, _c, _c, _c, false);
			
			if (_selected)
			{
				draw_rectangle_colour(_x + 1, _y + 1, _x + _w - 1, _y + _h - 1, c_white, c_white, c_white, c_white, true);
			}
		});
		
		_btn.add_event_handler("on_select_release", method(_btn, function() {
			global.current_player.attire[@ self.attire_index] = self.option_value;
		}));
		
		_parent.add_child(_btn);
	}

	_parent.layout_children();
}
