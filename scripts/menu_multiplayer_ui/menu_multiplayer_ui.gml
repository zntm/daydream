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
	ui_invalidate_definition("ui/menu/multiplayer.ui");
	
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

function menu_multiplayer_ui_set_status(_text)
{
	if (global.ui_multiplayer_menu == undefined) exit;
	
	var _label = global.ui_multiplayer_menu.elements[$ "label_status"];
	if (_label != undefined) _label.text = _text;
}

function menu_multiplayer_ui_refresh_room_code()
{
	if (global.ui_multiplayer_menu == undefined) exit;
	
	var _label = global.ui_multiplayer_menu.elements[$ "label_room_code"];
	if (_label == undefined) exit;
	
	if (global.relay_manager != undefined && global.relay_manager.is_in_session())
	{
		var _code = global.relay_manager.get_room_code_formatted();
		var _suffix = "";
		
		if (global.relay != undefined)
		{
			var _assist = global.relay.network_assist;
			
			if (_assist != undefined && _assist.status == "pending")
			{
				_suffix = " (resolving route...)";
			}
			else if (_assist != undefined && _assist.forwarded)
			{
				_suffix = " (UPnP opened)";
			}
		}
		
		_label.text = $"Invite Code: {_code}{_suffix}";
	}
	else
	{
		_label.text = "Invite Code: not hosting";
	}
}

function menu_multiplayer_ui_refresh_host_toggles()
{
	if (global.ui_multiplayer_menu == undefined) exit;
	
	var _elements = global.ui_multiplayer_menu.elements;
	
	var _btn_auto_forward = _elements[$ "btn_toggle_auto_forward"];
	var _btn_public_ip = _elements[$ "btn_toggle_public_ip"];
	var _btn_build = _elements[$ "btn_toggle_build"];
	var _btn_containers = _elements[$ "btn_toggle_containers"];
	var _permission = _elements[$ "drop_guest_permission"];
	
	if (_btn_auto_forward != undefined)
	{
		_btn_auto_forward.text = "Auto Forward: " + (global.settings.mp_host_auto_forward ? "On" : "Off");
	}
	
	if (_btn_public_ip != undefined)
	{
		_btn_public_ip.text = "Public Invite: " + (global.settings.mp_host_advertise_public_ip ? "On" : "Off");
	}
	
	if (_btn_build != undefined)
	{
		_btn_build.text = "Building: " + (global.settings.mp_host_allow_build ? "On" : "Off");
	}
	
	if (_btn_containers != undefined)
	{
		_btn_containers.text = "Containers: " + (global.settings.mp_host_allow_containers ? "On" : "Off");
	}
	
	if (_permission != undefined)
	{
		_permission.choice_index = clamp(floor(global.settings.mp_host_default_permission), SETTINGS_LEVEL.NONE, SETTINGS_LEVEL.MAX);
	}
}

function menu_multiplayer_ui_save_host_defaults(_port, _max_players, _permission_index)
{
	global.settings.mp_host_port = _port;
	global.settings.mp_host_max_players = _max_players;
	global.settings.mp_host_default_permission = _permission_index;
	file_save_settings();
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
	var _input_join_password = _elements[$ "input_join_password"];
	
	if (_btn_connect != undefined && _input_invite_code != undefined)
	{
		_btn_connect.add_event_handler("on_select_release", method(_input_invite_code, function() {
			var _code = self.text;
			var _password = (_input_join_password != undefined) ? _input_join_password.text : "";
			
			_code = string_replace_all(_code, "-", "");
	        _code = string_replace_all(_code, " ", "");
	        
	        if (string_length(_code) > 0)
	        {
	            PRINT($"[MENU] Joining session with code: {_code}");
	            
	            if (global.relay_manager.join_session(_code, _password))
	            {
	                PRINT("[MENU] Connection initiated...");
					menu_multiplayer_ui_set_status("Connecting to host...");
	            }
	            else
	            {
	                PRINT("[MENU] Failed to join session - invalid code?");
					menu_multiplayer_ui_set_status("Unable to join. Check the invite code.");
	            }
	        }
	        else
	        {
	            PRINT("[MENU] Please enter an invite code");
				menu_multiplayer_ui_set_status("Enter an invite code to connect.");
	        }
		}));
	}
	
	var _input_host_port = _elements[$ "input_host_port"];
	var _input_host_max_players = _elements[$ "input_host_max_players"];
	var _input_host_password = _elements[$ "input_host_password"];
	var _drop_guest_permission = _elements[$ "drop_guest_permission"];
	var _btn_auto_forward = _elements[$ "btn_toggle_auto_forward"];
	var _btn_public_ip = _elements[$ "btn_toggle_public_ip"];
	var _btn_build = _elements[$ "btn_toggle_build"];
	var _btn_containers = _elements[$ "btn_toggle_containers"];
	var _btn_host = _elements[$ "btn_host"];
	var _btn_copy_code = _elements[$ "btn_copy_code"];
	var _btn_leave_session = _elements[$ "btn_leave_session"];
	
	if (_input_host_port != undefined) _input_host_port.text = string(round(global.settings.mp_host_port ?? 6510));
	if (_input_host_max_players != undefined) _input_host_max_players.text = string(round(global.settings.mp_host_max_players ?? 4));
	if (_drop_guest_permission != undefined) _drop_guest_permission.choice_index = clamp(floor(global.settings.mp_host_default_permission ?? SETTINGS_LEVEL.MIN), SETTINGS_LEVEL.NONE, SETTINGS_LEVEL.MAX);
	
	if (_btn_auto_forward != undefined)
	{
		_btn_auto_forward.add_event_handler("on_select_release", function() {
			global.settings.mp_host_auto_forward = !global.settings.mp_host_auto_forward;
			file_save_settings();
			menu_multiplayer_ui_refresh_host_toggles();
		});
	}
	
	if (_btn_public_ip != undefined)
	{
		_btn_public_ip.add_event_handler("on_select_release", function() {
			global.settings.mp_host_advertise_public_ip = !global.settings.mp_host_advertise_public_ip;
			file_save_settings();
			menu_multiplayer_ui_refresh_host_toggles();
		});
	}
	
	if (_btn_build != undefined)
	{
		_btn_build.add_event_handler("on_select_release", function() {
			global.settings.mp_host_allow_build = !global.settings.mp_host_allow_build;
			file_save_settings();
			menu_multiplayer_ui_refresh_host_toggles();
		});
	}
	
	if (_btn_containers != undefined)
	{
		_btn_containers.add_event_handler("on_select_release", function() {
			global.settings.mp_host_allow_containers = !global.settings.mp_host_allow_containers;
			file_save_settings();
			menu_multiplayer_ui_refresh_host_toggles();
		});
	}
	
	if (_btn_host != undefined)
	{
		_btn_host.add_event_handler("on_select_release", function() {
			if (global.relay_manager.is_in_session())
			{
				menu_multiplayer_ui_set_status("Leave the current session before hosting a new one.");
				exit;
			}
			
			var _port = real((_input_host_port != undefined && _input_host_port.text != "") ? _input_host_port.text : string(global.settings.mp_host_port ?? 6510));
			var _max_players = real((_input_host_max_players != undefined && _input_host_max_players.text != "") ? _input_host_max_players.text : string(global.settings.mp_host_max_players ?? 4));
			var _permission = (_drop_guest_permission != undefined) ? _drop_guest_permission.choice_index : SETTINGS_LEVEL.MIN;
			var _password = (_input_host_password != undefined) ? _input_host_password.text : "";
			
			_port = clamp(_port, 1024, 65535);
			_max_players = clamp(_max_players, 2, 8);
			
			menu_multiplayer_ui_save_host_defaults(_port, _max_players, _permission);
			
			var _code = global.relay_manager.host_session({
				port: _port,
				password: _password,
				max_players: _max_players,
				default_permission_level: _permission,
				auto_forward: !!global.settings.mp_host_auto_forward,
				advertise_public_ip: !!global.settings.mp_host_advertise_public_ip,
				allow_build: !!global.settings.mp_host_allow_build,
				allow_containers: !!global.settings.mp_host_allow_containers
			});
			
			if (_code != "")
			{
				menu_multiplayer_ui_set_status($"Hosting on port {_port}. Invite is ready.");
				menu_multiplayer_ui_refresh_room_code();
			}
			else
			{
				menu_multiplayer_ui_set_status($"Unable to host on port {_port}. It may already be in use.");
			}
		});
	}
	
	if (_btn_copy_code != undefined)
	{
		_btn_copy_code.add_event_handler("on_select_release", function() {
			if (global.relay_manager.copy_room_code())
			{
				menu_multiplayer_ui_refresh_room_code();
				menu_multiplayer_ui_set_status("Invite code copied to clipboard.");
			}
			else
			{
				menu_multiplayer_ui_set_status("Start a host session first.");
			}
		});
	}
	
	if (_btn_leave_session != undefined)
	{
		_btn_leave_session.add_event_handler("on_select_release", function() {
			if (global.relay_manager.is_in_session())
			{
				global.relay_manager.leave_session();
				menu_multiplayer_ui_set_status("Session closed.");
				menu_multiplayer_ui_refresh_room_code();
			}
			else
			{
				menu_multiplayer_ui_set_status("No active session to leave.");
			}
		});
	}
	
	menu_multiplayer_ui_refresh_host_toggles();
	menu_multiplayer_ui_refresh_room_code();
	
	if (global.relay != undefined && global.relay.last_disconnect_reason != "")
	{
		menu_multiplayer_ui_set_status($"Last network message: {global.relay.last_disconnect_reason}");
	}
}
