global.region_data = {}
global.region_list = []

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
        
        if (string_ends_with(_file, ".json"))
        {
            dbg_timer("init_region");
            
            var _json = tag_value_parse(buffer_load_json(_subdirectory));
            
            if (is_struct(_json))
            {
                var _name_clean = string_delete(_name, string_length(_name) - 4, 5);
                
                // Use internal ID if provided, otherwise fallback to namespaced filename
                // Example: "emeraldine" -> "phantasia:emeraldine"
                var _internal_id = _json[$ "id"] ?? _name_clean;
                var _full_id = (string_pos(":", _internal_id) > 0) ? _internal_id : $"{_namespace}:{_internal_id}";
                
                var _region_data = new RegionData(_full_id, _json);
                
                global.region_data[$ _full_id] = _region_data;
                
                array_push(global.region_list, _region_data);
                
                dbg_timer("init_region", $"[Init] Loaded Region: \'{_full_id}\'");
                
                delete _json;
            }
        }
    }
}
