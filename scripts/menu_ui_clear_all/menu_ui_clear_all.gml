function menu_ui_clear_all()
{
	/* Destroy all registered UI instances */
    if (variable_global_exists("ui_instances"))
    {
        var _keys = struct_get_names(global.ui_instances);
        for (var i = array_length(_keys) - 1; i >= 0; --i)
        {
            ui_instance_destroy(global.ui_instances[$ _keys[i]]);
        }
    }
    
	/* Explicitly clear gui_root children just in case */
    if (variable_global_exists("gui_root") && global.gui_root != undefined)
    {
        global.gui_root.clear_children();
    }

	if (variable_global_exists("ui_settings_menu")) global.ui_settings_menu = undefined;
	if (variable_global_exists("ui_settings_rebind")) global.ui_settings_rebind = undefined;
	if (variable_global_exists("ui_player_statistics_popup")) global.ui_player_statistics_popup = undefined;
	if (variable_global_exists("ui_warning_screen")) global.ui_warning_screen = undefined;
}


function menu_ui_get_metrics()
{
    static __metrics = {
        safe: 16,
        panel_gap: 12,
        panel_pad: 12,
        section_gap: 10,
        card_gap: 12,
        icon_button: 20,
        card_background: #1e1e2e,
        card_background_alt: #25253a,
        card_border: #3a3a4a,
        card_border_hover: #6a6a8a,
        card_shadow: c_black,
        text_muted: #aaaaaa,
        text_dim: c_ltgray,
        placeholder_fill: c_dkgray
    }

    return __metrics;
}


function menu_ui_trim_text(_text, _max_characters)
{
    var _value = string(_text ?? "");

    if (_max_characters <= 0) return "";

    if (string_length(_value) <= _max_characters)
    {
        return _value;
    }

    return string_copy(_value, 1, max(1, _max_characters - 3)) + "...";
}


function menu_ui_localize_or_default(_key, _fallback)
{
    var _value = loca_translate(_key);

    if (_value == undefined)
    {
        return _fallback;
    }

    _value = string(_value);

    if (_value == "" || _value == _key)
    {
        return _fallback;
    }

    return _value;
}


function menu_ui_draw_panel(_x, _y, _w, _h, _hovered = false, _accent = false)
{
    var _metrics = menu_ui_get_metrics();
    var _border = _accent ? _metrics.card_border_hover : _metrics.card_border;
    var _fill = _hovered ? _metrics.card_background_alt : _metrics.card_background;

    draw_set_alpha(0.28);
    draw_rectangle_colour(_x + 2, _y + 2, _x + _w + 2, _y + _h + 2, _metrics.card_shadow, _metrics.card_shadow, _metrics.card_shadow, _metrics.card_shadow, false);

    draw_set_alpha(0.92);
    draw_rectangle_colour(_x, _y, _x + _w, _y + _h, _fill, _fill, _fill, _fill, false);

    draw_set_alpha(1);
    draw_rectangle_colour(_x, _y, _x + _w, _y + _h, _border, _border, _border, _border, true);
    draw_rectangle_colour(_x + 3, _y + 3, _x + _w - 3, _y + _h - 3, _border, _border, _border, _border, true);
}


function menu_ui_draw_icon(_asset_key, _cx, _cy, _alpha = 1, _scale = 2, _colour = c_white)
{
    var _asset = global.sprite_asset[$ _asset_key];

    if (_asset == undefined) exit;

    draw_sprite_ext(_asset.get_sprite(), 0, _cx, _cy, _scale, _scale, 0, _colour, _alpha);
}


function menu_ui_format_option_label(_value)
{
    switch (_value)
    {
        case SETTINGS_LEVEL.NONE: return "None";
        case SETTINGS_LEVEL.MIN:  return "Minimal";
        case SETTINGS_LEVEL.MAX:  return "Full";
    }

    if (is_string(_value))
    {
        return _value;
    }

    return string(_value);
}
