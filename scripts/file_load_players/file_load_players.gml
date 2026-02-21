global.file_players      = [];
global.file_players_uuid = [];

function file_load_players()
{
    static __sort = function(_a, _b)
    {
        return _a.get_last_opened() - _b.get_last_opened();
    }
    
    array_resize(global.file_players, 0);
    array_resize(global.file_players_uuid, 0);
    
    var _files        = file_read_directory(PROGRAM_DIRECTORY_PLAYERS);
    var _files_length = array_length(_files);
    var _length       = array_length(global.attire_elements);
    
    for (var i = 0; i < _files_length; ++i)
    {
        var _file = _files[i];
        
        if (!directory_exists($"{PROGRAM_DIRECTORY_PLAYERS}/{_file}")) continue;
        
        var _player_data_path = $"{PROGRAM_DIRECTORY_PLAYERS}/{_file}/global.dat";
        
        if (!file_exists(_player_data_path)) continue;
        
        var _buffer = buffer_load_decompressed(_player_data_path);
        
        if (_buffer == -1) continue;
        
        var _uuid         = buffer_read(_buffer, buffer_string);
        var _name         = buffer_read(_buffer, buffer_string);
        var _hp           = buffer_read(_buffer, buffer_u16);
        var _hp_max       = buffer_read(_buffer, buffer_u16);
        var _last_opened  = buffer_read(_buffer, buffer_string);
        var _version      = buffer_read(_buffer, buffer_string);
        var _attire       = json_parse(buffer_read(_buffer, buffer_string));
        var _statistics   = json_parse(buffer_read(_buffer, buffer_string));
        var _achievements = json_parse(buffer_read(_buffer, buffer_string));
        var _extra        = json_parse(buffer_read(_buffer, buffer_string));
        
        buffer_delete(_buffer);
        
        array_push(global.file_players_uuid, _file);
        
        var _player = new FilePlayer(_file, _name, unix_to_datetime(datetime_to_unix()));
        
        _player.set_version(_version)
               .set_attire(_attire)
               .set_hp(_hp, _hp_max)
               .set_statistics(_statistics)
               .set_achievements(_achievements)
               .set_effects(_extra[$ "effects"] ?? {});
               
        array_push(global.file_players, _player);
    }
    
    array_sort(global.file_players, __sort);
}