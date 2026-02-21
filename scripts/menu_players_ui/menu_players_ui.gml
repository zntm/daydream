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
	
	menu_players_ui_init();
}

function menu_players_ui_init()
{
	var _instance = global.ui_players_menu;
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
	
	var _btn_create_player = _elements[$ "btn_create_player"];
	
	if (_btn_create_player != undefined)
	{
		_btn_create_player.text = loca_translate("phantasia:menu.players.create");
		
		_btn_create_player.add_event_handler("on_select_release", function() {
			menu_transition_goto(rm_Menu_Create_Player);
		});
	}
	
	var _btn_open_folder = _elements[$ "btn_open_folder"];
	
	if (_btn_open_folder != undefined)
	{
		_btn_open_folder.text = loca_translate("phantasia:menu.players.folder");
		
		_btn_open_folder.add_event_handler("on_select_release", function() {
			execute_shell_simple(PROGRAM_DIRECTORY_PLAYERS);
		});
	}
	
	/* check players directory */
	var _a = file_read_directory(PROGRAM_DIRECTORY_PLAYERS);
    var _b = global.file_players_uuid;
    
    if (!array_equals(_a, _b))
    {
        file_load_players();
    }
	
	var _players = global.file_players;
    var _players_length = array_length(_players);
	
	/* container for the player list */
	var _container = _elements[$ "players_container"];
	
	if (_container != undefined)
	{
		/* clear previous if any */
		_container.children = [];
		
		for (var i = 0; i < _players_length; ++i)
	    {
	        var _player = _players[i];
	        
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
			_entry.player_index = i;
			
			_entry.add_event_handler("on_draw", method(_entry, function(_x, _y, _xscale, _yscale) {
				var _data = global.file_players[self.player_index];
				
				/* player entry visual size based on UI size */
				var _ew = self.width * _xscale;
				var _eh = self.height * _yscale;
				
				/* Draw entry background and border */
				draw_set_alpha(0.5);
				draw_rectangle_colour(_x, _y, _x + _ew, _y + _eh, c_black, c_black, c_black, c_black, false);
				draw_set_alpha(1);
				draw_rectangle_colour(_x, _y, _x + _ew, _y + _eh, #3a3a4a, #3a3a4a, #3a3a4a, #3a3a4a, true);
				
				var _halign = draw_get_halign();
		        var _valign = draw_get_valign();
		        
		        draw_set_align(fa_left, fa_top);
		        
				/* render the player details */
		        render_text(_x + 72, _y + 16, _data.get_name());
				
				// Currently missing Date last used but we'll add placeholder text
				render_text(_x + 72, _y + 56, "date last used", 0.8, 0.8);
				
				var _cx = _x + 36;
				var _cy = _y + _eh - 16;
				
				render_attire_ext(_data.get_attire(), _cx, _cy, 2, 2, 0, c_white, 1);
		        
		        draw_set_align(_halign, _valign);
			}));
			
			/* Adding Pin / Options sub-buttons over the entry */
			var _btn_pin = new UIButton(192 - 40, 4, 32, 24, "");
			_btn_pin.on_select_release = function() { show_debug_message("Pin clicked"); };
			_btn_pin.parent = _entry; // add to entry to be drawn together
			
			var _btn_opt = new UIButton(192 - 40, 32, 32, 24, "");
			_btn_opt.on_select_release = function() { show_debug_message("Options clicked"); };
			_btn_opt.parent = _entry;
			
			array_push(_entry.children, _btn_pin, _btn_opt);
			
			_entry.add_event_handler("on_select_release", method(_entry, function() {
				var _data = global.file_players[self.player_index];
		        var _uuid = _data.get_uuid();
		        
		        if (!directory_exists(PROGRAM_DIRECTORY_PLAYERS + "\\" + _uuid))
		        {
					show_debug_message("Player folder not found: " + string(_uuid));
					return;
				}
				
				global.current_player.name = _data.get_name();
				global.current_player.uuid = _uuid;
				
				/* set current player attire */
				global.current_player.attire = _data.get_attire();
				
		        room_goto(rm_Menu_Worlds);
			}));
			
			array_push(_container.children, _entry);
		}
		
		/* adjust container height for scrolling based on number of rows */
		var _rows = ceil(_players_length / 4);
		_container.height = max(100, _rows * 160); 
		

	}
}
