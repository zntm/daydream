/// @desc Initialise all in-game declarative UI panels (hotbar, inventory, crafting, chat, choices, effects).
/// @param {Real} _logical_width  Logical design width in UI units.
/// @param {Real} _logical_height Logical design height in UI units.
function control_game_ui_init(_logical_width, _logical_height)
{
    control_game_ui_cleanup_existing();

    var _hotbar_def = ui_load("ui/hotbar.ui");

    global.ui_hotbar = ui_spawn(_hotbar_def, {
        link:   {},
        parent: global.gui_root
    }, ["inventory_changed"]);

    global.gui_panel_hotbar_modular = global.ui_hotbar;

    var _inventory_def = ui_load("ui/inventory.ui");

    global.ui_inventory = ui_spawn(_inventory_def, {
        link:   {},
        parent: global.gui_root
    }, ["inventory_changed"]);

    global.gui_panel_inventory_modular = global.ui_inventory;
    control_game_ui_set_instance_visible(global.ui_inventory, false);

    global.ui_crafting_def      = ui_load("ui/crafting.ui");
    global.ui_crafting_slot_def = ui_load("ui/crafting_slot.ui");

    global.ui_crafting = ui_spawn(global.ui_crafting_def, {
        link:   {},
        parent: global.gui_root
    });

    control_game_ui_set_instance_visible(global.ui_crafting, false);

    var _stat_bars_def = ui_load("ui/stat_bars.ui");

    global.ui_stat_bars = ui_spawn(_stat_bars_def, {
        link:   control_game_ui_create_stat_link(),
        parent: global.gui_root
    });

    var _chest_pull_btn = global.ui_crafting.elements[$ "btn_chest_pull"];

    if (_chest_pull_btn != undefined)
    {
        _chest_pull_btn.add_event_handler("on_select_release", function()
        {
            global.crafting_pull_from_chests = !global.crafting_pull_from_chests;
            self.text = "PULL FROM CHESTS is " + (global.crafting_pull_from_chests ? "ON" : "OFF");

            inventory_refresh_craftable();
        });
    }

    global.gui_panel_crafting_modular = global.ui_crafting.root_elements[0];

    global.gui_panel_chat = new GUIChatHistory(8, -8, 300, 128, 8);
    global.gui_panel_chat.offset_x = 8;
    global.gui_panel_chat.offset_y = -8;
    global.gui_panel_chat.set_anchor("left", "bottom");
    global.gui_root.add_child(global.gui_panel_chat);

    global.gui_panel_choices = new GUIChoicePanel(0, 0, 300);
    global.gui_panel_choices.offset_y = -50;
    global.gui_panel_choices.visible = false;
    global.gui_panel_choices.set_anchor("center", "middle");
    global.gui_root.add_child(global.gui_panel_choices);

    global.gui_panel_effects = new GUIEffectPanel(0, 0);
    global.gui_panel_effects.offset_x = -16;
    global.gui_panel_effects.offset_y = -16;
    global.gui_panel_effects.set_anchor("right", "bottom");
    global.gui_root.add_child(global.gui_panel_effects);
}


function control_game_ui_cleanup_existing()
{
    var _ui_keys = [
        "ui_hotbar",
        "ui_inventory",
        "ui_crafting",
        "ui_stat_bars"
    ];

    for (var i = array_length(_ui_keys) - 1; i >= 0; --i)
    {
        var _key = _ui_keys[i];

        if (variable_global_exists(_key))
        {
            var _instance = global[$ _key];

            if (_instance != undefined)
            {
                ui_instance_destroy(_instance);
            }

            global[$ _key] = undefined;
        }
    }

    var _panel_keys = [
        "gui_panel_chat",
        "gui_panel_choices",
        "gui_panel_effects"
    ];

    for (var j = array_length(_panel_keys) - 1; j >= 0; --j)
    {
        var _panel_key = _panel_keys[j];

        if (variable_global_exists(_panel_key))
        {
            var _panel = global[$ _panel_key];

            if ((_panel != undefined) && (global.gui_root != undefined) && struct_exists(global.gui_root, "remove_child"))
            {
                global.gui_root.remove_child(_panel);
            }

            global[$ _panel_key] = undefined;
        }
    }

    if (variable_global_exists("ui_crafting_slots"))
    {
        while (array_length(global.ui_crafting_slots) > 0)
        {
            var _slot_inst = array_pop(global.ui_crafting_slots);

            if (_slot_inst != undefined)
            {
                ui_instance_destroy(_slot_inst);
            }
        }
    }

    if (variable_global_exists("ui_inventory_container")) && (global.ui_inventory_container != undefined)
    {
        var _container = global.ui_inventory_container;

        if (struct_exists(_container, "parent") && (_container.parent != undefined))
        {
            _container.parent.remove_child(_container);
        }

        global.ui_inventory_container = undefined;
    }
}


function control_game_ui_set_instance_visible(_instance, _visible)
{
    if (_instance == undefined) exit;

    _instance.visible = _visible;

    if !(struct_exists(_instance, "root_elements")) exit;

    var _root_count = array_length(_instance.root_elements);

    for (var i = _root_count - 1; i >= 0; --i)
    {
        var _root = _instance.root_elements[i];

        if (_root != undefined)
        {
            _root.visible = _visible;
        }
    }
}


function control_game_ui_get_local_player()
{
    var _lp = noone;

    with (obj_Player)
    {
        if (is_local)
        {
            _lp = id;
            break;
        }
    }

    return _lp;
}


function control_game_ui_create_stat_link()
{
    return {
        hp_value: function()
        {
            var _lp = control_game_ui_get_local_player();
            return instance_exists(_lp) ? _lp.hp : 0;
        },
        hp_max: function()
        {
            var _lp = control_game_ui_get_local_player();
            return instance_exists(_lp) ? max(_lp.hp_max, 1) : 1;
        },
        stamina_value: function()
        {
            var _lp = control_game_ui_get_local_player();
            return instance_exists(_lp) ? _lp.stamina : 0;
        },
        stamina_max: function()
        {
            var _lp = control_game_ui_get_local_player();
            return instance_exists(_lp) ? max(_lp.stamina_max, 1) : 1;
        },
        breath_visible: function()
        {
            var _lp = control_game_ui_get_local_player();
            return instance_exists(_lp) && (_lp.breath < _lp.breath_max);
        },
        breath_value: function()
        {
            var _lp = control_game_ui_get_local_player();
            return instance_exists(_lp) ? _lp.breath : 0;
        },
        breath_max: function()
        {
            var _lp = control_game_ui_get_local_player();
            return instance_exists(_lp) ? max(_lp.breath_max, 1) : 1;
        },
        charge_visible: function()
        {
            var _lp = control_game_ui_get_local_player();
            return instance_exists(_lp) && ((_lp.charge_time ?? 0) > 0);
        },
        charge_value: function()
        {
            var _lp = control_game_ui_get_local_player();
            return instance_exists(_lp) ? (_lp.charge_time ?? 0) : 0;
        },
        charge_max: function()
        {
            var _lp = control_game_ui_get_local_player();
            return instance_exists(_lp) ? max((_lp.charge_threshold ?? 1), 0.001) : 1;
        }
    };
}


function control_game_ui_sync_visibility()
{
    var _is_open = obj_Game_Control.is_opened;

    var _generating = !!(_is_open & WORLD_OPENED_BOOL.GENERATING_WORLD);
    var _inventory  = !!(_is_open & WORLD_OPENED_BOOL.INVENTORY);
    var _gui        = !!(_is_open & WORLD_OPENED_BOOL.GUI);
    var _menu       = !!(_is_open & WORLD_OPENED_BOOL.MENU);
    var _chat       = !!(_is_open & WORLD_OPENED_BOOL.CHAT);

    if (global.ui_hotbar != undefined)
    {
        control_game_ui_set_instance_visible(
            global.ui_hotbar,
            !_generating && ((_gui && !_menu && !_chat) || (_inventory && !_chat))
        );
    }

    if (global.ui_inventory != undefined)
    {
        control_game_ui_set_instance_visible(global.ui_inventory, !_generating && _inventory && !_chat);
    }

    if (variable_global_exists("ui_crafting")) && (global.ui_crafting != undefined)
    {
        control_game_ui_set_instance_visible(global.ui_crafting, !_generating && _inventory && !_chat);
    }

    if (variable_global_exists("ui_stat_bars")) && (global.ui_stat_bars != undefined)
    {
        control_game_ui_set_instance_visible(global.ui_stat_bars, !_generating && _gui && !_menu && !_chat);
    }

    if (variable_global_exists("gui_panel_crafting_modular")) && (global.gui_panel_crafting_modular != undefined)
    {
        global.gui_panel_crafting_modular.visible = !_generating && _inventory && !_chat
            && (array_length(global.gui_panel_crafting_modular.children) > 0);
    }

    if (variable_global_exists("gui_panel_effects")) && (global.gui_panel_effects != undefined)
    {
        global.gui_panel_effects.visible = !_generating && _gui && !_menu && !_chat;
    }

    if (variable_global_exists("gui_panel_chat")) && (global.gui_panel_chat != undefined)
    {
        global.gui_panel_chat.visible = _gui && !_menu;
    }
}


function control_game_ui_update()
{
    control_game_ui_sync_visibility();

    global.ui_input_consumed = false;
    global.ui_hover_consumed = false;
    global.inventory_ui_hover = undefined;

    if (global.gui_root != undefined)
    {
        global.gui_root.update();
    }

    if (variable_global_exists("ui_instances"))
    {
        var _ui_keys  = struct_get_names(global.ui_instances);
        var _ui_count = array_length(_ui_keys);

        for (var i = _ui_count - 1; i >= 0; --i)
        {
            var _ui_inst = global.ui_instances[$ _ui_keys[i]];

            if ((_ui_inst != undefined) && !ui_instance_is_parented(_ui_inst))
            {
                ui_update(_ui_inst);
            }
        }
    }

    ui_clear_events();
}


function control_game_ui_draw()
{
    if (global.gui_root != undefined)
    {
        global.gui_root.draw();
    }

    if (variable_global_exists("ui_instances"))
    {
        var _ui_keys  = struct_get_names(global.ui_instances);
        var _ui_count = array_length(_ui_keys);

        for (var i = _ui_count - 1; i >= 0; --i)
        {
            var _ui_inst = global.ui_instances[$ _ui_keys[i]];

            if ((_ui_inst != undefined) && !ui_instance_is_parented(_ui_inst))
            {
                ui_draw(_ui_inst);
            }
        }
    }

    ui_draw_deferred_text();
}


function control_game_ui_draw_overlay()
{
    var _is_open = obj_Game_Control.is_opened;

    if !(_is_open & WORLD_OPENED_BOOL.GUI) exit;

    var _lp = control_game_ui_get_local_player();

    if (_lp == noone) exit;
    if (_lp.hp <= 0) exit;

    var _base_scale = ui_get_base_scale();

    if (_is_open & WORLD_OPENED_BOOL.INVENTORY)
    {
        var _target = gui_inventory_tooltip_resolve_target();

        if (_target != undefined) && !(_is_open & WORLD_OPENED_BOOL.CHAT)
        {
            if ((_target.slot_type ?? INVENTORY_SLOT_TYPE.BASE) != INVENTORY_SLOT_TYPE.CRAFTABLE)
            {
                gui_inventory_tooltip(_base_scale.x, _base_scale.y);

                var _tooltip = surface_inventory.tooltip;
                var _surface_tooltip = _tooltip.surface;

                if (surface_exists(_surface_tooltip))
                {
                    var _tooltip_x = (global.gui_mouse_x + GUI_TOOLTIP_XOFFSET) * _base_scale.x;
                    var _tooltip_total_height = (_tooltip.surface_height + (GUI_INVENTORY_TOOLTIP_BG_PADDING * 2)) * _base_scale.y;
                    var _tooltip_y = (global.gui_mouse_y * _base_scale.y) - _tooltip_total_height - (GUI_TOOLTIP_YOFFSET * _base_scale.y);

                    if (_tooltip_y < 0)
                    {
                        _tooltip_y = (global.gui_mouse_y + GUI_TOOLTIP_YOFFSET) * _base_scale.y;
                    }

                    draw_sprite_ext(
                        spr_Inventory_Tooltip,
                        0,
                        _tooltip_x - (GUI_INVENTORY_TOOLTIP_BG_PADDING * _base_scale.x),
                        _tooltip_y - (GUI_INVENTORY_TOOLTIP_BG_PADDING * _base_scale.y),
                        ((_tooltip.surface_width + GUI_INVENTORY_TOOLTIP_BG_PADDING) / 14) * _base_scale.x,
                        ((_tooltip.surface_height + GUI_INVENTORY_TOOLTIP_BG_PADDING) / 14) * _base_scale.y,
                        0,
                        c_white,
                        1
                    );

                    draw_surface(_surface_tooltip, _tooltip_x, _tooltip_y);
                }
            }
        }
    }

    if !(_is_open & WORLD_OPENED_BOOL.INVENTORY)
    {
        var _item = global.inventory.base[global.inventory_selected_hotbar];

        if (_item != INVENTORY_EMPTY)
        {
            var _data = global.item_data[$ _item.get_id()];

            if (_data != undefined)
            {
                var _root_width = global.gui_root.get_width();
                var _root_height = global.gui_root.get_height();

                ui_draw_text_stroked(
                    (_root_width / 2) * _base_scale.x,
                    (_root_height - (INVENTORY_SLOT_DIMENSION + 96)) * _base_scale.y,
                    loca_translate($"{_data.get_namespace()}:item.{_data.get_id()}.name"),
                    1.5 * _base_scale.x,
                    1.5 * _base_scale.y,
                    c_white,
                    1,
                    c_black,
                    0.9,
                    fa_center,
                    fa_bottom
                );
            }
        }
    }

    var _charge_time = _lp.charge_time ?? 0;
    var _charge_max = max(_lp.charge_threshold ?? 1, 0.001);

    if (_charge_time > 0)
    {
        var _camera = view_camera[0];
        var _camera_x = camera_get_view_x(_camera);
        var _camera_y = camera_get_view_y(_camera);
        var _bar_w = 48;
        var _bar_h = 3;
        var _bar_x = ((_lp.x - _camera_x) / _base_scale.x) - (_bar_w / 2);
        var _bar_y = ((_lp.y + 12 - _camera_y) / _base_scale.y);
        var _ratio = clamp(_charge_time / _charge_max, 0, 1);

        draw_sprite_ext(
            spr_Square,
            0,
            _bar_x * _base_scale.x,
            _bar_y * _base_scale.y,
            _bar_w * _base_scale.x,
            _bar_h * _base_scale.y,
            0,
            #1a1a1a,
            0.7
        );

        if (_ratio > 0)
        {
            draw_sprite_ext(
                spr_Square,
                0,
                _bar_x * _base_scale.x,
                _bar_y * _base_scale.y,
                (_bar_w * _ratio) * _base_scale.x,
                _bar_h * _base_scale.y,
                0,
                #676767,
                1
            );
        }
    }
}
