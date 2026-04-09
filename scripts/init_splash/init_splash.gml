function init_splash(_directory)
{
    global.menu_data[$ "splash_texts"] ??= {}

    var _json = buffer_load_json(_directory);

    if (!is_struct(_json)) exit;

    struct_foreach(_json, function(_name, _value)
    {
        global.menu_data.splash_texts[$ _name] = _value;
    });

    delete _json;
}
