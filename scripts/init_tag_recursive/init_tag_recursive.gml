global.tag_data = {}

function init_tag_recursive(_directory, _namespace, _id)
{
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        var _subdirectory = $"{_directory}/{_file}";
        
        var _name = ((_id == undefined) ? _file : $"{_id}/{_file}");
        
        if (directory_exists(_subdirectory))
        {
            init_tag_recursive(_subdirectory, _namespace, _name);
            
            continue;
        }
        
        if (string_ends_with(_subdirectory, ".json"))
        {
            dbg_timer("init_tag");
            
            var _id2 = string_delete($"{_name}", string_length($"{_name}") - 4, 5);
            
            var _json = buffer_load_json(_subdirectory);
            
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
    
    global.tag_data = init_tag_value(global.tag_data);
}