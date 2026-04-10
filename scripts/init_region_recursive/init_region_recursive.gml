global.region_data      = {}
global.region_list      = []
global.cave_region_data = {}
global.cave_region_list = []

function init_region_recursive(_namespace = "phantasia", _directory)
{
    var _files = file_read_directory(_directory, true);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];

        if (directory_exists($"{_directory}/{_file}")) continue;
        
        if (string_ends_with(_file, ".json"))
        {
            dbg_timer("init_region");
            
            var _json = tag_value_parse(buffer_load_json($"{_directory}/{_file}"));
            if (!init_data_namespace_allowed(_json, _file)) continue;
            
            if (is_struct(_json))
            {
                var _name_clean = string_delete(_file, string_length(_file) - 4, 5);
                
                // Use internal ID if provided, otherwise fallback to namespaced filename
                // Example: "emeraldine" -> "phantasia:surface/emeraldine"
                var _internal_id = _json[$ "id"] ?? _name_clean;
                var _full_id     = (string_pos(":", _internal_id) > 0) ? _internal_id : $"{_namespace}:{_internal_id}";
                
                if (string_pos("cave", _name_clean) > 0)
                {
                    var _region_data = new CaveRegionData(_full_id, _json);
                    
                    global.cave_region_data[$ _full_id] = _region_data;
                    
                    array_push(global.cave_region_list, _region_data);
                }
                else
                {
                    var _region_data = new RegionData(_full_id, _json);
                    
                    array_push(global.region_list, _region_data);
                }
                
                /* always store in the main region map for easy resolution by ID */
                global.region_data[$ _full_id] = _region_data;
                
                dbg_timer("init_region", $"[Init] Loaded Region: \'{_full_id}\'");
                
                delete _json;
            }
        }
    }
}
