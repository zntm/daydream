global.achievement_data = {}

function init_achievement(_namespace, _directory)
{
    var _files = file_read_directory(_directory, true);
    var _files_length = array_length(_files);
    
    for (var i = _files_length - 1; i >= 0; --i)
    {
        var _file = _files[i];
        
        // Skip non-json
        if (!string_ends_with(_file, ".json")) continue;
        
        var _json = buffer_load_json($"{_directory}/{_file}");
        if (!init_data_namespace_allowed(_json, _file)) continue;
        
        if (is_struct(_json))
        {
            // Derive ID from filename: "first_wood.json" -> "first_wood"
            var _name = string_replace(_file, ".json", "");
            var _id = $"{_namespace}:achievement/{_name}";
            
            global.achievement_data[$ _id] = _json;
        }
    }
}
