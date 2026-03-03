global.ui_title_menu = undefined;


function menu_title_ui_load()
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
		var _full_path = "resources/data/ui/menu/title.ui";
		if (struct_exists(global.ui_definitions, _full_path))
		{
			struct_remove(global.ui_definitions, _full_path);
		}
	}
	
	var _def = ui_load("ui/menu/title.ui");
	
	if (_def == undefined)
	{
		show_debug_message("[Menu Title] failed to load ui/menu/title.ui");
		exit;
	}
	
	var _instance = ui_spawn(_def, {
		link: {},
		parent: global.gui_root
	});
	
	global.ui_title_menu = _instance;
	
	menu_title_ui_init();
}


function menu_title_ui_init()
{
	var _instance = global.ui_title_menu;
	var _elements = _instance.elements;
	
	/* splash text */
	var _title_graphic = _elements[$ "title_graphic"];
	
	if (_title_graphic != undefined)
	{
		var _splash_data = global.menu_data.splash_texts;
		var _splash_current_date = _splash_data[$ $"{current_month}_{current_day}"];
		var _splash_text = array_choose(((chance(0.1)) && (_splash_current_date != undefined)) ? _splash_current_date : _splash_data.generic);
		
		_title_graphic.on_draw = method(
			{ _text: _splash_text },
			function(_x, _y, _xscale, _yscale)
			{
			    draw_sprite_ext(spr_Menu_Title, 0, _x, _y + 4, 2, 2, 0, c_black, 0.25);
			    draw_sprite_ext(spr_Menu_Title, 0, _x, _y,     2, 2, 0, c_white, 1);
			    
			    var _halign = draw_get_halign();
			    var _valign = draw_get_valign();
			    
			    draw_set_align(fa_middle, fa_center);
			    
			    render_text(_x + (sprite_get_width(spr_Menu_Title) * 2 / 2), _y + (sprite_get_height(spr_Menu_Title) * 2), _text, 1, 1, 12, MENU_TITLE_SPLASH_COLOUR);
			    
			    draw_set_align(_halign, _valign);
			}
		);
	}
	
	
	/* version graphic */
	var _version_graphic = _elements[$ "version_graphic"];
	
	if (_version_graphic != undefined)
	{
		_version_graphic.on_draw = method(
			{},
			function(_x, _y, _xscale, _yscale)
			{
			    var _halign = draw_get_halign();
			    var _valign = draw_get_valign();
			    
			    draw_set_align(fa_right, fa_bottom);
			    
			    render_text(_x, _y, program_get_version());
			    
			    draw_set_align(_halign, _valign);
			}
		);
	}
	
	
	/* buttons */
	var _btn_play = _elements[$ "btn_play"];
	if (_btn_play != undefined)
	{
		_btn_play.text = loca_translate("phantasia:menu.title.play");
		_btn_play.add_event_handler("on_select_release", function() {
			menu_transition_goto(rm_Menu_Players);
		});
	}
	
	var _btn_settings = _elements[$ "btn_settings"];
	if (_btn_settings != undefined)
	{
		_btn_settings.text = loca_translate("phantasia:menu.settings.title");
		_btn_settings.add_event_handler("on_select_release", function() {
			menu_transition_goto(rm_Menu_Settings);
		});
	}
	
	var _btn_credits = _elements[$ "btn_credits"];
	if (_btn_credits != undefined)
	{
		_btn_credits.text = loca_translate("phantasia:menu.title.credits");
		_btn_credits.add_event_handler("on_select_release", function() {
			menu_transition_goto(rm_Menu_Credits);
		});
	}
	
	var _btn_exit = _elements[$ "btn_exit"];
	if (_btn_exit != undefined)
	{
		_btn_exit.text = loca_translate("phantasia:menu.title.exit");
		_btn_exit.add_event_handler("on_select_release", function() {
			menu_title_ui_popup_exit();
		});
	}
}


function menu_title_ui_popup_exit()
{
	/* create popup container */
	var _popup_root = new UIElement(0, 0, 960, 540);

	var _bg = new UIElement(300, 196, 360, 148);
	_bg.background_color = #1e1e2e;
	_bg.border_color = #3a3a4a;
	_bg.parent = _popup_root;
	array_push(_popup_root.children, _bg);

	var _header = new UIText(0, 0, loca_translate("phantasia:menu.exit.header"));
	_header.halign = fa_center;
	_header.valign = fa_middle;
	_header.parent = _bg;
	_header.x = _bg.width / 2;
	_header.y = 36;
	array_push(_bg.children, _header);

	var _btn_no = new UIButton(40, 80, 120, 32, loca_translate("phantasia:menu.generic.no"));
	_btn_no.parent = _bg;
	_btn_no.add_event_handler("on_select_release", method({ _root: _popup_root }, function()
	{
		/* remove popup from gui_root */
		var _children = global.gui_root.children;

		for (var i = array_length(_children) - 1; i >= 0; --i)
		{
			if (_children[i] == _root)
			{
				array_delete(_children, i, 1);

				break;
			}
		}
	}));
	array_push(_bg.children, _btn_no);

	var _btn_yes = new UIButton(200, 80, 120, 32, loca_translate("phantasia:menu.generic.yes"));
	_btn_yes.parent = _bg;
	_btn_yes.add_event_handler("on_select_release", function()
	{
		game_end();
	});
	array_push(_bg.children, _btn_yes);

	_popup_root.parent = global.gui_root;
	array_push(global.gui_root.children, _popup_root);
}
