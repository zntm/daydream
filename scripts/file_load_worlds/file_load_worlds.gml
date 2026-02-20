global.file_worlds = [];
global.file_worlds_uuid = [];

function file_load_worlds()
{
    static __sort = function(_a, _b)
    {
        return _a.get_last_opened() - _b.get_last_opened();
    }
    
    array_resize(global.file_worlds, 0);
    array_resize(global.file_worlds_uuid, 0);
    
    var _files = file_read_directory(PROGRAM_DIRECTORY_WORLDS);
    var _files_length = array_length(_files);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        
        if (!directory_exists($"{PROGRAM_DIRECTORY_WORLDS}/{_file}")) continue;
        
        var _world_data_path = $"{PROGRAM_DIRECTORY_WORLDS}/{_file}/global.dat";
        if (!file_exists(_world_data_path)) continue;
        
        var _buffer = buffer_load_decompressed(_world_data_path);
        if (_buffer == -1) continue;
        
        var _uuid        = buffer_read(_buffer, buffer_string);
        var _name        = buffer_read(_buffer, buffer_string);
        var _seed        = buffer_read(_buffer, buffer_f64);
        var _time        = buffer_read(_buffer, buffer_f64);
        var _day         = buffer_read(_buffer, buffer_f64);
        var _wind        = buffer_read(_buffer, buffer_f64);
        var _storm       = buffer_read(_buffer, buffer_f64);
        var _difficulty  = buffer_read(_buffer, buffer_f64);
        var _dimension   = buffer_read(_buffer, buffer_string);
        var _last_opened = buffer_read(_buffer, buffer_string);
        var _version     = buffer_read(_buffer, buffer_string);
        
        buffer_delete(_buffer);
        
        array_push(global.file_worlds_uuid, _file);
        
        array_push(global.file_worlds, new FileWorld(_file, _name, _seed, unix_to_datetime(datetime_to_unix())) 
            .set_version(_version)
            .set_dimension(_dimension)
            .set_time(_time, _day)
            .set_weather(_wind, _storm)
            .set_difficulty(_difficulty));
    }

    
    array_sort(global.file_worlds, __sort);
}