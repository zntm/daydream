function menu_multiplayer_ui_load()
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
	if (variable_global_exists("ui_definitions"))
	{
		var _full_path = "resources/data/ui/menu/multiplayer.ui";
		if (struct_exists(global.ui_definitions, _full_path))
		{
			struct_remove(global.ui_definitions, _full_path);
		}
	}
	
	var _def = ui_load("ui/menu/multiplayer.ui");
	
	if (_def == undefined)
	{
		PRINT("[Menu Multiplayer] failed to load ui/menu/multiplayer.ui");
		exit;
	}
	
	var _instance = ui_spawn(_def, {
		link: {},
		parent: global.gui_root
	});
	
	global.ui_multiplayer_menu = _instance;
	
	menu_multiplayer_ui_init();
}

function menu_multiplayer_ui_init()
{
	var _instance = global.ui_multiplayer_menu;
	var _elements = _instance.elements;
	
	var _btn_back = _elements[$ "btn_back"];
	
	if (_btn_back != undefined)
	{
		_btn_back.add_event_handler("on_select_release", function() {
			menu_transition_goto(rm_Menu_Title);
		});
	}
	
	var _btn_connect = _elements[$ "btn_connect"];
	var _input_invite_code = _elements[$ "input_invite_code"];
	
	if (_btn_connect != undefined && _input_invite_code != undefined)
	{
		_btn_connect.add_event_handler("on_select_release", method(_input_invite_code, function() {
			var _code = self.text;
			
			_code = string_replace_all(_code, "-", "");
	        _code = string_replace_all(_code, " ", "");
	        
	        if (string_length(_code) > 0)
	        {
	            PRINT($"[MENU] Joining session with code: {_code}");
	            
	            if (global.relay_manager.join_session(_code))
	            {
	                PRINT("[MENU] Connection initiated...");
	            }
	            else
	            {
	                PRINT("[MENU] Failed to join session - invalid code?");
	            }
	        }
	        else
	        {
	            PRINT("[MENU] Please enter an invite code");
	        }
		}));
	}
}
