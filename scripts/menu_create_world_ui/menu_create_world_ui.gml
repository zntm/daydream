global.ui_create_world = undefined;


function menu_create_world_ui_load()
{
	/* hide legacy room instances */
	menu_create_world_ui_cleanup_legacy();
	
	
	/* ensure gui_root exists (menu rooms don't create one) */
	if (!variable_global_exists("gui_root")) || (global.gui_root == undefined)
	{
		var _design_w = 960;
		
		var _logical_width  = _design_w / global.gui_scale;
		var _logical_height = global.gui_height / (global.gui_width / _logical_width);
		
		global.gui_root = new UIElement(0, 0, _logical_width, _logical_height);
		global.gui_root.element_name = "gui_root";
	}
	
	
	var _def = ui_load("ui/create_world.ui");
	
	if (_def == undefined)
	{
		show_debug_message("[Create World] failed to load create_world.ui");
		
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
	var _world = global.current_world;
	
	
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
	}
	
	
	/* difficulty */
	var _difficulty = _elements[$ "difficulty"];
	
	if (_difficulty != undefined)
	{
		_difficulty.value = _world[$ "difficulty"] ?? 1;
	}
	
	
	/* death penalty */
	var _item_drop = _elements[$ "item_drop_pct"];
	
	if (_item_drop != undefined)
	{
		_item_drop.value = _world.death_penalty.item_drop_percentage;
	}
	
	
	var _item_durability = _elements[$ "item_durability_pct"];
	
	if (_item_durability != undefined)
	{
		_item_durability.value = _world.death_penalty.item_durability_percentage;
	}
	
	
	/* backup */
	var _backup_interval = _elements[$ "backup_interval"];
	
	if (_backup_interval != undefined)
	{
		_backup_interval.value = _world.backup.interval_minutes;
	}
	
	
	var _backup_slots_slider = _elements[$ "backup_slots"];
	
	if (_backup_slots_slider != undefined)
	{
		_backup_slots_slider.value = _world.backup.slots;
	}
	
	
	/* game rules */
	var _advance_time = _elements[$ "advance_time"];
	
	if (_advance_time != undefined)
	{
		_advance_time.value = _world.gamerule.advance_time;
	}
	
	
	var _friendly_fire = _elements[$ "friendly_fire"];
	
	if (_friendly_fire != undefined)
	{
		_friendly_fire.selected = _world.gamerule.friendly_fire;
	}
	
	
	var _entity_drops = _elements[$ "entity_drops"];
	
	if (_entity_drops != undefined)
	{
		_entity_drops.selected = (_world.gamerule.item_drops.entity_percentage > 0);
	}
	
	
	var _tile_drops = _elements[$ "tile_drops"];
	
	if (_tile_drops != undefined)
	{
		_tile_drops.selected = (_world.gamerule.item_drops.tile_percentage > 0);
	}
	
	
	var _natural_regen = _elements[$ "natural_regen"];
	
	if (_natural_regen != undefined)
	{
		_natural_regen.value = _world.gamerule.natural_regeneration;
	}
	
	
	/* expand/collapse buttons */
	menu_create_world_ui_bind_toggle(_elements, "btn_death_penalty", "death_penalty_content");
	menu_create_world_ui_bind_toggle(_elements, "btn_advanced", "advanced_content");
	menu_create_world_ui_bind_toggle(_elements, "btn_backup", "backup_content");
	menu_create_world_ui_bind_toggle(_elements, "btn_game_rules", "game_rules_content");
	menu_create_world_ui_bind_toggle(_elements, "btn_item_drops", "item_drops_content");
	
	
	/* randomize buttons */
	var _btn_rand_name = _elements[$ "btn_randomize_name"];
	
	if (_btn_rand_name != undefined)
	{
		_btn_rand_name.add_event_handler("on_select_release", method(
			{ name_box: _name_box },
			function()
			{
				var _name;
				
				do
				{
					_name = menu_textbox_randomize_world_name();
				}
				until (string(_name) != "undefined") && (string_length(_name) <= 40);
				
				name_box.set_value(_name);
			}
		));
	}
	
	
	var _btn_rand_seed = _elements[$ "btn_randomize_seed"];
	
	if (_btn_rand_seed != undefined)
	{
		_btn_rand_seed.add_event_handler("on_select_release", method(
			{ seed_box: _seed_box },
			function()
			{
				seed_box.set_value(string(irandom_range(-0x8000_0000, 0x7fff_ffff)));
			}
		));
	}
	
	
	/* create world button */
	var _btn_create = _elements[$ "btn_create_world"];
	
	if (_btn_create != undefined)
	{
		_btn_create.add_event_handler("on_select_release", method(
			{ inst: _instance },
			function()
			{
				menu_create_world_ui_submit(inst);
			}
		));
	}
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
			
			
			if (content.parent != undefined) && (struct_exists(content.parent, "layout_children"))
			{
				content.parent.layout_children();
			}
		}
	));
}


function menu_create_world_ui_submit(_instance)
{
	var _elements = _instance.elements;
	
	
	/* read name */
	var _name_box = _elements[$ "world_name"];
	var _name = (_name_box != undefined) ? string_trim(_name_box.get_value()) : "";
	
	if (_name == "")
	{
		show_debug_message("[Create World] empty name, aborting");
		
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
	with (obj_Menu_Anchor)
	{
		y = -1000;
	}
	
	
	with (obj_Menu_Button)
	{
		y = -1000;
	}
	
	
	with (obj_Menu_Dropdown)
	{
		y = -1000;
	}
	
	
	with (obj_Menu_Textbox)
	{
		y = -1000;
	}
}
