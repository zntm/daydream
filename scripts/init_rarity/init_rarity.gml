global.rarity_data = {}

function init_rarity(_directory, _namespace = "phantasia", _type = 0)
{
    var _data = buffer_load_json(_directory);
    
    var _names  = struct_get_names(_data);
    var _length = array_length(_names);
    
    for (var i = 0; i < _length; ++i)
    {
        var _name = _names[i];
        
        global.rarity_data[$ $"{_namespace}:{_name}"] = hex_parse(_data[$ _name]);
    }
}