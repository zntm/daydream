function menu_create_world_ui_open()
{
    if (variable_global_exists("create_world_ui") && global.create_world_ui != undefined) exit;
    
    var _def = ui_load("ui/create_world.ui");
    
    if (_def == undefined)
    {
        show_debug_message("[create world ui] failed to load ui/create_world.ui");
        
        exit;
    }
    
    var _link = {
        world_name: "",
        world_seed: ""
    };
    
    global.create_world_ui = ui_spawn(_def, { link: _link });
    
    if (global.create_world_ui == undefined)
    {
        show_debug_message("[create world ui] failed to spawn create_world.ui");
        
        exit;
    }
    
    
    /* toggle state for expandable sections */
    global.create_world_sections =
    {
        death_penalty: false,
        advanced: false,
        backup: false,
        game_rules: false,
        item_drops: false
    };
    
    /* toggle state for checkboxes */
    global.create_world_toggles =
    {
        friendly_fire: false,
        entity_drops: true,
        tile_drops: true
    };
    
    /* permission state */
    global.create_world_permission = 0;
    
    /* Iterative layout and height refresh helper */
    var _ui_refresh_layout = function(_element)
    {
        var _curr = _element;
        
        while (_curr != undefined)
        {
            /* Layout children first */
            _curr.layout_children();
            
            /* If it's a scroll area, recalculate its content height */
            if (_curr.element_type == "scroll_area")
            {
                _curr.recalculate_content_height();
            }
            /* If it's an area (container), update its height to fit children */
            /* Skip if it's a fixed-size container like scroll_area or window */
            else if (_curr.element_type == "area")
            {
                var _children = _curr.children;
                var _child_count = array_length(_children);
                var _max_y = 0;
                
                for (var i = 0; i < _child_count; ++i)
                {
                    var _c = _children[i];
                    if (_c.visible)
                    {
                        _max_y = max(_max_y, _c.y + _c.height);
                    }
                }
                
                _curr.height = _max_y;
            }
            
            /* Propagate up to parent */
            _curr = _curr.parent;
        }
    };

    /* section toggle helper */
    var _wire_section_toggle = function(_btn_name, _content_name, _section_key, _ui_refresh_layout)
    {
        var _btn = ui_get(global.create_world_ui, _btn_name);
        
        if (_btn == undefined) exit;
        
        _btn.add_event_handler("on_select_release", method(
            { btn_name: _btn_name, content_name: _content_name, section_key: _section_key, refresh: _ui_refresh_layout },
            function()
            {
                var _sections = global.create_world_sections;
                
                _sections[$ section_key] = !_sections[$ section_key];
                
                var _open = _sections[$ section_key];
                var _content = ui_get(global.create_world_ui, content_name);
                
                if (_content != undefined)
                {
                    _content.visible = _open;
                }
                
                var _btn = ui_get(global.create_world_ui, btn_name);
                
                if (_btn != undefined)
                {
                    var _label = string_replace(btn_name, "_toggle", "");
                    _label = string_replace_all(_label, "_", " ");
                    
                    _btn.text = _open ? $"v {_label}" : $"> {_label}";
                }
                
                /* Reflow layout starting from the content's parent */
                if (_content != undefined)
                {
                    refresh(_content.parent);
                }
            }
        ));
    };
    
    _wire_section_toggle("death_penalty_toggle", "death_penalty_content", "death_penalty", _ui_refresh_layout);
    _wire_section_toggle("advanced_toggle", "advanced_content", "advanced", _ui_refresh_layout);
    _wire_section_toggle("backup_toggle", "backup_content", "backup", _ui_refresh_layout);
    _wire_section_toggle("game_rules_toggle", "game_rules_content", "game_rules", _ui_refresh_layout);
    _wire_section_toggle("item_drops_toggle", "item_drops_content", "item_drops", _ui_refresh_layout);
    
    
    /* back button */
    var _back_btn = ui_get(global.create_world_ui, "back_btn");
    
    if (_back_btn != undefined)
    {
        _back_btn.add_event_handler("on_select_release", function()
        {
            menu_create_world_ui_close();
            menu_transition_goto(rm_Menu_Worlds);
        });
    }
    
    
    /* checkbox toggle helper */
    var _wire_checkbox = function(_btn_name, _toggle_key)
    {
        var _btn = ui_get(global.create_world_ui, _btn_name);
        
        if (_btn == undefined) exit;
        
        _btn.add_event_handler("on_select_release", method(
            { btn_name: _btn_name, toggle_key: _toggle_key },
            function()
            {
                var _toggles = global.create_world_toggles;
                
                _toggles[$ toggle_key] = !_toggles[$ toggle_key];
                
                var _on = _toggles[$ toggle_key];
                var _btn = ui_get(global.create_world_ui, btn_name);
                
                if (_btn != undefined)
                {
                    _btn.text = _on ? "[x]" : "[ ]";
                }
            }
        ));
    };
    
    _wire_checkbox("friendly_fire_btn", "friendly_fire");
    _wire_checkbox("entity_drops_btn", "entity_drops");
    _wire_checkbox("tile_drops_btn", "tile_drops");
    
    
    /* permission radio buttons */
    var _perm_names = ["perm_none", "perm_min", "perm_max"];
    
    for (var i = array_length(_perm_names) - 1; i >= 0; --i)
    {
        var _radio = ui_get(global.create_world_ui, _perm_names[i]);
        
        if (_radio == undefined) continue;
        
        _radio.add_event_handler("on_select", method(
            { perm_index: i, perm_names: _perm_names },
            function(_data)
            {
                global.create_world_permission = perm_index;
                
                /* deselect others */
                for (var j = array_length(perm_names) - 1; j >= 0; --j)
                {
                    if (j == perm_index) continue;
                    
                    var _other = ui_get(global.create_world_ui, perm_names[j]);
                    
                    if (_other != undefined)
                    {
                        _other.deselect();
                    }
                }
            }
        ));
    }
    
    
    /* randomize world name button */
    var _name_btn = ui_get(global.create_world_ui, "name_random_btn");
    
    if (_name_btn != undefined)
    {
        _name_btn.add_event_handler("on_select_release", function()
        {
            var _name_input = ui_get(global.create_world_ui, "name_input");
            
            if (_name_input == undefined) exit;
            
            var _new_name;
            
            do
            {
                _new_name = menu_textbox_randomize_world_name();
            }
            until (string(_new_name) != "undefined" && string_length(_new_name) <= 40);
            
            _name_input.set_value(_new_name);
        });
    }
    
    
    /* randomize seed button */
    var _seed_btn = ui_get(global.create_world_ui, "seed_random_btn");
    
    if (_seed_btn != undefined)
    {
        _seed_btn.add_event_handler("on_select_release", function()
        {
            var _seed_input = ui_get(global.create_world_ui, "seed_input");
            
            if (_seed_input == undefined) exit;
            
            _seed_input.set_value(string(irandom_range(-0x80000000, 0x7fffffff)));
        });
    }
    
    
    /* create world button */
    var _create_btn = ui_get(global.create_world_ui, "create_btn");
    
    if (_create_btn != undefined)
    {
        _create_btn.add_event_handler("on_select_release", function()
        {
            var _name_input = ui_get(global.create_world_ui, "name_input");
            var _seed_input = ui_get(global.create_world_ui, "seed_input");
            
            if (_name_input == undefined || _seed_input == undefined) exit;
            
            var _name = string_trim(_name_input.get_value());
            
            if (_name == "")
            {
                show_debug_message("[create world ui] empty name, cannot create world.");
                
                exit;
            }
            
            var _seed = _seed_input.get_value();
            
            /* parse seed: numeric strings become numbers, text becomes a hash */
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
            
            
            /* read difficulty slider */
            var _diff_slider = ui_get(global.create_world_ui, "difficulty_slider");
            var _difficulty = 1.0;
            
            if (_diff_slider != undefined)
            {
                /* 0x, 1x, 2x, 3x, 4x */
                _difficulty = _diff_slider.value;
            }
            
            
            /* read death penalty sliders */
            var _item_drop_slider = ui_get(global.create_world_ui, "item_drop_slider");
            var _item_durability_slider = ui_get(global.create_world_ui, "item_durability_slider");
            
            var _item_drop = (_item_drop_slider != undefined) ? _item_drop_slider.value : 100;
            var _item_durability = (_item_durability_slider != undefined) ? _item_durability_slider.value : 100;
            
            
            /* read backup sliders */
            var _backup_interval_slider = ui_get(global.create_world_ui, "backup_interval_slider");
            var _backup_slots_slider = ui_get(global.create_world_ui, "backup_slots_slider");
            
            var _backup_enabled = global.create_world_sections.backup;
            var _backup_interval = (_backup_interval_slider != undefined) ? _backup_interval_slider.value : 5;
            var _backup_slots = (_backup_slots_slider != undefined) ? _backup_slots_slider.value : 3;
            
            
            /* read game rules */
            var _advance_time_slider = ui_get(global.create_world_ui, "advance_time_slider");
            var _natural_regen_slider = ui_get(global.create_world_ui, "natural_regen_slider");
            
            var _advance_time = (_advance_time_slider != undefined) ? _advance_time_slider.value : 1;
            var _natural_regen = (_natural_regen_slider != undefined) ? _natural_regen_slider.value : 1.0;
            
            var _toggles = global.create_world_toggles;
            
            
            /* store into world save data */
            global.world_save_data.name = _name;
            global.world_save_data.seed = _seed;
            global.world_save_data.difficulty = _difficulty;
            
            global.world_save_data.death_penalty_item_drop = _item_drop;
            global.world_save_data.death_penalty_item_durability = _item_durability;
            
            global.world_save_data.backup_enabled = _backup_enabled;
            global.world_save_data.backup_interval = _backup_interval;
            global.world_save_data.backup_slots = _backup_slots;
            
            global.world_save_data.permissions = global.create_world_permission;
            
            global.world_save_data.advance_time = _advance_time;
            global.world_save_data.friendly_fire = _toggles.friendly_fire;
            global.world_save_data.entity_drops = _toggles.entity_drops;
            global.world_save_data.tile_drops = _toggles.tile_drops;
            global.world_save_data.natural_regeneration = _natural_regen;
            
            
            randomize();
            
            var _uuid = "";
            var _index = datetime_to_unix();
            
            do
            {
                _uuid = uuid_generate(_index++);
            }
            until (!directory_exists($"{PROGRAM_DIRECTORY_WORLDS}/{_uuid}"));
            
            global.world_save_data.uuid = _uuid;
            
            menu_create_world_ui_close();
            
            room_goto(rm_World);
        });
    }
    
    
    /* cancel button */
    var _cancel_btn = ui_get(global.create_world_ui, "cancel_btn");
    
    if (_cancel_btn != undefined)
    {
        _cancel_btn.add_event_handler("on_select_release", function()
        {
            menu_create_world_ui_close();
            menu_transition_goto(rm_Menu_Worlds);
        });
    }
    
    
    /* initialize name and seed with random values */
    var _name_input = ui_get(global.create_world_ui, "name_input");
    
    if (_name_input != undefined)
    {
        var _existing_name = global.world_save_data.name;
        
        if (_existing_name != "")
        {
            _name_input.set_value(_existing_name);
        }
        else
        {
            var _random_name;
            
            do
            {
                _random_name = menu_textbox_randomize_world_name();
            }
            until (string(_random_name) != "undefined" && string_length(_random_name) <= 40);
            
            _name_input.set_value(_random_name);
        }
    }
    
    var _seed_input = ui_get(global.create_world_ui, "seed_input");
    
    if (_seed_input != undefined)
    {
        var _existing_seed = global.world_save_data.seed;
        
        if (_existing_seed != "")
        {
            _seed_input.set_value(string(_existing_seed));
        }
        else
        {
            _seed_input.set_value(string(irandom_range(-0x80000000, 0x7fffffff)));
        }
    }
    
    /* Initial layout refresh */
    if (global.create_world_ui.root_elements != undefined && array_length(global.create_world_ui.root_elements) > 0)
    {
        _ui_refresh_layout(global.create_world_ui.root_elements[0]);
    }
    
    show_debug_message("[create world ui] opened successfully.");
}


function menu_create_world_ui_close()
{
    if (!variable_global_exists("create_world_ui") || global.create_world_ui == undefined)
    {
        exit;
    }
    
    ui_destroy(global.create_world_ui);
    
    global.create_world_ui = undefined;
    
    if (variable_global_exists("create_world_sections"))
    {
        global.create_world_sections = undefined;
    }
    
    if (variable_global_exists("create_world_toggles"))
    {
        global.create_world_toggles = undefined;
    }
    
    show_debug_message("[create world ui] closed.");
}


function menu_create_world_ui_update()
{
    if (!variable_global_exists("create_world_ui") || global.create_world_ui == undefined)
    {
        exit;
    }
    
    ui_update(global.create_world_ui);
}


function menu_create_world_ui_draw()
{
    if (!variable_global_exists("create_world_ui") || global.create_world_ui == undefined)
    {
        exit;
    }
    
    ui_draw(global.create_world_ui);
}
