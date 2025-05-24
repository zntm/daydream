global.rarity_data = {}

function init_rarity(_directory, _namespace = "phantasia", _type = 0)
{
    if (!file_exists(_directory)) exit;
    
    var _data = buffer_load_json(_directory);
    
    var _names  = struct_get_names(_data);
    var _length = array_length(_names);
    
    for (var i = 0; i < _length; ++i)
    {
        var _name  = _names[i];
        var _name2 = $"{_namespace}:{_name}";
        
        global.rarity_data[$ _name2] = hex_parse(_data[$ _name]);
    }
}