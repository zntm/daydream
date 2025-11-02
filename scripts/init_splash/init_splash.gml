function init_splash(_directory)
{
    global.menu_data[$ "splash_texts"] ??= {}
    
    struct_foreach(global.menu_data.splash_texts, function(_name, _value)
    {
        struct_remove(global.menu_data.splash_texts, _name);
    });
    
    var _json = buffer_load_json(_directory);
    
    struct_foreach(_json, function(_name, _value)
    {
        global.menu_data.splash_texts[$ _name] = _value;
    });
    
    delete _json;
}