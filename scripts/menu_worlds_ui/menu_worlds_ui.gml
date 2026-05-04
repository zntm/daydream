global.ui_worlds_menu = undefined;


function menu_worlds_ui_load()
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
    ui_invalidate_definition("ui/menu/worlds.ui");

    var _def = ui_load("ui/menu/worlds.ui");

    if (_def == undefined)
    {
        PRINT("[Menu Worlds] failed to load ui/menu/worlds.ui");
        exit;
    }

    var _instance = ui_spawn(_def, {
        link: {},
        parent: global.gui_root
    });

    global.ui_worlds_menu = _instance;
    global.worlds_view_mode = global.menu_preferences.worlds_view_mode ?? "grid";

    menu_worlds_ui_init();
}


function menu_worlds_ui_init()
{
    var _instance = global.ui_worlds_menu;
    var _elements = _instance.elements;

    var _title = _elements[$ "title"];
    if (_title != undefined)
    {
        _title.text = menu_ui_localize_or_default("phantasia:menu.worlds.title", "Worlds");
    }

    var _label_pinned = _elements[$ "label_pinned"];
    if (_label_pinned != undefined) _label_pinned.text = "Pinned";

    var _label_all = _elements[$ "label_all"];
    if (_label_all != undefined) _label_all.text = "All Worlds";

    /* back button */
    var _btn_back = _elements[$ "btn_back"];
    if (_btn_back != undefined)
    {
        _btn_back.text = menu_ui_localize_or_default("phantasia:menu.generic.back", "Back");
        _btn_back.add_event_handler("on_select_release", function() {
            menu_transition_goto(rm_Menu_Players);
        });
    }

    /* create world button */
    var _btn_create_world = _elements[$ "btn_create_world"];
    if (_btn_create_world != undefined)
    {
        _btn_create_world.text = menu_ui_localize_or_default("phantasia:menu.worlds.create", "Create World");
        _btn_create_world.add_event_handler("on_select_release", function() {
            menu_refresh_value_world_save();
            menu_transition_goto(rm_Menu_Create_World);
        });
    }

    /* grid/list view toggle */
    menu_worlds_ui_configure_view_button(_elements[$ "btn_view_grid"], "grid", "phantasia:ui/view_grid");
    menu_worlds_ui_configure_view_button(_elements[$ "btn_view_list"], "list", "phantasia:ui/view_list");
    menu_worlds_ui_refresh_view_buttons();
    
    menu_worlds_ui_set_loading_state();

    call_later(1, time_source_units_frames, function() {
        var _directory_listing = file_read_directory(PROGRAM_DIRECTORY_WORLDS);
        var _known_listing = global.file_worlds_uuid;

        if (!array_equals(_directory_listing, _known_listing))
        {
            file_load_worlds();
        }

        menu_worlds_ui_populate();
    });
}


function menu_worlds_ui_configure_view_button(_button, _mode, _asset_key)
{
    if (_button == undefined) exit;

    _button.text = "";
    _button.view_mode = _mode;
    _button.icon_asset_key = _asset_key;
    _button.on_draw = method(_button, function(_x, _y, _xscale, _yscale) {
        var _alpha = global.menu_transition_alpha ?? 1;
        var _cx = _x + (self.width * _xscale * 0.5);
        var _cy = _y + (self.height * _yscale * 0.5);
        var _scale = ((self.boolean & MENU_BUTTON_BOOL.IS_HOVER) != 0) ? 2.15 : 2.0;

        menu_ui_draw_icon(self.icon_asset_key, _cx, _cy, _alpha, _scale);
    });

    _button.add_event_handler("on_select_release", method(_button, function() {
        if (global.worlds_view_mode == self.view_mode) exit;

        global.worlds_view_mode = self.view_mode;
        global.menu_preferences.worlds_view_mode = self.view_mode;

        file_save_menu_preferences();
        menu_worlds_ui_refresh_view_buttons();
        menu_worlds_ui_populate();
    }));
}


function menu_worlds_ui_refresh_view_buttons()
{
    var _instance = global.ui_worlds_menu;
    if (_instance == undefined) exit;

    var _btn_grid = ui_get(_instance, "btn_view_grid");
    if (_btn_grid != undefined)
    {
        _btn_grid.sprite_index = (global.worlds_view_mode == "grid") ? spr_Menu_Button_Secondary : spr_Menu_Button_Main;
    }

    var _btn_list = ui_get(_instance, "btn_view_list");
    if (_btn_list != undefined)
    {
        _btn_list.sprite_index = (global.worlds_view_mode == "list") ? spr_Menu_Button_Secondary : spr_Menu_Button_Main;
    }
}


function menu_worlds_ui_set_loading_state()
{
    var _instance = global.ui_worlds_menu;
    if (_instance == undefined) exit;

    var _pinned = ui_get(_instance, "pinned_container");
    if (_pinned != undefined)
    {
        _pinned.clear_children();

        var _hint = new UIText(0, 20, "Loading pinned worlds...");
        _hint.halign = fa_left;
        _hint.valign = fa_middle;
        _hint.text_scale = 0.7;
        _hint.colour = menu_ui_get_metrics().text_dim;
        _pinned.add_child(_hint);
    }

    var _container = ui_get(_instance, "worlds_container");
    if (_container != undefined)
    {
        _container.clear_children();

        var _loading = new UIText(0, 12, "Loading worlds...");
        _loading.halign = fa_left;
        _loading.valign = fa_top;
        _loading.text_scale = 0.8;
        _loading.colour = menu_ui_get_metrics().text_dim;
        _container.add_child(_loading);
    }
}


function menu_worlds_ui_populate()
{
    var _instance = global.ui_worlds_menu;
    if (_instance == undefined) exit;

    var _pinned_container = ui_get(_instance, "pinned_container");
    var _main_container = ui_get(_instance, "worlds_container");

    if (_pinned_container == undefined || _main_container == undefined) exit;

    _pinned_container.clear_children();
    _main_container.clear_children();

    var _worlds = global.file_worlds;
    var _worlds_len = array_length(_worlds);
    var _pinned = [];
    var _ordered = [];

    for (var i = 0; i < _worlds_len; ++i)
    {
        var _world = _worlds[i];
        if (_world[$ "pinned"] == true)
        {
            array_push(_pinned, _world);
        }
    }

    for (var i = 0; i < array_length(_pinned); ++i)
    {
        array_push(_ordered, _pinned[i]);
    }

    for (var i = 0; i < _worlds_len; ++i)
    {
        var _world = _worlds[i];
        if (_world[$ "pinned"] != true)
        {
            array_push(_ordered, _world);
        }
    }

    menu_worlds_ui_refresh_view_buttons();
    menu_worlds_ui_build_pinned_strip(_pinned_container, _pinned, _instance);
    menu_worlds_ui_build_cards(_main_container, _ordered, (global.worlds_view_mode == "grid"), _instance, ui_layout_resolve_scalar(_main_container.width, 0));
}


function menu_worlds_ui_build_pinned_strip(_container, _worlds, _instance)
{
    var _metrics = menu_ui_get_metrics();
    var _len = array_length(_worlds);

    if (_len <= 0)
    {
        var _empty = new UIText(0, 20, "Pin worlds here for quick access.");
        _empty.halign = fa_left;
        _empty.valign = fa_middle;
        _empty.text_scale = 0.7;
        _empty.colour = _metrics.text_dim;
        _container.add_child(_empty);
        _container.height = 66;
        exit;
    }

    var _card_w = 260;
    var _card_h = 70;
    var _gap = _metrics.card_gap;
    var _container_width = ui_layout_resolve_scalar(_container.width, 0);

    for (var i = 0; i < _len; ++i)
    {
        var _x = i * (_card_w + _gap);
        menu_worlds_ui_create_card(_container, _worlds[i], _x, 0, _card_w, _card_h, "pinned", _instance);
    }

    _container.width = max(_container_width, (_len * (_card_w + _gap)) - _gap);
    _container.height = _card_h;
}


function menu_worlds_ui_build_cards(_container, _worlds, _is_grid, _instance, _container_width)
{
    var _metrics = menu_ui_get_metrics();
    var _len = array_length(_worlds);

    if (_len <= 0)
    {
        var _empty = new UIText(0, 12, "No worlds found.");
        _empty.halign = fa_left;
        _empty.valign = fa_top;
        _empty.text_scale = 0.8;
        _empty.colour = _metrics.text_dim;
        _container.add_child(_empty);
        _container.height = 48;
        exit;
    }

    var _gap = _metrics.card_gap;
    var _card_w = _is_grid ? 212 : _container_width;
    var _card_h = _is_grid ? 138 : 86;
    var _columns = max(1, floor((_container_width + _gap) / (_card_w + _gap)));
    var _total_width = (_columns * _card_w) + ((_columns - 1) * _gap);
    var _start_x = _is_grid ? floor(max(0, (_container_width - _total_width) * 0.5)) : 0;
    var _bottom = 0;

    for (var i = 0; i < _len; ++i)
    {
        var _x;
        var _y;

        if (_is_grid)
        {
            _x = _start_x + ((i mod _columns) * (_card_w + _gap));
            _y = floor(i / _columns) * (_card_h + _gap);
        }
        else
        {
            _x = 0;
            _y = i * (_card_h + 8);
        }

        menu_worlds_ui_create_card(_container, _worlds[i], _x, _y, _card_w, _card_h, (_is_grid ? "grid" : "list"), _instance);
        _bottom = max(_bottom, _y + _card_h);
    }

    _container.height = _bottom;
}


function menu_worlds_ui_create_card(_container, _world, _x, _y, _w, _h, _layout, _instance)
{
    var _entry = new UIButton(_x, _y, _w, _h, "");
    _container.add_child(_entry);
    _entry.link_context = _instance.link_context;
    _entry.world_ref = _world;
    _entry.card_layout = _layout;
    _entry.on_draw = method(_entry, function(_x1, _y1, _xscale, _yscale) {
        menu_worlds_ui_draw_card(self, _x1, _y1, _xscale, _yscale);
    });

    menu_worlds_ui_attach_card_actions(_entry, _world);

    _entry.add_event_handler("on_select_release", method(_entry, function() {
        if (global.ui_input_consumed) exit;

        var _data = self.world_ref;
        var _uuid = _data.get_uuid();

        if (!directory_exists(PROGRAM_DIRECTORY_WORLDS + "\\" + _uuid))
        {
            PRINT("World folder not found: " + string(_uuid));
            exit;
        }

        global.current_world.name = _data.get_name();
        global.current_world.seed = _data.get_seed();
        global.current_world.dimension = _data.get_dimension();
        global.current_world.time = _data.get_time();
        global.current_world.day = _data.get_day();
        global.current_world.weather.wind = _data.get_weather_wind();
        global.current_world.weather.storm = _data.get_weather_storm();
        global.current_world.uuid = _uuid;
        global.current_world.difficulty = _data.get_difficulty();

        var _backup = _data.get_backup();
        global.current_world.backup.interval_minutes = _backup.interval_minutes;
        global.current_world.backup.slots = _backup.slots;
        global.current_world.enabled_mods = _data.get_enabled_mods();

        global.world_statistics = _data.get_statistics() ?? {}

        menu_transition_goto(rm_World);
    }));

    return _entry;
}


function menu_worlds_ui_attach_card_actions(_entry, _world)
{
    var _metrics = menu_ui_get_metrics();
    var _icon = _metrics.icon_button;

    var _btn_pin = menu_worlds_ui_create_icon_button(_entry, 4, 4, _icon, _icon, function() {
        var _w = self.world_ref;
        var _uuid = _w.get_uuid();

        _w[$ "pinned"] = file_toggle_pinned_world(_uuid);
        menu_worlds_ui_populate();
        global.ui_input_consumed = true;
    });
    _btn_pin.world_ref = _world;
    _btn_pin.on_draw = method(_btn_pin, function(_x, _y, _xscale, _yscale) {
        var _alpha = global.menu_transition_alpha ?? 1;
        var _cx = _x + (self.width * _xscale * 0.5);
        var _cy = _y + (self.height * _yscale * 0.5);
        var _key = (self.world_ref[$ "pinned"] == true) ? "phantasia:ui/pin_active" : "phantasia:ui/pin";
        menu_ui_draw_icon(_key, _cx, _cy, _alpha, 2);
    });

    var _btn_option = menu_worlds_ui_create_icon_button(_entry, _entry.width - _icon - 4, 4, _icon, _icon, function() {
        PRINT("World options: " + string(self.world_ref.get_name()));
        global.ui_input_consumed = true;
    });
    _btn_option.world_ref = _world;
    _btn_option.on_draw = method(_btn_option, function(_x, _y, _xscale, _yscale) {
        var _alpha = global.menu_transition_alpha ?? 1;
        var _cx = _x + (self.width * _xscale * 0.5);
        var _cy = _y + (self.height * _yscale * 0.5);
        menu_ui_draw_icon("phantasia:ui/option", _cx, _cy, _alpha, 2);
    });

    _entry.add_child(_btn_pin);
    _entry.add_child(_btn_option);
}


function menu_worlds_ui_create_icon_button(_parent, _x, _y, _w, _h, _handler)
{
    var _button = new UIButton(_x, _y, _w, _h, "");
    _button.boolean = 0;
    _parent.add_child(_button);
    _button.add_event_handler("on_select_release", method(_button, _handler));

    return _button;
}


function menu_worlds_ui_draw_card(_self, _x, _y, _xscale, _yscale)
{
    var _metrics = menu_ui_get_metrics();
    var _data = _self.world_ref;
    var _layout = _self.card_layout;
    var _w = _self.width * _xscale;
    var _h = _self.height * _yscale;
    var _hovered = ((_self.boolean & MENU_BUTTON_BOOL.IS_HOVER) != 0);
    var _alpha = global.menu_transition_alpha ?? 1;
    var _halign = draw_get_halign();
    var _valign = draw_get_valign();

    draw_set_alpha(_alpha);
    menu_ui_draw_panel(_x, _y, _w, _h, _hovered, false);
    draw_set_alpha(1);

    draw_set_align(fa_left, fa_top);

    switch (_layout)
    {
        case "pinned":
            menu_worlds_ui_draw_thumbnail(_x + 10, _y + 10, 72, _h - 20, _data, _alpha);
            render_text(_x + 92, _y + 12, menu_ui_trim_text(_data.get_name(), 18), 0.82, 0.82, 0, c_white, _alpha);
            render_text(_x + 92, _y + 32, date_datetime_string(_data.get_last_opened()), 0.58, 0.58, 0, _metrics.text_muted, _alpha);
            render_text(_x + 92, _y + 48, file_format_size(_data.get_size()), 0.55, 0.55, 0, _metrics.text_dim, _alpha);
            break;

        case "list":
            menu_worlds_ui_draw_thumbnail(_x + 12, _y + 12, 88, _h - 24, _data, _alpha);
            render_text(_x + 114, _y + 14, menu_ui_trim_text(_data.get_name(), 28), 0.92, 0.92, 0, c_white, _alpha);
            render_text(_x + 114, _y + 36, date_datetime_string(_data.get_last_opened()), 0.65, 0.65, 0, _metrics.text_muted, _alpha);
            render_text(_x + 114, _y + 56, file_format_size(_data.get_size()), 0.6, 0.6, 0, _metrics.text_dim, _alpha);
            break;

        default:
            menu_worlds_ui_draw_thumbnail(_x + 14, _y + 14, _w - 28, 70, _data, _alpha);
            draw_set_align(fa_center, fa_top);
            render_text(_x + (_w * 0.5), _y + 92, menu_ui_trim_text(_data.get_name(), 18), 0.86, 0.86, 0, c_white, _alpha);
            render_text(_x + (_w * 0.5), _y + 112, date_datetime_string(_data.get_last_opened()), 0.58, 0.58, 0, _metrics.text_muted, _alpha);
            break;
    }

    draw_set_align(_halign, _valign);
}


function menu_worlds_ui_draw_thumbnail(_x, _y, _w, _h, _world, _alpha)
{
    var _metrics = menu_ui_get_metrics();
    var _seed = abs(_world.get_seed());
    var _steps = 6;

    draw_set_alpha(_alpha * 0.18);
    draw_rectangle_colour(_x, _y, _x + _w, _y + _h, _metrics.placeholder_fill, _metrics.placeholder_fill, _metrics.placeholder_fill, _metrics.placeholder_fill, false);
    draw_set_alpha(_alpha * 0.32);
    
    for (var i = 0; i < _steps; ++i)
    {
        var _slice_w = _w / _steps;
        var _height_ratio = ((round(_seed / max(1, i + 3)) mod 7) + 2) / 10;
        var _hill_h = floor(_h * _height_ratio);
        var _x1 = _x + (_slice_w * i);
        var _x2 = _x1 + _slice_w + 1;
        
        draw_rectangle_colour(_x1, _y + _h - _hill_h, _x2, _y + _h, c_white, c_white, c_white, c_white, false);
    }
    
    draw_set_alpha(_alpha);
    draw_rectangle_colour(_x, _y, _x + _w, _y + _h, _metrics.card_border, _metrics.card_border, _metrics.card_border, _metrics.card_border, true);
    draw_set_alpha(1);
}
