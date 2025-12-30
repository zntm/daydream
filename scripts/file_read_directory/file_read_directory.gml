function file_read_directory(_directory, _recursive = false, _prefix = "")
{
    var _array = [];
    
    for (var _file = file_find_first($"{_directory}/*", fa_directory); _file != ""; _file = file_find_next())
    {
        /*
        show_debug_message(_file);
        
        if (_recursive) && (directory_exists($"{_directory}/{_file}"))
        {
            // show_debug_message($"{_directory}/{_file}");
            
            var _ = file_read_directory($"{_directory}/{_file}", true, $"{_prefix}{_file}/");
            
            // show_debug_message($"{_array} {_}")
            
            _array = array_concat(_array, _);
            
            continue;
        }
        */
        array_push(_array, $"{_prefix}{_file}");
    }
    
    file_find_close();
    
    return _array;
}

show_debug_message($"ts: {file_read_directory(PROGRAM_DIRECTORY_RESOURCES, true)}")