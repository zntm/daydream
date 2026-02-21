function menu_worlds_ui_load()
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
		var _full_path = "resources/data/ui/menu/worlds.ui";
		if (struct_exists(global.ui_definitions, _full_path))
		{
			struct_remove(global.ui_definitions, _full_path);
		}
	}
	
	var _def = ui_load("ui/menu/worlds.ui");
	
	if (_def == undefined)
	{
		show_debug_message("[Menu Worlds] failed to load ui/menu/worlds.ui");
		exit;
	}
	
	var _instance = ui_spawn(_def, {
		link: {},
		parent: global.gui_root
	});
	
	global.ui_worlds_menu = _instance;
	
	/* default view mode */
	if (!variable_global_exists("worlds_view_mode"))
	{
		global.worlds_view_mode = "grid";
	}
	
	menu_worlds_ui_init();
}

function menu_worlds_ui_init()
{
	var _instance = global.ui_worlds_menu;
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
	
	/* create world button */
	var _btn_create_world = _elements[$ "btn_create_world"];
	
	if (_btn_create_world != undefined)
	{
		_btn_create_world.text = loca_translate("phantasia:menu.worlds.create");
		
		_btn_create_world.add_event_handler("on_select_release", function() {
			menu_transition_goto(rm_Menu_Create_World);
		});
	}
	
	/* grid/list view toggle */
	var _btn_view_toggle = _elements[$ "btn_view_toggle"];
	
	if (_btn_view_toggle != undefined)
	{
		_btn_view_toggle.text = (global.worlds_view_mode == "grid") ? "Grid" : "List";
		
		_btn_view_toggle.add_event_handler("on_select_release", function() {
			global.worlds_view_mode = (global.worlds_view_mode == "grid") ? "list" : "grid";

			menu_worlds_ui_populate();
		});
	}
	
	/* check worlds directory */
	var _a = file_read_directory(PROGRAM_DIRECTORY_WORLDS);
    var _b = global.file_worlds_uuid;
    
    if (!array_equals(_a, _b))
    {
        file_load_worlds();
    }
	
	menu_worlds_ui_populate();
}

function menu_worlds_ui_populate()
{
	var _instance = global.ui_worlds_menu;
	var _elements = _instance.elements;
	var _container = _elements[$ "worlds_container"];
	
	if (_container == undefined) exit;
	
	/* update toggle button text */
	var _btn_view_toggle = _elements[$ "btn_view_toggle"];
	
	if (_btn_view_toggle != undefined)
	{
		_btn_view_toggle.text = (global.worlds_view_mode == "grid") ? "Grid" : "List";
	}
	
	/* clear previous */
	_container.children = [];
	
	var _worlds     = global.file_worlds;
	var _worlds_len = array_length(_worlds);
	var _is_grid    = (global.worlds_view_mode == "grid");
	
	/* separate pinned from normal */
	var _pinned = [];
	var _normal = [];
	
	for (var i = 0; i < _worlds_len; ++i)
	{
		var _w = _worlds[i];
		
		if (_w[$ "pinned"] == true)
		{
			array_push(_pinned, _w);
		}
		else
		{
			array_push(_normal, _w);
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
		_ypos = menu_worlds_ui_build_cards(_container, _pinned, _ypos, _is_grid, _instance);
		
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
		_label_normal.text = (array_length(_pinned) > 0) ? "Worlds" : "";
		_label_normal.text_halign = "fa_left";
		_label_normal.text_scale = 0.8;
		_label_normal.colour = c_ltgray;
		_label_normal.parent = _container;

		array_push(_container.children, _label_normal);

		_ypos += 20;
		_ypos = menu_worlds_ui_build_cards(_container, _normal, _ypos, _is_grid, _instance);
	}
	
	_container.height = max(100, _ypos + 16);
}


/// @desc Builds world cards into the container and returns the new y position.
function menu_worlds_ui_build_cards(_container, _worlds, _ystart, _is_grid, _instance)
{
	var _len = array_length(_worlds);
	var _ypos = _ystart;
	
	for (var i = 0; i < _len; ++i)
	{
		var _world = _worlds[i];
		
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
		_entry.world_ref    = _world;
		_entry.is_grid_mode = _is_grid;
		
		_entry.add_event_handler("on_draw", method(_entry, function(_x, _y, _xscale, _yscale) {
			var _data = self.world_ref;
			
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
				/* grid: thumbnail at top, name + date below */
				var _thumb_w = _ew - 16;
				var _thumb_h = 48;

				draw_rectangle_colour(_x + 8, _y + 8, _x + 8 + _thumb_w, _y + 8 + _thumb_h, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
				
				draw_set_align(fa_center, fa_top);

				var _cx = _x + (_ew / 2);

				render_text(_cx, _y + _thumb_h + 16, _data.get_name(), 0.9, 0.9);
				render_text(_cx, _y + _eh - 20, date_datetime_string(_data.get_last_opened()), 0.6, 0.6);
			}
			else
			{
				/* list: thumbnail left, name + date right */
				draw_rectangle_colour(_x + 8, _y + 8, _x + 48, _y + _eh - 8, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);
				
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

		_btn_pin.world_ref = _world;
		_btn_pin.parent    = _entry;

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
			var _w = self.world_ref;
			_w[$ "pinned"] = !(_w[$ "pinned"] == true);

			menu_worlds_ui_populate();
		}));
		
		/* gear icon */
		var _gear_x = _pin_x - _pin_w - 2;
		var _btn_gear = new UIButton(_gear_x, _pin_y, _pin_w, _pin_h, "");

		_btn_gear.world_ref = _world;
		_btn_gear.parent    = _entry;

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
			show_debug_message("World options: " + string(self.world_ref.get_name()));
		}));
		
		array_push(_entry.children, _btn_pin, _btn_gear);
		
		/* select world */
		_entry.add_event_handler("on_select_release", method(_entry, function() {
			var _data = self.world_ref;
			var _uuid = _data.get_uuid();
			
			if (!directory_exists(PROGRAM_DIRECTORY_WORLDS + "\\" + _uuid))
			{
				show_debug_message("World folder not found: " + string(_uuid));

				return;
			}
			
			global.current_world.name = _data.get_name();
			global.current_world.seed = _data.get_seed();
			
			global.current_world.dimension = _data.get_dimension();
			
			global.current_world.time = _data.get_time();
			global.current_world.day  = _data.get_day();
			
			global.current_world.weather.wind  = _data.get_weather_wind();
			global.current_world.weather.storm = _data.get_weather_storm();
			
			global.current_world.uuid = _uuid;
			
			global.current_world.difficulty = _data.get_difficulty();
			
			global.world_statistics = _data.get_statistics() ?? {};
			
			room_goto(rm_World);
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
