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
	
	menu_worlds_ui_init();
}

function menu_worlds_ui_init()
{
	var _instance = global.ui_worlds_menu;
	var _elements = _instance.elements;
	
	/* buttons */
	var _btn_back = _elements[$ "btn_back"];
	
	if (_btn_back != undefined)
	{
		_btn_back.text = loca_translate("phantasia:menu.generic.back");
		
		_btn_back.add_event_handler("on_select_release", function() {
			menu_transition_goto(rm_Menu_Title);
		});
	}
	
	var _btn_create_world = _elements[$ "btn_create_world"];
	
	if (_btn_create_world != undefined)
	{
		_btn_create_world.text = loca_translate("phantasia:menu.worlds.create");
		
		_btn_create_world.add_event_handler("on_select_release", function() {
			menu_transition_goto(rm_Menu_Create_World);
		});
	}
	
	var _btn_open_folder = _elements[$ "btn_open_folder"];
	
	if (_btn_open_folder != undefined)
	{
		_btn_open_folder.text = loca_translate("phantasia:menu.worlds.folder");
		
		_btn_open_folder.add_event_handler("on_select_release", function() {
			execute_shell_simple(PROGRAM_DIRECTORY_WORLDS);
		});
	}
	
	/* check worlds directory */
	var _a = file_read_directory(PROGRAM_DIRECTORY_WORLDS);
    var _b = global.file_worlds_uuid;
    
    if (!array_equals(_a, _b))
    {
        file_load_worlds();
    }
	
	var _worlds = global.file_worlds;
    var _worlds_length = array_length(_worlds);
	
	/* container for the world list */
	var _container = _elements[$ "worlds_container"];
	
	if (_container != undefined)
	{
		/* clear previous if any */
		_container.children = [];
		
		for (var i = 0; i < _worlds_length; ++i)
	    {
	        var _world = _worlds[i];
	        
	        var _xoffset = floor(i % 4) * 208;
	        var _yoffset = floor(i / 4) * 160;
			
			/* we create elements programmatically for the list items */
			var _entry = new UIButton(
				_xoffset,
				_yoffset,
				192,
				144,
				""
			);
			
			_entry.parent = _container;
			_entry.link_context = _instance.link_context;
			_entry.world_index = i;
			
			_entry.add_event_handler("on_draw", method(_entry, function(_x, _y, _xscale, _yscale) {
				var _data = global.file_worlds[self.world_index];
				
				var _halign = draw_get_halign();
		        var _valign = draw_get_valign();
		        
		        draw_set_align(fa_left, fa_top);
		        
				/* button sprite draws itself since it inherits, so we just add the text */
				/* UI is anchored differently from legacy, so _x, _y are top-left of the button bounds usually depending on anchor */
				/* but let's emulate the legacy look */
		        render_text(_x + 16, _y + 16, _data.get_name());
		        render_text(_x + 16, _y + 48, date_datetime_string(_data.get_last_opened()));
				
		        draw_set_align(_halign, _valign);
			}));
			
			_entry.add_event_handler("on_select_release", method(_entry, function() {
				var _data = global.file_worlds[self.world_index];
		        var _uuid = _data.get_uuid();
		        
		        if (!directory_exists(PROGRAM_DIRECTORY_WORLDS + "\\" + _uuid))
		        {
					/* TODO: popup error using new UI. For now just returning to title or logging */
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
		
		/* adjust container height for scrolling based on number of rows */
		var _rows = ceil(_worlds_length / 4);
		_container.height = max(100, _rows * 160); 
		

	}
}
