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
        
        var _name = string_replace(_file, ".json", "");
        var _json_root = buffer_load_json($"{_directory}/{_file}");
        var _prepared = init_data_prepare_json("achievements", _namespace, $"achievement/{_name}", _json_root, _file);
        if (_prepared == undefined) continue;

        var _json = _prepared.json;
        if (!init_data_namespace_allowed(_json, _file)) continue;
        
        if (is_struct(_json))
        {
            global.achievement_data[$ _prepared.full_id] = _json;
            init_data_finalize_json("achievements", _prepared.full_id, _prepared.json);
        }
    }
}
