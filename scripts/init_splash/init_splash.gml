global.splash_data = {}

function init_splash(_directory)
{
    static __clear = function(_name, _value)
    {
        struct_remove(global.splash_data, _name);
    }
    
    static __init = function(_name, _value)
    {
        global.splash_data[$ _name] = _value;
    }
    
    struct_foreach(global.splash_data, __clear);
    
    var _json = buffer_load_json(_directory);
    
    struct_foreach(_json, __init);
    
    delete _json;
}