global.region_data = {}

function init_region_recursive(_directory, _namespace = "phantasia", _id = undefined)
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
            init_region_recursive(_subdirectory, _namespace, _name);
            
            continue;
        }
        
        dbg_timer("init_region");
        
        var _json = tag_value_parse(buffer_load_json(_subdirectory));
        
        var _id2 = string_delete(_file, string_length(_file) - 4, 5);
        var _full_name = (_id == undefined) ? _id2 : $"{_id}/{_id2}";
        
        var _region_data = new RegionData(_full_name, _json);
        
        global.region_data[$ $"{_namespace}:{_full_name}"] = _region_data;
        
        delete _json;
        
        dbg_timer("init_region", $"[Init] Loaded Region: \'{_full_name}\'");
    }
}
