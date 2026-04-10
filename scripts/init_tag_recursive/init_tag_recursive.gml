global.tag_data = {}

function init_tag_recursive(_namespace, _directory)
{
    var _files = file_read_directory(_directory, true);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];

        if (directory_exists($"{_directory}/{_file}")) continue;
        
        if (string_ends_with(_file, ".json"))
        {
            dbg_timer("init_tag");
            
            var _id2 = string_delete(_file, string_length(_file) - 4, 5);
            
            var _json = buffer_load_json($"{_directory}/{_file}");
            if (!init_data_namespace_allowed(_json, _file)) continue;
            
            var _names  = struct_get_names(_json);
            var _length = array_length(_names);
            
            for (var j = 0; j < _length; ++j)
            {
                var _name2 = _names[j];
                
                global.tag_data[$ $"#{_namespace}:{_id2}/{_name2}"] = _json[$ _name2];
            }
            
            delete _json;
            
            dbg_timer("init_tag", $"[Init] Loaded Tag: \'{_id2}\'");
        }
    }
    
    global.tag_data = tag_value_parse(global.tag_data);
}
