global.file_players = [];
global.file_players_uuid = [];

function file_load_players()
{
    static __sort = function(_a, _b)
    {
        return _a.get_last_opened() - _b.get_last_opened();
    }
    
    array_resize(global.file_players, 0);
    array_resize(global.file_players_uuid, 0);
    
    var _files = file_read_directory(PROGRAM_DIRECTORY_PLAYERS);
    var _files_length = array_length(_files);
    
    var _length = array_length(global.attire_elements);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        
        if (!directory_exists($"{PROGRAM_DIRECTORY_PLAYERS}/{_file}")) continue;
        
        var _buffer = buffer_load_decompressed($"{PROGRAM_DIRECTORY_PLAYERS}/{_file}/global.dat");
        
        var _version = buffer_read(_buffer, buffer_u32);
        
        var _last_opened = unix_to_datetime(buffer_read(_buffer, buffer_f64));
        
        var _name = buffer_read(_buffer, buffer_string);
        
        var _attire = {}
        
        for (var j = 0; j < _length; ++j)
        {
            var _attire_name = buffer_read(_buffer, buffer_string);
            var _attire_colour = buffer_read(_buffer, buffer_u16);
            
            _attire[$ _attire_name] = {}
            
            _attire[$ _attire_name].colour = _attire_colour;
            
            if (_attire_name != "body")
            {
                var _attire_index = buffer_read(_buffer, buffer_u16);
                
                _attire[$ _attire_name].index = _attire_index;
            }
        }
        
        var _hp = buffer_read(_buffer, buffer_u16);
        var _hp_max = buffer_read(_buffer, buffer_u16);
        
        var _saturation = buffer_read(_buffer, buffer_u16);
        
        var _effects = file_load_snippet_effects(_buffer);
        
        // Skip hotbar byte (u8) which is saved after effects
        if (buffer_tell(_buffer) < buffer_get_size(_buffer))
        {
            buffer_read(_buffer, buffer_u8);
        }
        
        var _statistics = undefined;
        var _achievements = undefined;
        
        if (buffer_tell(_buffer) < buffer_get_size(_buffer))
        {
            _statistics = statistics_load_player(_buffer);
        }
        
        if (buffer_tell(_buffer) < buffer_get_size(_buffer))
        {
            _achievements = achievement_load_player(_buffer);
        }
        
        buffer_delete(_buffer);
        
        array_push(global.file_players_uuid, _file);
        
        array_push(global.file_players, new FilePlayer(_file, _name, _last_opened)
            .set_version(_version)
            .set_attire(_attire)
            .set_hp(_hp, _hp_max)
            .set_effects(_effects)
            .set_statistics(_statistics)
            .set_achievements(_achievements));
    }
    
    array_sort(global.file_players, __sort);
}