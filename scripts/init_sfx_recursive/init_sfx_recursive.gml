global.sfx_data = {}

function init_sfx_recursive(_directory, _namespace, _id)
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
            init_sfx_recursive(_subdirectory, _namespace, _name);
            
            continue;
        }
        
        if (string_ends_with(_subdirectory, ".ogg"))
        {
            dbg_timer("init_sfx");
            
            if (_id != undefined)
            {
                global.sfx_data[$ $"{_namespace}:{_id}"] ??= [];
                
                array_push(global.sfx_data[$ $"{_namespace}:{_id}"], $"{_namespace}:{string_delete(_name, string_length(_name) - 3, 4)}");
            }
            
            global.sfx_data[$ $"{_namespace}:{string_delete(_name, string_length(_name) - 3, 4)}"] = audio_create_stream(_subdirectory);
            
            dbg_timer("init_sfx", $"[Init] Loaded Sound Effect: \'{string_delete(_name, string_length(_name) - 3, 4)}\'");
        }
    }
}