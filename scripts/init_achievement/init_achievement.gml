global.achievement_data = {}

function init_achievement(_directory, _namespace)
{
    // Ensure achievement data store exists (it is initialized in achievement_init but that might be called later? No, achievement_init calls event_subscribe. It should be called early. But global.achievement_data = {} is there.)
    // Actually, init() calls init_achievement.
    // achievement_init() is called in Game Start?
    // Let's check when achievement_init is called.
    
    // If achievement_init resets the global, it wipes data loaded here.
    // achievement_init is likely called BEFORE init().
    // No, init() is called in step 0.
    // achievement_init needs to be checked.
    
    var _files = file_read_directory(_directory);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        
        // Skip non-json
        if (string_pos(".json", _file) == 0) continue;
        
        // Derive ID from filename: "first_wood.json" -> "first_wood"
        var _name = string_replace(_file, ".json", "");
        var _id = $"{_namespace}:achievement/{_name}";
        
        var _json = buffer_load_json($"{_directory}/{_file}");
        
        global.achievement_data[$ _id] = _json;
    }
}
