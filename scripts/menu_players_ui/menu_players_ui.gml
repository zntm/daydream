global.ui_players_menu = undefined;


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
	global.players_view_mode = global.menu_preferences.players_view_mode ?? "grid";
	
	menu_players_ui_init();
}


function menu_players_ui_init()
{
	var _instance = global.ui_players_menu;
	var _elements = _instance.elements;
	
	var _title = _elements[$ "title"];
	if (_title != undefined)
	{
		_title.text = menu_ui_localize_or_default("phantasia:menu.players.title", "Players");
	}
	
	var _label_pinned = _elements[$ "label_pinned"];
	if (_label_pinned != undefined) _label_pinned.text = "Pinned";
	
	var _label_all = _elements[$ "label_all"];
	if (_label_all != undefined) _label_all.text = "All Players";
	
	/* back button */
	var _btn_back = _elements[$ "btn_back"];
	if (_btn_back != undefined)
	{
		_btn_back.text = menu_ui_localize_or_default("phantasia:menu.generic.back", "Back");
		_btn_back.add_event_handler("on_select_release", function() {
			menu_transition_goto(rm_Menu_Title);
		});
	}
	
	/* create player button */
	var _btn_create_player = _elements[$ "btn_create_player"];
	if (_btn_create_player != undefined)
	{
		_btn_create_player.text = menu_ui_localize_or_default("phantasia:menu.players.create", "Create Player");
		_btn_create_player.add_event_handler("on_select_release", function() {
			menu_transition_goto(rm_Menu_Create_Player);
		});
	}
	
	/* grid/list view toggle */
	menu_players_ui_configure_view_button(_elements[$ "btn_view_grid"], "grid", "phantasia:ui/view_grid");
	menu_players_ui_configure_view_button(_elements[$ "btn_view_list"], "list", "phantasia:ui/view_list");
	menu_players_ui_refresh_view_buttons();
	
	/* show loading placeholder, then defer data load */
	menu_players_ui_set_loading_state();

	call_later(1, time_source_units_frames, function() {
		var _directory_listing = file_read_directory(PROGRAM_DIRECTORY_PLAYERS);
		var _known_listing = global.file_players_uuid;

		if (!array_equals(_directory_listing, _known_listing))
		{
			file_load_players();
		}

		menu_players_ui_populate();
	});
}


function menu_players_ui_configure_view_button(_button, _mode, _asset_key)
{
	if (_button == undefined) exit;
	
	_button.text = "";
	_button.view_mode = _mode;
	_button.icon_asset_key = _asset_key;
	_button.on_draw = method(_button, function(_x, _y, _xscale, _yscale) {
		var _alpha = global.menu_transition_alpha ?? 1;
		var _cx = _x + (self.width * _xscale * 0.5);
		var _cy = _y + (self.height * _yscale * 0.5);
		var _scale = ((self.boolean & MENU_BUTTON_BOOL.IS_HOVER) != 0) ? 2.15 : 2.0;
		
		menu_ui_draw_icon(self.icon_asset_key, _cx, _cy, _alpha, _scale);
	});
	
	_button.add_event_handler("on_select_release", method(_button, function() {
		if (global.players_view_mode == self.view_mode) exit;
		
		global.players_view_mode = self.view_mode;
		global.menu_preferences.players_view_mode = self.view_mode;
		
		file_save_menu_preferences();
		menu_players_ui_refresh_view_buttons();
		menu_players_ui_populate();
	}));
}


function menu_players_ui_refresh_view_buttons()
{
	var _instance = global.ui_players_menu;
	if (_instance == undefined) exit;

	var _btn_grid = ui_get(_instance, "btn_view_grid");
	if (_btn_grid != undefined)
	{
		_btn_grid.sprite_index = (global.players_view_mode == "grid") ? spr_Menu_Button_Secondary : spr_Menu_Button_Main;
	}

	var _btn_list = ui_get(_instance, "btn_view_list");
	if (_btn_list != undefined)
	{
		_btn_list.sprite_index = (global.players_view_mode == "list") ? spr_Menu_Button_Secondary : spr_Menu_Button_Main;
	}
}


function menu_players_ui_set_loading_state()
{
	var _instance = global.ui_players_menu;
	if (_instance == undefined) exit;

	var _pinned = ui_get(_instance, "pinned_container");
	if (_pinned != undefined)
	{
		_pinned.clear_children();
		
		var _hint = new UIText(0, 18, "Loading pinned profiles...");
		_hint.halign = fa_left;
		_hint.valign = fa_middle;
		_hint.text_scale = 0.7;
		_hint.colour = menu_ui_get_metrics().text_dim;
		_pinned.add_child(_hint);
	}

	var _container = ui_get(_instance, "players_container");
	if (_container != undefined)
	{
		_container.clear_children();
		
		var _loading = new UIText(0, 12, "Loading players...");
		_loading.halign = fa_left;
		_loading.valign = fa_top;
		_loading.text_scale = 0.8;
		_loading.colour = menu_ui_get_metrics().text_dim;
		_container.add_child(_loading);
	}
}


function menu_players_ui_populate()
{
	var _instance = global.ui_players_menu;
	if (_instance == undefined) exit;

	var _pinned_container = ui_get(_instance, "pinned_container");
	var _main_container = ui_get(_instance, "players_container");
	
	if (_pinned_container == undefined || _main_container == undefined) exit;
	
	_pinned_container.clear_children();
	_main_container.clear_children();
	
	var _players = global.file_players;
	var _players_len = array_length(_players);
	var _pinned = [];
	var _ordered = [];
	
	for (var i = 0; i < _players_len; ++i)
	{
		var _player = _players[i];
		if (_player[$ "pinned"] == true)
		{
			array_push(_pinned, _player);
		}
	}
	
	for (var i = 0; i < array_length(_pinned); ++i)
	{
		array_push(_ordered, _pinned[i]);
	}
	
	for (var i = 0; i < _players_len; ++i)
	{
		var _player = _players[i];
		if (_player[$ "pinned"] != true)
		{
			array_push(_ordered, _player);
		}
	}
	
	menu_players_ui_refresh_view_buttons();
	menu_players_ui_build_pinned_strip(_pinned_container, _pinned, _instance);
	menu_players_ui_build_cards(_main_container, _ordered, (global.players_view_mode == "grid"), _instance, ui_layout_resolve_scalar(_main_container.width, 0));
}


function menu_players_ui_build_pinned_strip(_container, _players, _instance)
{
	var _metrics = menu_ui_get_metrics();
	var _len = array_length(_players);
	
	if (_len <= 0)
	{
		var _empty = new UIText(0, 20, "Pin profiles here for quick access.");
		_empty.halign = fa_left;
		_empty.valign = fa_middle;
		_empty.text_scale = 0.7;
		_empty.colour = _metrics.text_dim;
		_container.add_child(_empty);
		_container.width = max(ui_layout_resolve_scalar(_container.width, 0), 240);
		_container.height = 60;
		
		exit;
	}
	
	var _card_w = 248;
	var _card_h = 64;
	var _gap = _metrics.card_gap;
	var _container_width = ui_layout_resolve_scalar(_container.width, 0);
	
	for (var i = 0; i < _len; ++i)
	{
		var _x = i * (_card_w + _gap);
		menu_players_ui_create_card(_container, _players[i], _x, 0, _card_w, _card_h, "pinned", _instance);
	}
	
	_container.width = max(_container_width, (_len * (_card_w + _gap)) - _gap);
	_container.height = _card_h;
}


function menu_players_ui_build_cards(_container, _players, _is_grid, _instance, _container_width)
{
	var _metrics = menu_ui_get_metrics();
	var _len = array_length(_players);
	
	if (_len <= 0)
	{
		var _empty = new UIText(0, 12, "No player profiles found.");
		_empty.halign = fa_left;
		_empty.valign = fa_top;
		_empty.text_scale = 0.8;
		_empty.colour = _metrics.text_dim;
		_container.add_child(_empty);
		_container.height = 48;
		
		exit;
	}
	
	var _gap = _metrics.card_gap;
	var _card_w = _is_grid ? 196 : _container_width;
	var _card_h = _is_grid ? 122 : 78;
	var _columns = max(1, floor((_container_width + _gap) / (_card_w + _gap)));
	var _total_width = (_columns * _card_w) + ((_columns - 1) * _gap);
	var _start_x = _is_grid ? floor(max(0, (_container_width - _total_width) * 0.5)) : 0;
	var _bottom = 0;
	
	for (var i = 0; i < _len; ++i)
	{
		var _x;
		var _y;
		
		if (_is_grid)
		{
			_x = _start_x + ((i mod _columns) * (_card_w + _gap));
			_y = floor(i / _columns) * (_card_h + _gap);
		}
		else
		{
			_x = 0;
			_y = i * (_card_h + 8);
		}
		
		menu_players_ui_create_card(_container, _players[i], _x, _y, _card_w, _card_h, (_is_grid ? "grid" : "list"), _instance);
		_bottom = max(_bottom, _y + _card_h);
	}
	
	_container.height = _bottom;
}


function menu_players_ui_create_card(_container, _player, _x, _y, _w, _h, _layout, _instance)
{
	var _entry = new UIButton(_x, _y, _w, _h, "");
	_container.add_child(_entry);
	_entry.link_context = _instance.link_context;
	_entry.player_ref = _player;
	_entry.card_layout = _layout;
	_entry.on_draw = method(_entry, function(_x1, _y1, _xscale, _yscale) {
		menu_players_ui_draw_card(self, _x1, _y1, _xscale, _yscale);
	});
	
	menu_players_ui_attach_card_actions(_entry, _player);
	
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
		global.current_player.hp     = _data.get_hp();
		global.current_player.hp_max = _data.get_hp_max();
		global.current_player.uuid   = _uuid;
		global.current_player.attire = _data.get_attire();
		
		global.player_statistics   = _data.get_statistics() ?? {}
		global.player_achievements = _data.get_achievements() ?? {}
		
		menu_refresh_value_world_save();
		menu_transition_goto(rm_Menu_Worlds);
	}));
	
	return _entry;
}


function menu_players_ui_attach_card_actions(_entry, _player)
{
	var _metrics = menu_ui_get_metrics();
	var _icon = _metrics.icon_button;
	
	var _btn_pin = menu_players_ui_create_icon_button(_entry, 4, 4, _icon, _icon, function() {
		var _p = self.player_ref;
		var _uuid = _p.get_uuid();
		
		_p[$ "pinned"] = file_toggle_pinned_player(_uuid);
		menu_players_ui_populate();
		global.ui_input_consumed = true;
	});
	_btn_pin.player_ref = _player;
	_btn_pin.icon_asset_key = (_player[$ "pinned"] == true) ? "phantasia:ui/pin_active" : "phantasia:ui/pin";
	_btn_pin.on_draw = method(_btn_pin, function(_x, _y, _xscale, _yscale) {
		var _alpha = global.menu_transition_alpha ?? 1;
		var _cx = _x + (self.width * _xscale * 0.5);
		var _cy = _y + (self.height * _yscale * 0.5);
		var _key = (self.player_ref[$ "pinned"] == true) ? "phantasia:ui/pin_active" : "phantasia:ui/pin";
		menu_ui_draw_icon(_key, _cx, _cy, _alpha, 2);
	});
	
	var _btn_stats = menu_players_ui_create_icon_button(_entry, _entry.width - _icon - 4, 4, _icon, _icon, function() {
		menu_popup_player_statistics(self.player_ref);
		global.ui_input_consumed = true;
	});
	_btn_stats.player_ref = _player;
	_btn_stats.on_draw = method(_btn_stats, function(_x, _y, _xscale, _yscale) {
		var _alpha = global.menu_transition_alpha ?? 1;
		var _cx = _x + (self.width * _xscale * 0.5);
		var _cy = _y + (self.height * _yscale * 0.5);
		menu_ui_draw_icon("phantasia:ui/statistics", _cx, _cy, _alpha, 2);
	});
	
	var _btn_option = menu_players_ui_create_icon_button(_entry, _entry.width - _icon - 4, _entry.height - _icon - 4, _icon, _icon, function() {
		PRINT("Player options: " + string(self.player_ref.get_name()));
		global.ui_input_consumed = true;
	});
	_btn_option.player_ref = _player;
	_btn_option.on_draw = method(_btn_option, function(_x, _y, _xscale, _yscale) {
		var _alpha = global.menu_transition_alpha ?? 1;
		var _cx = _x + (self.width * _xscale * 0.5);
		var _cy = _y + (self.height * _yscale * 0.5);
		menu_ui_draw_icon("phantasia:ui/option", _cx, _cy, _alpha, 2);
	});
	
	_entry.add_child(_btn_pin);
	_entry.add_child(_btn_stats);
	_entry.add_child(_btn_option);
}


function menu_players_ui_create_icon_button(_parent, _x, _y, _w, _h, _handler)
{
	var _button = new UIButton(_x, _y, _w, _h, "");
	_button.boolean = 0;
	_parent.add_child(_button);
	_button.add_event_handler("on_select_release", method(_button, _handler));
	
	return _button;
}


function menu_players_ui_draw_card(_self, _x, _y, _xscale, _yscale)
{
	var _metrics = menu_ui_get_metrics();
	var _data = _self.player_ref;
	var _layout = _self.card_layout;
	var _w = _self.width * _xscale;
	var _h = _self.height * _yscale;
	var _hovered = ((_self.boolean & MENU_BUTTON_BOOL.IS_HOVER) != 0);
	var _alpha = global.menu_transition_alpha ?? 1;
	var _hp = _data.get_hp();
	var _hp_max = max(1, _data.get_hp_max());
	var _hp_ratio = clamp(_hp / _hp_max, 0, 1);
	var _halign = draw_get_halign();
	var _valign = draw_get_valign();
	
	draw_set_alpha(_alpha);
	menu_ui_draw_panel(_x, _y, _w, _h, _hovered, false);
	draw_set_alpha(1);
	
	draw_set_align(fa_left, fa_top);
	
	switch (_layout)
	{
		case "pinned":
			draw_set_alpha(_alpha * 0.18);
			draw_rectangle_colour(_x + 12, _y + 10, _x + 62, _y + _h - 10, _metrics.placeholder_fill, _metrics.placeholder_fill, _metrics.placeholder_fill, _metrics.placeholder_fill, false);
			draw_set_alpha(1);
			render_attire(_data.get_attire(), 0, _x + 37, _y + (_h * 0.5) + 10, 2, 2);
			render_text(_x + 74, _y + 10, menu_ui_trim_text(_data.get_name(), 18), 0.8, 0.8, 0, c_white, _alpha);
			render_text(_x + 74, _y + 26, $"{_hp}/{_hp_max} HP", 0.6, 0.6, 0, _metrics.text_muted, _alpha);
			menu_players_ui_draw_hp_bar(_x + 74, _y + 42, _w - 108, 8, _hp_ratio, _alpha);
			render_text(_x + 74, _y + 54, date_datetime_string(_data.get_last_opened()), 0.55, 0.55, 0, _metrics.text_dim, _alpha);
			break;
		
		case "list":
			draw_set_alpha(_alpha * 0.18);
			draw_rectangle_colour(_x + 12, _y + 11, _x + 64, _y + _h - 11, _metrics.placeholder_fill, _metrics.placeholder_fill, _metrics.placeholder_fill, _metrics.placeholder_fill, false);
			draw_set_alpha(1);
			render_attire(_data.get_attire(), 0, _x + 38, _y + (_h * 0.5) + 12, 2.1, 2.1);
			render_text(_x + 80, _y + 12, menu_ui_trim_text(_data.get_name(), 28), 0.9, 0.9, 0, c_white, _alpha);
			render_text(_x + 80, _y + 30, $"{_hp}/{_hp_max} HP", 0.65, 0.65, 0, _metrics.text_muted, _alpha);
			menu_players_ui_draw_hp_bar(_x + 80, _y + 46, min(220, _w - 156), 8, _hp_ratio, _alpha);
			render_text(_x + 80, _y + 58, date_datetime_string(_data.get_last_opened()), 0.6, 0.6, 0, _metrics.text_dim, _alpha);
			break;
		
		default:
			draw_set_alpha(_alpha * 0.18);
			draw_rectangle_colour(_x + 14, _y + 16, _x + 74, _y + _h - 14, _metrics.placeholder_fill, _metrics.placeholder_fill, _metrics.placeholder_fill, _metrics.placeholder_fill, false);
			draw_set_alpha(1);
			render_attire(_data.get_attire(), 0, _x + 44, _y + (_h * 0.5) + 8, 2.4, 2.4);
			render_text(_x + 88, _y + 14, menu_ui_trim_text(_data.get_name(), 18), 0.85, 0.85, 0, c_white, _alpha);
			render_text(_x + 88, _y + 36, $"{_hp}/{_hp_max} HP", 0.65, 0.65, 0, _metrics.text_muted, _alpha);
			menu_players_ui_draw_hp_bar(_x + 88, _y + 54, _w - 118, 8, _hp_ratio, _alpha);
			render_text(_x + 88, _y + 70, date_datetime_string(_data.get_last_opened()), 0.58, 0.58, 0, _metrics.text_dim, _alpha);
			break;
	}
	
	draw_set_align(_halign, _valign);
}


function menu_players_ui_draw_hp_bar(_x, _y, _w, _h, _ratio, _alpha)
{
	var _fill = clamp(_ratio, 0, 1);
	
	draw_set_alpha(_alpha * 0.18);
	draw_rectangle_colour(_x, _y, _x + _w, _y + _h, c_black, c_black, c_black, c_black, false);
	
	draw_set_alpha(_alpha * 0.82);
	draw_rectangle_colour(_x + 1, _y + 1, _x + 1 + max(0, (_w - 2) * _fill), _y + _h - 1, c_white, c_white, c_white, c_white, false);
	
	draw_set_alpha(_alpha);
	draw_rectangle_colour(_x, _y, _x + _w, _y + _h, menu_ui_get_metrics().card_border, menu_ui_get_metrics().card_border, menu_ui_get_metrics().card_border, menu_ui_get_metrics().card_border, true);
	draw_set_alpha(1);
}
