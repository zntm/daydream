function menu_credits_ui_load()
{
	menu_ui_clear_all();
	
	/* clean up legacy */
    if (instance_exists(obj_Menu_Credits)) instance_destroy(obj_Menu_Credits);
	instance_destroy(obj_Menu_Button);
	instance_destroy(obj_Menu_Anchor);
	
	/* ensure gui_root exists */
	if (!variable_global_exists("gui_root")) || (global.gui_root == undefined)
	{
		global.gui_root = ui_create_root();
		global.gui_root.element_name = "gui_root";
	}
	
	/* cache reload */
	if (variable_global_exists("ui_definitions"))
	{
		var _full_path = "resources/data/ui/menu/credits.ui";
		if (struct_exists(global.ui_definitions, _full_path))
		{
			struct_remove(global.ui_definitions, _full_path);
		}
	}
	
	var _def = ui_load("ui/menu/credits.ui");
	
	if (_def == undefined)
	{
		PRINT("[Menu Credits] failed to load ui/menu/credits.ui");
		exit;
	}
	
	var _instance = ui_spawn(_def, {
		link: {},
		parent: global.gui_root
	});
	
	global.ui_credits_menu = _instance;
	
	menu_credits_ui_init();
}

function menu_credits_ui_init()
{
	var _instance = global.ui_credits_menu;
	var _elements = _instance.elements;
	
	var _btn_back = _elements[$ "btn_back"];
	
	if (_btn_back != undefined)
	{
		_btn_back.add_event_handler("on_select_release", function() {
			menu_transition_goto(rm_Menu_Title);
		});
	}
	
	var _list = _elements[$ "credits_list"];
	var _scroll = _elements[$ "credits_scroll"];
	
	if (_list != undefined)
	{
		var _credit_data = global.credit_data;
        var _length = array_length(_credit_data);
        var _ypos = 16;
        
        for (var i = 0; i < _length; ++i)
        {
            var _credits = _credit_data[i];
            var _header_text = loca_translate($"menu.credits.header.{_credits.header}");
            
            var _header_ui = new UIText(400, _ypos, "");
            _header_ui.text = _header_text;
            _header_ui.text_halign = "fa_center";
            _header_ui.colour = _credits.colour;
            
            _header_ui.parent = _list;
            array_push(_list.children, _header_ui);
            
            _ypos += 24;
            
            var _entries = _credits.entries;
            var _entries_length = _credits.entries_length;
            
            for (var j = 0; j < _entries_length; ++j)
            {
                var _entry = _entries[j];
                var _name = _entry.name;
                
                var _entry_ui = new UIText(400, _ypos, "");
                _entry_ui.text = _name;
                _entry_ui.text_scale = 0.8;
                _entry_ui.text_halign = "fa_center";
                _entry_ui.colour = _entry[$ "colour"] ?? c_white;
                
                _entry_ui.parent = _list;
                array_push(_list.children, _entry_ui);
                
                _ypos += 24;
            }
            
            _ypos += 16;
        }
        
        _list.height = _ypos;

	}
}
