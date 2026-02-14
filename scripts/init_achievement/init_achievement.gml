global.achievement_data = {}

function init_achievement(_directory, _namespace)
{
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        
        // Skip non-json
        if (!string_ends_with(_file, ".json")) continue;
        
        var _json = buffer_load_json($"{_directory}/{_file}");
        
        if (is_struct(_json))
        {
            // Derive ID from filename: "first_wood.json" -> "first_wood"
            var _name = string_replace(_file, ".json", "");
            var _id = $"{_namespace}:achievement/{_name}";
            
            global.achievement_data[$ _id] = _json;
        }
    }
}
