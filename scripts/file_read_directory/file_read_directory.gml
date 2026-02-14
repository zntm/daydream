function file_read_directory(_directory, _recursive = false, _prefix = "")
{
    var _files = [];
    
    for (var _file = file_find_first($"{_directory}/*", fa_directory); _file != ""; _file = file_find_next())
    {
        array_push(_files, $"{_prefix}{_file}");
    }
    
    file_find_close();
    
    if (!_recursive)
    {
        return _files;
    }
    
    var _result = [];
    var _length = array_length(_files);
    
    for (var i = 0; i < _length; ++i)
    {
        var _file = _files[i];
        
        if (directory_exists($"{_directory}/{_file}"))
        {
            show_debug_message($"{_directory}/{_file}");
            
            _result = array_concat(_result, file_read_directory($"{_directory}/{_file}", true, $"{_file}/"));
            
            continue;
        }
        
        array_push(_result, _file);
    }
    
    return _result;
}

show_debug_message($"ts: {file_read_directory(PROGRAM_DIRECTORY_RESOURCES, true)}")