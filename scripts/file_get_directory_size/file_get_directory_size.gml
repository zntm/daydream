/// @desc Returns the total size of all files in a directory (in bytes).
/// @param {String} _directory The directory to measure.
/// @returns {Real}
function file_get_directory_size(_directory)
{
    var _total = 0;
    var _files = [];
    var _dirs  = [];

    /* collect files (fa_none excludes directories) */
    for (var _f = file_find_first($"{_directory}/*", fa_none); _f != ""; _f = file_find_next())
    {
        array_push(_files, _f);
    }

    file_find_close();

    /* collect subdirectories separately so iterator is never nested */
    for (var _d = file_find_first($"{_directory}/*", fa_directory); _d != ""; _d = file_find_next())
    {
        array_push(_dirs, _d);
    }

    file_find_close();

    /* sum file sizes using binary file API */
    for (var i = array_length(_files) - 1; i >= 0; --i)
    {
        var _handle = file_bin_open($"{_directory}/{_files[i]}", 0);
        _total += file_bin_size(_handle);

        file_bin_close(_handle);
    }

    /* recurse into subdirectories */
    for (var i = array_length(_dirs) - 1; i >= 0; --i)
    {
        _total += file_get_directory_size($"{_directory}/{_dirs[i]}");
    }

    return _total;
}


/// @desc Formats a byte count into a human-readable string like "2.32 MB" or "188.12 KB".
/// @param {Real} _bytes The number of bytes.
/// @returns {String}
function file_format_size(_bytes)
{
    if (_bytes >= 1048576)
    {
        return $"{string_format(_bytes / 1048576, 1, 2)} MB";
    }

    if (_bytes >= 1024)
    {
        return $"{string_format(_bytes / 1024, 1, 2)} KB";
    }

    return $"{_bytes} B";
}
