function menu_players_ui_load()
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
		var _full_path = "resources/data/ui/menu/players.ui";
		if (struct_exists(global.ui_definitions, _full_path))
		{
			struct_remove(global.ui_definitions, _full_path);
		}
	}
	
	var _def = ui_load("ui/menu/players.ui");
	
	if (_def == undefined)
	{
		show_debug_message("[Menu Players] failed to load ui/menu/players.ui");
		exit;
	}
	
	var _instance = ui_spawn(_def, {
		link: {},
		parent: global.gui_root
	});
	
	global.ui_players_menu = _instance;
	
	/* default view mode */
	if (!variable_global_exists("players_view_mode"))
	{
		global.players_view_mode = "grid";
	}
	
	menu_players_ui_init();
}

function menu_players_ui_init()
{
	var _instance = global.ui_players_menu;
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
	
	/* create player button */
	var _btn_create_player = _elements[$ "btn_create_player"];
	
	if (_btn_create_player != undefined)
	{
		_btn_create_player.text = loca_translate("phantasia:menu.players.create");
		
		_btn_create_player.add_event_handler("on_select_release", function() {
			menu_transition_goto(rm_Menu_Create_Player);
		});
	}
	
	/* grid/list view toggle */
	var _btn_view_toggle = _elements[$ "btn_view_toggle"];
	
	if (_btn_view_toggle != undefined)
	{
		_btn_view_toggle.text = (global.players_view_mode == "grid") ? "Grid" : "List";
		
		_btn_view_toggle.add_event_handler("on_select_release", function() {
			global.players_view_mode = (global.players_view_mode == "grid") ? "list" : "grid";

			menu_players_ui_populate();
		});
	}
	
	/* check players directory */
	var _a = file_read_directory(PROGRAM_DIRECTORY_PLAYERS);
    var _b = global.file_players_uuid;
    
    if (!array_equals(_a, _b))
    {
        file_load_players();
    }
	
	menu_players_ui_populate();
}

function menu_players_ui_populate()
{
	var _instance = global.ui_players_menu;
	var _elements = _instance.elements;
	var _container = _elements[$ "players_container"];
	
	if (_container == undefined) exit;
	
	/* update toggle button text */
	var _btn_view_toggle = _elements[$ "btn_view_toggle"];
	
	if (_btn_view_toggle != undefined)
	{
		_btn_view_toggle.text = (global.players_view_mode == "grid") ? "Grid" : "List";
	}
	
	/* clear previous */
	_container.children = [];
	
	var _players     = global.file_players;
	var _players_len = array_length(_players);
	var _is_grid     = (global.players_view_mode == "grid");
	
	/* separate pinned from normal, sort each by date last used */
	var _pinned = [];
	var _normal = [];
	
	for (var i = 0; i < _players_len; ++i)
	{
		var _p = _players[i];
		
		if (_p[$ "pinned"] == true)
		{
			array_push(_pinned, _p);
		}
		else
		{
			array_push(_normal, _p);
		}
	}
	
	var _ypos = 0;
	
	/* pinned section */
	if (array_length(_pinned) > 0)
	{
		var _label_pinned = new UIText(8, _ypos, "");
		_label_pinned.text = "Pinned";
		_label_pinned.text_halign = "fa_left";
		_label_pinned.text_scale = 0.8;
		_label_pinned.colour = c_ltgray;
		_label_pinned.parent = _container;

		array_push(_container.children, _label_pinned);

		_ypos += 20;
		_ypos = menu_players_ui_build_cards(_container, _pinned, _ypos, _is_grid, _instance);
		
		/* divider */
		var _divider = new UILine(0, _ypos + 4, 920, 1);
		_divider.colour = #3a3a4a;
		_divider.parent = _container;

		array_push(_container.children, _divider);

		_ypos += 12;
	}
	
	/* normal section */
	if (array_length(_normal) > 0)
	{
		var _label_normal = new UIText(8, _ypos, "");
		_label_normal.text = (array_length(_pinned) > 0) ? "Players" : "";
		_label_normal.text_halign = "fa_left";
		_label_normal.text_scale = 0.8;
		_label_normal.colour = c_ltgray;
		_label_normal.parent = _container;

		array_push(_container.children, _label_normal);

		_ypos += 20;
		_ypos = menu_players_ui_build_cards(_container, _normal, _ypos, _is_grid, _instance);
	}
	
	_container.height = max(100, _ypos + 16);
}


/// @desc Builds player cards into the container and returns the new y position.
function menu_players_ui_build_cards(_container, _players, _ystart, _is_grid, _instance)
{
	var _len = array_length(_players);
	var _ypos = _ystart;
	
	for (var i = 0; i < _len; ++i)
	{
		var _player = _players[i];
		
		var _card_w, _card_h, _xoffset, _yoffset;
		
		if (_is_grid)
		{
			_card_w  = 140;
			_card_h  = 120;
			_xoffset = floor(i % 6) * (_card_w + 8);
			_yoffset = _ystart + floor(i / 6) * (_card_h + 8);
		}
		else
		{
			_card_w  = 900;
			_card_h  = 56;
			_xoffset = 0;
			_yoffset = _ystart + i * (_card_h + 4);
		}
		
		var _entry = new UIButton(
			_xoffset,
			_yoffset,
			_card_w,
			_card_h,
			""
		);
		
		_entry.parent       = _container;
		_entry.link_context = _instance.link_context;
		_entry.player_ref   = _player;
		_entry.is_grid_mode = _is_grid;
		
		_entry.add_event_handler("on_draw", method(_entry, function(_x, _y, _xscale, _yscale) {
			var _data = self.player_ref;
			
			var _ew = self.width * _xscale;
			var _eh = self.height * _yscale;
			
			/* background */
			draw_set_alpha(0.5);
			draw_rectangle_colour(_x, _y, _x + _ew, _y + _eh, c_black, c_black, c_black, c_black, false);
			draw_set_alpha(1);
			draw_rectangle_colour(_x, _y, _x + _ew, _y + _eh, #3a3a4a, #3a3a4a, #3a3a4a, #3a3a4a, true);
			
			var _halign = draw_get_halign();
			var _valign = draw_get_valign();
			
			draw_set_align(fa_left, fa_top);
			
			if (self.is_grid_mode)
			{
				/* grid: avatar centered, name below, date below that */
				var _cx = _x + (_ew / 2);
				var _cy = _y + 8;
				
				render_attire_ext(_data.get_attire(), _cx, _cy + 40, 2, 2, 0, c_white, 1);
				
				draw_set_align(fa_center, fa_top);

				render_text(_cx, _y + _eh - 40, _data.get_name(), 0.9, 0.9);
				render_text(_cx, _y + _eh - 24, date_datetime_string(_data.get_last_opened()), 0.6, 0.6);
			}
			else
			{
				/* list: avatar left, name + date right */
				var _cx = _x + 24;
				var _cy = _y + (_eh / 2);
				
				render_attire_ext(_data.get_attire(), _cx, _cy + 8, 1.5, 1.5, 0, c_white, 1);
				
				render_text(_x + 56, _y + 8, _data.get_name());
				render_text(_x + 56, _y + 28, date_datetime_string(_data.get_last_opened()), 0.7, 0.7);
			}
			
			draw_set_align(_halign, _valign);
		}));
		
		/* pin icon */
		var _pin_w  = 24;
		var _pin_h  = 20;
		var _pin_x  = _card_w - _pin_w - 4;
		var _pin_y  = _card_h - _pin_h - 4;
		var _btn_pin = new UIButton(_pin_x, _pin_y, _pin_w, _pin_h, "");

		_btn_pin.player_ref = _player;
		_btn_pin.parent     = _entry;

		_btn_pin.add_event_handler("on_draw", method(_btn_pin, function(_x, _y, _xscale, _yscale) {
			var _halign = draw_get_halign();
			var _valign = draw_get_valign();

			draw_set_align(fa_center, fa_middle);

			var _cx = _x + (self.width * _xscale / 2);
			var _cy = _y + (self.height * _yscale / 2);

			render_text(_cx, _cy, "Pin", 0.6, 0.6);

			draw_set_align(_halign, _valign);
		}));

		_btn_pin.add_event_handler("on_select_release", method(_btn_pin, function() {
			var _p = self.player_ref;
			_p[$ "pinned"] = !(_p[$ "pinned"] == true);

			menu_players_ui_populate();
		}));
		
		/* gear icon */
		var _gear_x = _pin_x - _pin_w - 2;
		var _btn_gear = new UIButton(_gear_x, _pin_y, _pin_w, _pin_h, "");

		_btn_gear.player_ref = _player;
		_btn_gear.parent     = _entry;

		_btn_gear.add_event_handler("on_draw", method(_btn_gear, function(_x, _y, _xscale, _yscale) {
			var _halign = draw_get_halign();
			var _valign = draw_get_valign();

			draw_set_align(fa_center, fa_middle);

			var _cx = _x + (self.width * _xscale / 2);
			var _cy = _y + (self.height * _yscale / 2);

			render_text(_cx, _cy, "Opt", 0.6, 0.6);

			draw_set_align(_halign, _valign);
		}));

		_btn_gear.add_event_handler("on_select_release", method(_btn_gear, function() {
			show_debug_message("Player options: " + string(self.player_ref.get_name()));
		}));
		
		array_push(_entry.children, _btn_pin, _btn_gear);
		
		/* select player */
		_entry.add_event_handler("on_select_release", method(_entry, function() {
			var _data = self.player_ref;
			var _uuid = _data.get_uuid();
			
			if (!directory_exists(PROGRAM_DIRECTORY_PLAYERS + "\\" + _uuid))
			{
				show_debug_message("Player folder not found: " + string(_uuid));

				return;
			}
			
			global.current_player.name   = _data.get_name();
			global.current_player.uuid   = _uuid;
			global.current_player.attire = _data.get_attire();
			
			room_goto(rm_Menu_Worlds);
		}));
		
		array_push(_container.children, _entry);
	}
	
	/* calculate final y position */
	if (_is_grid)
	{
		var _rows = ceil(_len / 6);
		
		return _ystart + _rows * 128;
	}
	
	return _ystart + _len * 60;
}
