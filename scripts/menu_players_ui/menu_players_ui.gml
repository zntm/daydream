function menu_players_ui_load()
{
	menu_ui_clear_all();
	
	/* clean up legacy */
	instance_destroy(obj_Menu_Button);
	instance_destroy(obj_Menu_Anchor);
	
	/* ensure gui_root exists */
	if (!variable_global_exists("gui_root")) || (global.gui_root == undefined)
	{
		global.gui_root = ui_create_root();
		global.gui_root.element_name = "gui_root";
	}
	
	/* cache reload */
	ui_invalidate_definition("ui/menu/players.ui");
	
	var _def = ui_load("ui/menu/players.ui");
	
	if (_def == undefined)
	{
		PRINT("[Menu Players] failed to load ui/menu/players.ui");
		exit;
	}
	
	var _instance = ui_spawn(_def, {
		link: {},
		parent: global.gui_root
	});
	
	global.ui_players_menu = _instance;
	
	/* restore view mode from preferences */
	global.players_view_mode = global.menu_preferences.players_view_mode;
	
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
		_btn_view_toggle.text = "";
		
		_btn_view_toggle.on_draw = method(_btn_view_toggle, function(_x, _y, _xscale, _yscale) {
			var _alpha  = global.menu_transition_alpha ?? 1;
			var _spr_id = (global.players_view_mode == "grid")
				? "phantasia:ui/view_grid"
				: "phantasia:ui/view_list";
			var _asset = global.sprite_asset[$ _spr_id];

			if (_asset != undefined)
			{
				var _cx = _x + (self.width * _xscale / 2);
				var _cy = _y + (self.height * _yscale / 2);

				draw_sprite_ext(_asset.get_sprite(), 0, _cx, _cy, 2, 2, 0, c_white, _alpha);
			}
		});
		
		_btn_view_toggle.add_event_handler("on_select_release", function() {
			global.players_view_mode = (global.players_view_mode == "grid") ? "list" : "grid";

			global.menu_preferences.players_view_mode = global.players_view_mode;

			file_save_menu_preferences();
			menu_players_ui_populate();
		});
	}
	
	/* show loading placeholder, then defer data load */
	var _container = _elements[$ "players_container"];

	if (_container != undefined)
	{
		_container.children = [];

		var _loading = new UIText(8, 8, "");
		_loading.text       = "Loading...";
		_loading.halign     = fa_left;
		_loading.valign     = fa_top;
		_loading.text_scale = 0.8;
		_loading.colour     = c_ltgray;
		_loading.parent     = _container;

		array_push(_container.children, _loading);
	}

	call_later(1, time_source_units_frames, function() {
		var _a = file_read_directory(PROGRAM_DIRECTORY_PLAYERS);
		var _b = global.file_players_uuid;

		if (!array_equals(_a, _b))
		{
			file_load_players();
		}

		menu_players_ui_populate();
	});
}

function menu_players_ui_populate()
{
	var _instance = global.ui_players_menu;
	var _elements = _instance.elements;
	var _container = _elements[$ "players_container"];
	
	if (_container == undefined) exit;
	
	/* clear previous */
	_container.children = [];
	
	var _players     = global.file_players;
	var _players_len = array_length(_players);
	var _is_grid     = (global.players_view_mode == "grid");
	
	/* separate pinned from normal */
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
		_label_pinned.text       = "Pinned";
		_label_pinned.halign     = fa_left;
		_label_pinned.valign     = fa_top;
		_label_pinned.text_scale = 0.8;
		_label_pinned.colour     = c_ltgray;
		_label_pinned.parent     = _container;

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
		_label_normal.text       = (array_length(_pinned) > 0) ? "Players" : "";
		_label_normal.halign     = fa_left;
		_label_normal.valign     = fa_top;
		_label_normal.text_scale = 0.8;
		_label_normal.colour     = c_ltgray;
		_label_normal.parent     = _container;

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
		
		_entry.on_draw = method(_entry, function(_x, _y, _xscale, _yscale) {
			var _data = self.player_ref;
			
			var _ew = self.width * _xscale;
			var _eh = self.height * _yscale;
			var _alpha = global.menu_transition_alpha ?? 1;
			
			/* background */
			draw_set_alpha(0.5 * _alpha);
			draw_rectangle_colour(_x, _y, _x + _ew, _y + _eh, c_black, c_black, c_black, c_black, false);
			draw_set_alpha(_alpha);
			draw_rectangle_colour(_x, _y, _x + _ew, _y + _eh, #3a3a4a, #3a3a4a, #3a3a4a, #3a3a4a, true);
			draw_set_alpha(1);
			
			var _halign = draw_get_halign();
			var _valign = draw_get_valign();
			
			draw_set_align(fa_left, fa_top);
			
			if (self.is_grid_mode)
			{
				/* grid: avatar centered, name below, date below that */
				var _cx = _x + (_ew / 2);
				var _cy = _y + 8;
				
				draw_set_alpha(_alpha);
				render_attire(_data.get_attire(), 0, _cx, _cy + 40, 2, 2);
				draw_set_alpha(1);
				
				draw_set_align(fa_center, fa_top);

				render_text(_cx, _y + _eh - 40, _data.get_name(), 0.9, 0.9, 0, c_white, _alpha);
				render_text(_cx, _y + _eh - 24, date_datetime_string(_data.get_last_opened()), 0.6, 0.6, 0, c_white, _alpha);
				render_text(_cx, _y + _eh - 14, file_format_size(_data.get_size()), 0.55, 0.55, 0, c_ltgray, _alpha);
			}
			else
			{
				/* list: avatar left, name + date right */
				var _cx = _x + 24;
				var _cy = _y + (_eh / 2);
				
				draw_set_alpha(_alpha);
				render_attire(_data.get_attire(), 0, _cx, _cy + 8, 1.5, 1.5);
				draw_set_alpha(1);
				
				render_text(_x + 56, _y + 8, _data.get_name(), 1, 1, 0, c_white, _alpha);
				render_text(_x + 56, _y + 28, date_datetime_string(_data.get_last_opened()), 0.7, 0.7, 0, c_white, _alpha);
				
				draw_set_align(fa_right, fa_top);
				
				render_text(_x + _ew - 52, _y + 20, file_format_size(_data.get_size()), 0.65, 0.65, 0, c_ltgray, _alpha);
			}
			
			draw_set_align(_halign, _valign);
		});
		
		/* icon button dimensions */
		var _icon_w = 20;
		var _icon_h = 20;
		
		/* option icon (rightmost) */
		var _option_x  = _card_w - _icon_w - 4;
		var _option_y  = _card_h - _icon_h - 4;
		var _btn_option = new UIButton(_option_x, _option_y, _icon_w, _icon_h, "");

		_btn_option.boolean    = 0;
		_btn_option.player_ref = _player;
		_btn_option.parent     = _entry;

		_btn_option.on_draw = method(_btn_option, function(_x, _y, _xscale, _yscale) {
			var _alpha = global.menu_transition_alpha ?? 1;
			var _asset = global.sprite_asset[$ "phantasia:ui/option"];

			if (_asset != undefined)
			{
				var _cx = _x + (self.width * _xscale / 2);
				var _cy = _y + (self.height * _yscale / 2);

				draw_sprite_ext(_asset.get_sprite(), 0, _cx, _cy, 2, 2, 0, c_white, _alpha);
			}
		});

		_btn_option.add_event_handler("on_select_release", method(_btn_option, function() {
			PRINT("Player options: " + string(self.player_ref.get_name()));
			global.ui_input_consumed = true;
		}));
		
		/* pin icon (left of option) */
		var _pin_x   = _option_x - _icon_w - 2;
		var _btn_pin = new UIButton(_pin_x, _option_y, _icon_w, _icon_h, "");

		_btn_pin.boolean    = 0;
		_btn_pin.player_ref = _player;
		_btn_pin.parent     = _entry;

		_btn_pin.on_draw = method(_btn_pin, function(_x, _y, _xscale, _yscale) {
			var _alpha = global.menu_transition_alpha ?? 1;
			var _is_pinned = (self.player_ref[$ "pinned"] == true);
			var _spr_key   = _is_pinned ? "phantasia:ui/pin_active" : "phantasia:ui/pin";
			var _asset     = global.sprite_asset[$ _spr_key];

			if (_asset != undefined)
			{
				var _cx = _x + (self.width * _xscale / 2);
				var _cy = _y + (self.height * _yscale / 2);

				draw_sprite_ext(_asset.get_sprite(), 0, _cx, _cy, 2, 2, 0, c_white, _alpha);
			}
		});

		_btn_pin.add_event_handler("on_select_release", method(_btn_pin, function() {
			var _p    = self.player_ref;
			var _uuid = _p.get_uuid();

			_p[$ "pinned"] = file_toggle_pinned_player(_uuid);

			menu_players_ui_populate();
			
			global.ui_input_consumed = true;
		}));
		
		/* statistics icon (left of pin) */
		var _stats_x    = _pin_x - _icon_w - 2;
		var _btn_stats = new UIButton(_stats_x, _option_y, _icon_w, _icon_h, "");

		_btn_stats.boolean    = 0;
		_btn_stats.player_ref = _player;
		_btn_stats.parent     = _entry;

		_btn_stats.on_draw = method(_btn_stats, function(_x, _y, _xscale, _yscale) {
			var _alpha = global.menu_transition_alpha ?? 1;
			var _asset = global.sprite_asset[$ "phantasia:ui/statistics"];

			if (_asset != undefined)
			{
				var _cx = _x + (self.width * _xscale / 2);
				var _cy = _y + (self.height * _yscale / 2);

				draw_sprite_ext(_asset.get_sprite(), 0, _cx, _cy, 2, 2, 0, c_white, _alpha);
			}
		});

		_btn_stats.add_event_handler("on_select_release", method(_btn_stats, function() {
			menu_popup_player_statistics(self.player_ref);
			global.ui_input_consumed = true;
		}));
		
		array_push(_entry.children, _btn_stats, _btn_pin, _btn_option);
		
		/* select player */
		_entry.add_event_handler("on_select_release", method(_entry, function() {
			if (global.ui_input_consumed) exit;
			
			var _data = self.player_ref;
			var _uuid = _data.get_uuid();
			
			if (!directory_exists(PROGRAM_DIRECTORY_PLAYERS + "/" + _uuid))
			{
				PRINT("Player folder not found: " + string(_uuid));

				exit;
			}
			
			global.current_player.name   = _data.get_name();
			global.current_player.uuid   = _uuid;
			global.current_player.attire = _data.get_attire();
			
			menu_transition_goto(rm_Menu_Worlds);
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
