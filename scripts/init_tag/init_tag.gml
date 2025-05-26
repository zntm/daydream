global.tag_data = {}

function init_tag(_directory, _namespace = "phantasia", _type = 0)
{
    if (!file_exists(_directory)) exit;
    
    var _data = buffer_load_json(_directory);
    
    var _names  = struct_get_names(_data);
    var _length = array_length(_names);
    
    for (var i = 0; i < _length; ++i)
    {
        var _name = _names[i];
        
        global.tag_data[$ $"#{_namespace}:{_name}"] = _data[$ _name];
    }
}