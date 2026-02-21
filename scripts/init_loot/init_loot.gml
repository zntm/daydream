function init_loot(_directory, _namespace = "phantasia")
{
    var _files = file_read_directory(_directory, true);
    
    for (var i = array_length(_files) - 1; i >= 0; --i)
    {
        var _file = _files[i];
        
        // global.sound_asset[$ $"{_namespace}:{_id}"] = _array;
    }
}