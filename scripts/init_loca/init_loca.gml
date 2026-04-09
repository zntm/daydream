global.loca_font = fnt_Default;
global.loca_font_scale = 0.38;

global.loca_data = {}

init_loca_effect();

function init_loca(_namespace, _directory, _clear_existing = true)
{
    if (_clear_existing) && (global.loca_font != fnt_Default)
    {
        font_delete(global.loca_font);
    }

    if (_clear_existing)
    {
        var _names  = struct_get_names(global.loca_data);
        var _length = array_length(_names);

        for (var i = _length - 1; i >= 0; --i)
        {
            var _name = _names[i];

            if (_name != "name") && (_name != "locale_code")
            {
                struct_remove(global.loca_data, _name);
            }
        }
    }

    if (file_exists($"{_directory}/font.ttf"))
    {
        if (!_clear_existing) && (global.loca_font != fnt_Default)
        {
            font_delete(global.loca_font);
        }

        var _data = json_parse(buffer_load_text($"{_directory}/font.json"));

        global.loca_font = font_add($"{_directory}/font.ttf", _data.size, false, false, _data.first, _data.last);
        global.loca_font_scale = _data.scale;

        font_enable_sdf(global.loca_font, true);
    }
    else if (file_exists($"{_directory}/font.otf"))
    {
        if (!_clear_existing) && (global.loca_font != fnt_Default)
        {
            font_delete(global.loca_font);
        }

        var _data = json_parse(buffer_load_text($"{_directory}/font.json"));

        global.loca_font = font_add($"{_directory}/font.otf", _data.size, false, false, _data.first, _data.last);
        global.loca_font_scale = _data.scale;

        font_enable_sdf(global.loca_font, true);
    }
    else
    {
        if (_clear_existing)
        {
            global.loca_font = fnt_Default;
            global.loca_font_scale = 0.38;
        }
    }

    var _json = buffer_load_json($"{_directory}/data.json");

    if (is_struct(_json))
    {
        var _names2  = struct_get_names(_json);
        var _length2 = array_length(_names2);

        for (var i = _length2 - 1; i >= 0; --i)
        {
            var _name = _names2[i];

            if (_name != "name") && (_name != "locale_code")
            {
                global.loca_data[$ $"{_namespace}:{_name}"] = _json[$ _name];
            }
            else
            {
                global.loca_data[$ _name] = _json[$ _name];
            }
        }

        delete _json;
    }

    draw_set_font(global.loca_font);

    init_loca_effect();
}
