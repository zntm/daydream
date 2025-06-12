global.sfx_data = {}
global.sfx_asset = {}

function init_sfx_asset(_directory, _namespace, _id)
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
            init_sfx_asset(_subdirectory, _namespace, _name);
            
            continue;
        }
        
        if (string_ends_with(_subdirectory, ".ogg"))
        {
            dbg_timer("init_sfx");
            
            global.sfx_asset[$ $"{_namespace}:{string_delete(_name, string_length(_name) - 3, 4)}"] = audio_create_stream(_subdirectory);
            
            dbg_timer("init_sfx", $"[Init] Loaded Sound Effect: \'{string_delete(_name, string_length(_name) - 3, 4)}\'");
        }
    }
}