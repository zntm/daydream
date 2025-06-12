function init_sfx(_directory, _namespace)
{
    init_sfx_asset($"{_directory}/asset", _namespace);
    
    var _json = init_tag_value(buffer_load_json($"{_directory}/data.json"));
    
    var _names  = struct_get_names(_json);
    var _length = array_length(_names);
    
    for (var i = 0; i < _length; ++i)
    {
        var _name = _names[i];
        var _data = _json[$ _name];
        
        global.sfx_data[$ $"{_namespace}:{_name}"] = new SFXData()
            .set_asset(_data.asset)
            .set_falloff(_data.falloff)
            .set_subtitle(_data[$ "subtitle"]);
    }
    
    delete _json;
}