function file_save_player_global(_current_player, _extra_data = {})
{
    var _buffer = buffer_create(1024, buffer_grow, 1);
    
    buffer_write(_buffer, buffer_string, _current_player.uuid);
    buffer_write(_buffer, buffer_string, _current_player.name);
    buffer_write(_buffer, buffer_u16,    _current_player.hp);
    buffer_write(_buffer, buffer_u16,    _current_player.hp_max);
    buffer_write(_buffer, buffer_string, date_datetime_string(date_current_datetime()));
    buffer_write(_buffer, buffer_string, PROGRAM_VERSION_NUMBER);
    
    /* complex structs as json strings for simplicity within the buffer */
    buffer_write(_buffer, buffer_string, json_stringify(_current_player.attire));
    buffer_write(_buffer, buffer_string, json_stringify(global.player_statistics));
    buffer_write(_buffer, buffer_string, json_stringify(global.player_achievements));
    
    /* extra data (e.g. effects) */
    buffer_write(_buffer, buffer_string, json_stringify(_extra_data));
    
    buffer_save_compressed(_buffer, $"{PROGRAM_DIRECTORY_PLAYERS}/{_current_player.uuid}/global.dat");
    buffer_delete(_buffer);
}
