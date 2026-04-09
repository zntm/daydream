global.ui_create_world = undefined;


function menu_create_world_ui_load()
{
	menu_ui_clear_all();
	
	/* hide legacy room instances */
	menu_create_world_ui_cleanup_legacy();
	
	
	/* ensure gui_root exists (menu rooms don't create one) */
	if (!variable_global_exists("gui_root")) || (global.gui_root == undefined)
	{
		global.gui_root = ui_create_root();
		global.gui_root.element_name = "gui_root";
	}
	
	
	/* reload definition if it exists in cache */
	ui_invalidate_definition("ui/menu/create_world.ui");
	
	
	var _def = ui_load("ui/menu/create_world.ui");
	
	if (_def == undefined)
	{
		PRINT("[Create World] failed to load create_world.ui");
		
		exit;
	}
	
	
	var _instance = ui_spawn(_def, {
		link: {},
		parent: global.gui_root
	});
	
	
	global.ui_create_world = _instance;
	
	
	menu_create_world_ui_init();
}


function menu_create_world_ui_init()
{
	var _instance = global.ui_create_world;
	var _elements = _instance.elements;
	
	menu_refresh_value_world_save();
	
	var _world = global.current_world;
	var _title = _elements[$ "title"];
	if (_title != undefined)
	{
		_title.text = menu_ui_localize_or_default("phantasia:menu.worlds.create", "Create World");
	}
	
	
	/* back button */
	var _btn_back = _elements[$ "btn_back"];
	
	if (_btn_back != undefined)
	{
		_btn_back.text = menu_ui_localize_or_default("phantasia:menu.generic.back", "Back");
		
		_btn_back.add_event_handler("on_select_release", function() {
			menu_transition_goto(rm_Menu_Worlds);
		});
	}
	
	
	/* world name */
	var _name_box = _elements[$ "world_name"];
	
	if (_name_box != undefined)
	{
		var _name = _world.name;
		
		if (_name == "")
		{
			do
			{
				_name = menu_textbox_randomize_world_name();
			}
			until (string(_name) != "undefined") && (string_length(_name) <= 40);
		}
		
		_name_box.set_value(_name);
		_world.name = _name;
		
		_name_box.add_event_handler("on_input", method(_name_box, function(_data) {
			global.current_world.name = self.text;
		}));
		
		_name_box.add_event_handler("on_change", method(_name_box, function(_data) {
			global.current_world.name = self.text;
		}));
	}
	
	
	/* world seed */
	var _seed_box = _elements[$ "world_seed"];
	
	if (_seed_box != undefined)
	{
		var _seed = _world.seed;
		
		if (_seed == 0)
		{
			_seed = string(irandom_range(-0x8000_0000, 0x7fff_ffff));
		}
		
		_seed_box.set_value(_seed);
		_world.seed = _seed;
		
		_seed_box.add_event_handler("on_input", method(_seed_box, function(_data) {
			global.current_world.seed = self.get_value();
		}));
		
		_seed_box.add_event_handler("on_change", method(_seed_box, function(_data) {
			global.current_world.seed = self.get_value();
		}));
	}
	
	
	/* difficulty */
	var _difficulty = _elements[$ "difficulty"];
	
	if (_difficulty != undefined)
	{
		_difficulty.value = _world[$ "difficulty"] ?? 1;
		_difficulty.add_event_handler("on_drag", method(_difficulty, function(_data) {
			global.current_world.difficulty = self.value;
		}));
		_difficulty.add_event_handler("on_value_change", method(_difficulty, function(_value) {
			global.current_world.difficulty = self.value;
		}));
	}
	
	var _permissions = _elements[$ "permissions"];
	
	if (_permissions != undefined)
	{
		var _permission_level = _world.default_permission.level ?? SETTINGS_LEVEL.MIN;
		_permissions.set_choices(["None", "Minimal", "Full"]);
		_permissions.set_selected(_permission_level);
		_world.default_permission.level = _permission_level;
		_permissions.add_event_handler("on_change", method(_permissions, function(_data) {
			global.current_world.default_permission.level = self.choice_index;
		}));
	}
	
	
	/* death penalty */
	var _item_drop = _elements[$ "item_drop_pct"];
	
	if (_item_drop != undefined)
	{
		_item_drop.value = _world.death_penalty.item_drop_percentage;
		_item_drop.add_event_handler("on_drag", method(_item_drop, function(_data) {
			global.current_world.death_penalty.item_drop_percentage = self.value;
		}));
		_item_drop.add_event_handler("on_value_change", method(_item_drop, function(_value) {
			global.current_world.death_penalty.item_drop_percentage = self.value;
		}));
	}
	
	
	var _item_durability = _elements[$ "item_durability_pct"];
	
	if (_item_durability != undefined)
	{
		_item_durability.value = _world.death_penalty.item_durability_percentage;
		_item_durability.add_event_handler("on_drag", method(_item_durability, function(_data) {
			global.current_world.death_penalty.item_durability_percentage = self.value;
		}));
		_item_durability.add_event_handler("on_value_change", method(_item_durability, function(_value) {
			global.current_world.death_penalty.item_durability_percentage = self.value;
		}));
	}
	
	
	/* backup */
	var _backup_interval = _elements[$ "backup_interval"];
	
	if (_backup_interval != undefined)
	{
		_backup_interval.value = _world.backup.interval_minutes;
		_backup_interval.add_event_handler("on_drag", method(_backup_interval, function(_data) {
			global.current_world.backup.interval_minutes = self.value;
		}));
		_backup_interval.add_event_handler("on_value_change", method(_backup_interval, function(_value) {
			global.current_world.backup.interval_minutes = self.value;
		}));
	}
	
	
	var _backup_slots_slider = _elements[$ "backup_slots"];
	
	if (_backup_slots_slider != undefined)
	{
		_backup_slots_slider.value = _world.backup.slots;
		_backup_slots_slider.add_event_handler("on_drag", method(_backup_slots_slider, function(_data) {
			global.current_world.backup.slots = self.value;
		}));
		_backup_slots_slider.add_event_handler("on_value_change", method(_backup_slots_slider, function(_value) {
			global.current_world.backup.slots = self.value;
		}));
	}
	
	
	/* game rules */
	var _advance_time = _elements[$ "advance_time"];
	
	if (_advance_time != undefined)
	{
		_advance_time.value = _world.gamerule.advance_time;
		_advance_time.add_event_handler("on_drag", method(_advance_time, function(_data) {
			global.current_world.gamerule.advance_time = self.value;
		}));
		_advance_time.add_event_handler("on_value_change", method(_advance_time, function(_value) {
			global.current_world.gamerule.advance_time = self.value;
		}));
	}
	
	
	var _friendly_fire = _elements[$ "friendly_fire"];
	
	if (_friendly_fire != undefined)
	{
		_friendly_fire.selected = _world.gamerule.friendly_fire;
		_friendly_fire.add_event_handler("on_change", method(_friendly_fire, function(_data) {
			global.current_world.gamerule.friendly_fire = self.selected;
		}));
	}
	
	
	var _entity_drops = _elements[$ "entity_drops"];
	
	if (_entity_drops != undefined)
	{
		_entity_drops.selected = (_world.gamerule.item_drops.entity_percentage > 0);
		_entity_drops.add_event_handler("on_change", method(_entity_drops, function(_data) {
			global.current_world.gamerule.item_drops.entity_percentage = self.selected ? 100 : 0;
		}));
	}
	
	
	var _tile_drops = _elements[$ "tile_drops"];
	
	if (_tile_drops != undefined)
	{
		_tile_drops.selected = (_world.gamerule.item_drops.tile_percentage > 0);
		_tile_drops.add_event_handler("on_change", method(_tile_drops, function(_data) {
			global.current_world.gamerule.item_drops.tile_percentage = self.selected ? 100 : 0;
		}));
	}
	
	
	var _natural_regen = _elements[$ "natural_regen"];
	
	if (_natural_regen != undefined)
	{
		_natural_regen.value = _world.gamerule.natural_regeneration;
		_natural_regen.add_event_handler("on_drag", method(_natural_regen, function(_data) {
			global.current_world.gamerule.natural_regeneration = self.value;
		}));
		_natural_regen.add_event_handler("on_value_change", method(_natural_regen, function(_value) {
			global.current_world.gamerule.natural_regeneration = self.value;
		}));
	}
	
	var _renderer = _elements[$ "preview_renderer"];
	if (_renderer != undefined)
	{
		_renderer.on_draw = method(_renderer, function(_x, _y, _xscale, _yscale) {
			menu_create_world_ui_draw_preview(_x, _y, self.width * _xscale, self.height * _yscale);
		});
	}
	
	
	/* expand/collapse buttons */
	menu_create_world_ui_bind_toggle(_elements, "btn_death_penalty", "death_penalty_content");
	menu_create_world_ui_bind_toggle(_elements, "btn_advanced", "advanced_content");
	menu_create_world_ui_bind_toggle(_elements, "btn_backup", "backup_content");
	menu_create_world_ui_bind_toggle(_elements, "btn_game_rules", "game_rules_content");
	menu_create_world_ui_bind_toggle(_elements, "btn_item_drops", "item_drops_content");
	
	
	var _btn_rand_seed = _elements[$ "btn_randomize_seed"];
	
	if (_btn_rand_seed != undefined)
	{
		_btn_rand_seed.add_event_handler("on_select_release", method(
			{ seed_box: _seed_box },
			function()
			{
				var _seed = string(irandom_range(-0x8000_0000, 0x7fff_ffff));
				seed_box.set_value(_seed);
				global.current_world.seed = _seed;
			}
		));
	}
	
	
	/* create world button */
	var _btn_create = _elements[$ "btn_create_world"];
	
	if (_btn_create != undefined)
	{
		_btn_create.text = menu_ui_localize_or_default("phantasia:menu.worlds.create", "Create World");
		_btn_create.add_event_handler("on_select_release", method(
			{ inst: _instance },
			function()
			{
				menu_create_world_ui_submit(inst);
			}
		));
	}
	
	menu_create_world_ui_refresh_layout_tree(ui_get(_instance, "options_content"));
}


function menu_create_world_ui_draw_preview(_x, _y, _w, _h)
{
	var _metrics = menu_ui_get_metrics();
	var _name = menu_ui_trim_text(global.current_world.name, 22);
	var _seed = string(global.current_world.seed);
	var _difficulty = global.current_world.difficulty ?? 1;
	var _drop_ratio = clamp((global.current_world.death_penalty.item_drop_percentage ?? 0) / 100, 0, 1);
	var _backup_ratio = clamp((global.current_world.backup.slots ?? 0) / 10, 0, 1);
	var _steps = 8;
	
	draw_set_alpha(0.12);
	draw_rectangle_colour(_x, _y, _x + _w, _y + _h, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(0.24);
	
	for (var i = 0; i < _steps; ++i)
	{
		var _slice_w = _w / _steps;
		var _seed_value = abs(string_get_seed(_seed + string(i)));
		var _height_ratio = ((_seed_value mod 9) + 2) / 12;
		var _hill_h = floor(_h * _height_ratio * 0.58);
		var _x1 = _x + (_slice_w * i);
		var _x2 = _x1 + _slice_w + 1;
		
		draw_rectangle_colour(_x1, _y + _h - _hill_h, _x2, _y + _h, c_white, c_white, c_white, c_white, false);
	}
	
	draw_set_alpha(0.16 + (_difficulty * 0.08));
	draw_rectangle_colour(_x + 16, _y + 18, _x + 16 + (_w - 32) * clamp((_difficulty + 1) / 5, 0, 1), _y + 28, c_white, c_white, c_white, c_white, false);
	draw_set_alpha(0.12 + (_drop_ratio * 0.28));
	draw_rectangle_colour(_x + 16, _y + 34, _x + 16 + (_w - 32) * _drop_ratio, _y + 42, c_white, c_white, c_white, c_white, false);
	draw_set_alpha(0.12 + (_backup_ratio * 0.28));
	draw_rectangle_colour(_x + 16, _y + 48, _x + 16 + (_w - 32) * _backup_ratio, _y + 56, c_white, c_white, c_white, c_white, false);
	draw_set_alpha(1);
	
	draw_rectangle_colour(_x, _y, _x + _w, _y + _h, _metrics.card_border, _metrics.card_border, _metrics.card_border, _metrics.card_border, true);
	draw_rectangle_colour(_x + 4, _y + 4, _x + _w - 4, _y + _h - 4, _metrics.card_border, _metrics.card_border, _metrics.card_border, _metrics.card_border, true);
	
	var _halign = draw_get_halign();
	var _valign = draw_get_valign();
	draw_set_align(fa_left, fa_top);
	render_text(_x + 16, _y + _h - 40, (_name == "" ? "Untitled World" : _name), 0.8, 0.8, 0, c_white, 1);
	render_text(_x + 16, _y + _h - 22, "Seed: " + menu_ui_trim_text(_seed, 18), 0.55, 0.55, 0, _metrics.text_dim, 1);
	draw_set_align(_halign, _valign);
}


function menu_create_world_ui_bind_toggle(_elements, _button_name, _content_name)
{
	var _btn = _elements[$ _button_name];
	var _content = _elements[$ _content_name];
	
	if (_btn == undefined) || (_content == undefined) exit;
	
	
	_btn.add_event_handler("on_select_release", method(
		{ content: _content },
		function()
		{
			content.visible = !(content.visible);
			menu_create_world_ui_refresh_layout_tree(content.parent ?? content);
		}
	));
}


function menu_create_world_ui_refresh_layout_tree(_element)
{
	var _current = _element;

	while (_current != undefined)
	{
		if (struct_exists(_current, "layout_children"))
		{
			_current.layout_children();
		}

		menu_create_world_ui_refresh_flow_height(_current);

		if (instanceof(_current) == "UIScrollArea")
		{
			if (struct_exists(_current, "recalculate_content_size"))
			{
				_current.recalculate_content_size();
			}

			_current.scroll_offset = clamp(_current.scroll_offset, 0, _current.get_max_scroll());
		}

		_current = _current.parent;
	}
}


function menu_create_world_ui_refresh_flow_height(_element)
{
	if (_element == undefined) exit;

	if (struct_exists(_element, "children"))
	{
		var _max_bottom = 0;
		var _child_count = array_length(_element.children);

		for (var i = 0; i < _child_count; ++i)
		{
			var _child = _element.children[i];
			if (_child == undefined || !(_child.visible)) continue;

			menu_create_world_ui_refresh_flow_height(_child);
			_max_bottom = max(_max_bottom, _child.y + _child.height);
		}

		if (_element.element_name == "options_content"
		|| _element.element_name == "advanced_content"
		|| _element.element_name == "death_penalty_content"
		|| _element.element_name == "backup_content"
		|| _element.element_name == "game_rules_content"
		|| _element.element_name == "item_drops_content")
		{
			_element.height = _max_bottom;
		}
	}
}


function menu_create_world_ui_submit(_instance)
{
	var _elements = _instance.elements;
	
	
	/* read name */
	var _name_box = _elements[$ "world_name"];
	var _name = (_name_box != undefined) ? string_trim(_name_box.get_value()) : "";
	
	if (_name == "")
	{
		PRINT("[Create World] empty name, aborting");
		
		exit;
	}
	
	
	/* read seed */
	var _seed_box = _elements[$ "world_seed"];
	var _seed = (_seed_box != undefined) ? _seed_box.get_value() : "0";
	
	if (!string_contains(_seed, "."))
	{
		if (string_starts_with(_seed, "-"))
		{
			if ($"-{string_digits(_seed)}" == _seed)
			{
				_seed = real(_seed);
			}
		}
		else
		{
			if (string_digits(_seed) == _seed)
			{
				_seed = real(_seed);
			}
		}
	}
	
	if (is_string(_seed))
	{
		_seed = string_get_seed(_seed);
	}
	
	
	/* read difficulty */
	var _difficulty = _elements[$ "difficulty"];
	
	global.current_world.name = _name;
	global.current_world.seed = _seed;
	global.current_world.difficulty = (_difficulty != undefined) ? _difficulty.value : 1;
	
	
	/* death penalty */
	var _item_drop = _elements[$ "item_drop_pct"];
	var _item_durability = _elements[$ "item_durability_pct"];
	
	global.current_world.death_penalty.item_drop_percentage = (_item_drop != undefined) ? _item_drop.value : 0;
	global.current_world.death_penalty.item_durability_percentage = (_item_durability != undefined) ? _item_durability.value : 0;
	
	
	/* backup */
	var _backup_interval = _elements[$ "backup_interval"];
	var _backup_slots_slider = _elements[$ "backup_slots"];
	
	global.current_world.backup.interval_minutes = (_backup_interval != undefined) ? _backup_interval.value : 0;
	global.current_world.backup.slots = (_backup_slots_slider != undefined) ? _backup_slots_slider.value : 0;
	global.current_world.default_permission.level = (_elements[$ "permissions"] != undefined) ? _elements[$ "permissions"].choice_index : SETTINGS_LEVEL.MIN;
	
	
	/* game rules */
	var _advance_time = _elements[$ "advance_time"];
	var _friendly_fire = _elements[$ "friendly_fire"];
	var _entity_drops = _elements[$ "entity_drops"];
	var _tile_drops = _elements[$ "tile_drops"];
	var _natural_regen = _elements[$ "natural_regen"];
	
	global.current_world.gamerule.advance_time = (_advance_time != undefined) ? _advance_time.value : 1;
	global.current_world.gamerule.friendly_fire = (_friendly_fire != undefined) ? _friendly_fire.selected : false;
	global.current_world.gamerule.item_drops.entity_percentage = (_entity_drops != undefined && _entity_drops.selected) ? 100 : 0;
	global.current_world.gamerule.item_drops.tile_percentage = (_tile_drops != undefined && _tile_drops.selected) ? 100 : 0;
	global.current_world.gamerule.natural_regeneration = (_natural_regen != undefined) ? _natural_regen.value : 1;
	
	
	/* generate uuid */
	randomize();
	
	var _uuid = "";
	var _index = datetime_to_unix();
	
	do
	{
		_uuid = uuid_generate(++_index);
	}
	until (!directory_exists($"{PROGRAM_DIRECTORY_WORLDS}/{_uuid}"));
	
	global.current_world.uuid = _uuid;
	
	
	room_goto(rm_World);
}


function menu_create_world_ui_cleanup_legacy()
{
	/* destroy legacy room instances */
	instance_destroy(obj_Menu_Anchor);
	instance_destroy(obj_Menu_Button);
	instance_destroy(obj_Menu_Dropdown);
	instance_destroy(obj_Menu_Textbox);
}
