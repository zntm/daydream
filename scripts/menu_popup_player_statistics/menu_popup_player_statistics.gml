global.ui_player_statistics_popup = undefined;


function menu_popup_player_statistics(_data)
{
    menu_popup_player_statistics_close();

    ui_invalidate_definition("ui/menu/player_statistics.ui");

    var _def = ui_load("ui/menu/player_statistics.ui");

    if (_def == undefined) exit;

    var _instance = ui_spawn(_def, {
        link: {},
        parent: global.gui_root
    });

    global.ui_player_statistics_popup = _instance;

    var _title = ui_get(_instance, "label_title");
    var _btn_back = ui_get(_instance, "btn_back");
    var _list = ui_get(_instance, "stats_list");
    var _scroll = ui_get(_instance, "stats_scroll");

    if (_title != undefined)
    {
        _title.text = $"Statistics: {_data.get_name()}";
    }

    if (_btn_back != undefined)
    {
        _btn_back.text = "< Back";
        _btn_back.add_event_handler("on_select_release", function() {
            menu_popup_player_statistics_close();
        });
    }

    if (_list == undefined) exit;

    if (_scroll != undefined)
    {
        _scroll.scroll_offset = 0;
    }

    var _stats = _data.get_statistics() ?? {}
    var _categories = ["general", "blocks", "items", "mobs"];
    var _total_height = 0;
    var _list_width = _list.width;
    var _center_x = _list_width / 2;
    var _row_width = _list_width - 24;

    for (var c = 0; c < array_length(_categories); ++c)
    {
        var _category = _categories[c];
        var _entries = statistics_get_list(_stats, _category);

        if (array_length(_entries) == 0) continue;

        var _header = new UIText(_center_x, 0, menu_popup_player_statistics_get_category_label(_category));
        _header.text_scale = 1.05;
        _header.colour = c_yellow;
        _list.add_child(_header);
        _total_height += 24;

        for (var i = 0; i < array_length(_entries); ++i)
        {
            var _entry = _entries[i];
            var _row = new UIArea(0, 0, _row_width, 36);

            var _name = new UIText(0, 18, _entry.name);
            _name.halign = fa_left;
            _row.add_child(_name);

            var _value = new UIText(_row_width, 18, _entry.value);
            _value.halign = fa_right;
            _value.colour = c_ltgray;
            _row.add_child(_value);

            _list.add_child(_row);
            _total_height += 44;
        }
    }

    if (_total_height <= 0)
    {
        var _empty = new UIText(_center_x, 18, "No statistics yet.");
        _empty.colour = c_ltgray;
        _list.add_child(_empty);
        _total_height = 36;
    }

    _list.height = _total_height;
}


function menu_popup_player_statistics_close()
{
    if (global.ui_player_statistics_popup != undefined)
    {
        ui_destroy(global.ui_player_statistics_popup);
        global.ui_player_statistics_popup = undefined;
    }
}


function menu_popup_player_statistics_get_category_label(_category)
{
    var _label = loca_translate($"phantasia:statistics.category.{_category}");

    if (_label == $"phantasia:statistics.category.{_category}")
    {
        _label = string_upper(string_char_at(_category, 1)) + string_copy(_category, 2, string_length(_category) - 1);
    }

    return _label;
}
