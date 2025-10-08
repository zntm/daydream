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
        
        try
        {
            var _buffer = buffer_load_decompressed($"{PROGRAM_DIRECTORY_WORLDS}/{_file}/global.dat");
            
            var _version = buffer_read(_buffer, buffer_u32);
            
            var _last_opened = unix_to_datetime(buffer_read(_buffer, buffer_f64));
            
            var _name = buffer_read(_buffer, buffer_string);
            var _seed = buffer_read(_buffer, buffer_f64);
            
            var _dimension = buffer_read(_buffer, buffer_string);
            
            var _time = buffer_read(_buffer, buffer_f64);
            var _day = buffer_read(_buffer, buffer_f64);
            
            var _weather_wind  = buffer_read(_buffer, buffer_f32);
            var _weather_storm = buffer_read(_buffer, buffer_f32);
            
            buffer_delete(_buffer);
            
            array_push(global.file_worlds_uuid, _file);
            
            array_push(global.file_worlds, new FileWorld(_file, _name, _seed, _last_opened)
                .set_dimension(_dimension)
                .set_time(_time, _day)
                .set_weather(_weather_wind, _weather_storm));
        }
        catch (_error)
        {
        }
    }
    
    array_sort(global.file_worlds, __sort);
}