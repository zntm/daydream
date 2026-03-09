/// @desc Returns the total size of all files in a directory (in bytes).
/// @param {String} _directory The directory to measure.
/// @returns {Real}
function file_get_directory_size(_directory)
{
    var _total = 0;
    var _list  = file_read_directory(_directory, true);

    for (var i = array_length(_list) - 1; i >= 0; --i)
    {
        var _path = $"{_directory}/{_list[i]}";

        /* skip directories as we only want to sum file sizes */
        if (directory_exists(_path)) continue;

        var _handle = file_bin_open(_path, 0);

        if (_handle != -1)
        {
            _total += file_bin_size(_handle);
            file_bin_close(_handle);
        }
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
