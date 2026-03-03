/// @desc Reads all files in a directory and returns them as an array of file paths.
/// @param {String} _directory The directory to read.
/// @param {Bool} _recursive OPTIONAL! Whether to also read subdirectories.
/// @returns {Array<String>}
function file_read_directory(_directory, _recursive = false)
{
    var _files = [];
    
    for (var _file = file_find_first($"{_directory}/*", fa_directory); _file != ""; _file = file_find_next())
    {
        array_push(_files, _file);
    }
    
    file_find_close();
    
    if (_recursive)
    {
        /* clone because _files contains dir names and is being appended to */
        var _dirs = variable_clone(_files);
        
        for (var i = array_length(_dirs) - 1; i >= 0; --i)
        {
            var _dir = _dirs[i];
            
            var _subfiles = file_read_directory($"{_directory}/{_dir}", true);
            
            array_concat(_dirs, _subfiles);
            
            for (var j = array_length(_subfiles) - 1; j >= 0; --j)
            {
                /* concat _dir to subfile to add the filepath */
                array_push(_files, $"{_dir}/{_subfiles[j]}");
            }
        }
        
        array_sort(_files, sort_alphabetical_descending);
        
        PRINT($"{_directory}: {_files} {_dirs}")
    }
    
    return _files;
}
