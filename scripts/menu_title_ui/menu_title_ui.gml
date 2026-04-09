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
		global.gui_root = ui_create_root();
		global.gui_root.element_name = "gui_root";
	}
	
	/* cache reload */
	ui_invalidate_definition("ui/menu/title.ui");
	
	var _def = ui_load("ui/menu/title.ui");
	
	if (_def == undefined)
	{
		PRINT("[Menu Title] failed to load ui/menu/title.ui");
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
		
		_title_graphic.splash_text = _splash_text;
		
		_title_graphic.on_draw = method(_title_graphic, function(_x, _y, _xscale, _yscale)
		{
			var _title_spr = spr_Menu_Title;
			var _asset     = global.sprite_asset[$ "phantasia:ui/title"];
			
			if (_asset != undefined)
			{
				_title_spr = _asset.get_sprite();
			}
			
			var _s  = 2;
			var _sw = sprite_get_width(_title_spr) * _s;
			var _sh = sprite_get_height(_title_spr) * _s;
			var _ox = sprite_get_xoffset(_title_spr) * _s;
			var _oy = sprite_get_yoffset(_title_spr) * _s;
			
			/* align top-center of sprite visual bounds to (_x, _y) */
			var _draw_x = _x - (_sw / 2) + _ox;
			var _draw_y = _y + _oy;
			
			draw_sprite_ext(_title_spr, 0, _draw_x, _draw_y + 4, _s, _s, 0, c_black, 0.25);
			draw_sprite_ext(_title_spr, 0, _draw_x, _draw_y,     _s, _s, 0, c_white, 1);
			
			var _halign = draw_get_halign();
			var _valign = draw_get_valign();
			
			draw_set_align(fa_middle, fa_center);

			var _splash_x = _draw_x + _sw - _ox - 38;
			var _splash_y = _draw_y + _sh - _oy - 10;
			render_text(_splash_x + 2, _splash_y + 2, splash_text, 0.85, 0.85, -14, c_black, 0.25);
			render_text(_splash_x, _splash_y, splash_text, 0.85, 0.85, -14, MENU_TITLE_SPLASH_COLOUR);
			
			draw_set_align(_halign, _valign);
		});
	}
	
	
	/* version graphic */
	var _version_graphic = _elements[$ "version_graphic"];
	
	if (_version_graphic != undefined)
	{
		_version_graphic.on_draw = method(_version_graphic, function(_x, _y, _xscale, _yscale)
		{
			var _halign = draw_get_halign();
			var _valign = draw_get_valign();
			
			draw_set_align(fa_right, fa_bottom);
			
			render_text(_x, _y, "v" + program_get_version(), 0.7, 0.7, 0, c_white, 0.5);
			
			draw_set_align(_halign, _valign);
		});
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
	
	/* socials */
	var _btn_twitter = _elements[$ "btn_twitter"];
	if (_btn_twitter != undefined)
	{
		_btn_twitter.boolean = 0;
		_btn_twitter.on_draw = method(_btn_twitter, function(_x, _y, _xscale, _yscale) {
			var _asset = global.sprite_asset[$ "phantasia:ui/site_twitter"];
			if (_asset != undefined)
			{
				var _cx = _x + (self.width * _xscale / 2);
				var _cy = _y + (self.height * _yscale / 2);
				var _s = ((struct_exists(self, "is_hovered")) && (self.is_hovered)) ? 2.2 : 2.0;
				draw_sprite_ext(_asset.get_sprite(), 0, _cx, _cy, _s, _s, 0, c_white, 1);
			}
		});
		
		_btn_twitter.add_event_handler("on_select_release", function() {
			url_open(SITE_TWITTER);
		});
	}
	
	var _btn_bluesky = _elements[$ "btn_bluesky"];
	if (_btn_bluesky != undefined)
	{
		_btn_bluesky.boolean = 0;
		_btn_bluesky.on_draw = method(_btn_bluesky, function(_x, _y, _xscale, _yscale) {
			var _asset = global.sprite_asset[$ "phantasia:ui/site_bluesky"];
			if (_asset != undefined)
			{
				var _cx = _x + (self.width * _xscale / 2);
				var _cy = _y + (self.height * _yscale / 2);
				var _s = ((struct_exists(self, "is_hovered")) && (self.is_hovered)) ? 2.2 : 2.0;
				draw_sprite_ext(_asset.get_sprite(), 0, _cx, _cy, _s, _s, 0, c_white, 1);
			}
		});
		
		_btn_bluesky.add_event_handler("on_select_release", function() {
			url_open(SITE_BLUESKY);
		});
	}
	
	var _btn_discord = _elements[$ "btn_discord"];
	if (_btn_discord != undefined)
	{
		_btn_discord.boolean = 0;
		_btn_discord.on_draw = method(_btn_discord, function(_x, _y, _xscale, _yscale) {
			var _asset = global.sprite_asset[$ "phantasia:ui/site_discord"];
			if (_asset != undefined)
			{
				var _cx = _x + (self.width * _xscale / 2);
				var _cy = _y + (self.height * _yscale / 2);
				var _s = ((struct_exists(self, "is_hovered")) && (self.is_hovered)) ? 2.2 : 2.0;
				draw_sprite_ext(_asset.get_sprite(), 0, _cx, _cy, _s, _s, 0, c_white, 1);
			}
		});
		
		_btn_discord.add_event_handler("on_select_release", function() {
			url_open(SITE_DISCORD);
		});
	}
}

function menu_title_ui_popup_exit()
{
	/* create popup container */
	var _popup_root = ui_create_root();

	var _bg = new UIElement(0, 0, 360, 148);
	_bg.background_color = #1e1e2e;
	_bg.border_color = #3a3a4a;
    _bg.set_anchor("center", "middle");
	_popup_root.add_child(_bg);

	var _header = new UIText(0, 0, loca_translate("phantasia:menu.exit.header"));
	_header.halign = fa_center;
	_header.valign = fa_middle;
	_header.x = _bg.width / 2;
	_header.y = 36;
	_bg.add_child(_header);

	var _btn_no = new UIButton(40, 80, 120, 32, loca_translate("phantasia:menu.generic.no"));
	_bg.add_child(_btn_no);
	_btn_no.add_event_handler("on_select_release", method({ _root: _popup_root }, function()
	{
		global.gui_root.remove_child(_root);
	}));

	var _btn_yes = new UIButton(200, 80, 120, 32, loca_translate("phantasia:menu.generic.yes"));
	_bg.add_child(_btn_yes);
	_btn_yes.add_event_handler("on_select_release", function()
	{
		game_end();
	});

	global.gui_root.add_child(_popup_root);
}
