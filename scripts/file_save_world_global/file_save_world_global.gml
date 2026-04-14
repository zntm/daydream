function file_write_world_global_data(_buffer, _current_world)
{
    var _backup = _current_world[$ "backup"] ?? {}
    var _enabled_mods = _current_world[$ "enabled_mods"] ?? world_get_default_enabled_mods();
    var _enabled_mod_count = clamp(array_length(_enabled_mods), 0, 255);

    buffer_write(_buffer, buffer_string, _current_world.uuid);
    buffer_write(_buffer, buffer_string, _current_world.name);
    buffer_write(_buffer, buffer_f64,    _current_world.seed);
    buffer_write(_buffer, buffer_f64,    _current_world.time);
    buffer_write(_buffer, buffer_f64,    _current_world.day);
    buffer_write(_buffer, buffer_f64,    _current_world.weather.wind);
    buffer_write(_buffer, buffer_f64,    _current_world.weather.storm);
    buffer_write(_buffer, buffer_f64,    _current_world[$ "difficulty"] ?? 1.0);
    buffer_write(_buffer, buffer_string, _current_world.dimension);
    buffer_write(_buffer, buffer_string, date_datetime_string(date_current_datetime()));
    buffer_write(_buffer, buffer_string, PROGRAM_VERSION_NUMBER);

    /* appended fields are optional so older world files still load cleanly. */
    buffer_write(_buffer, buffer_u16, max(0, round(_backup[$ "interval_minutes"] ?? 0)));
    buffer_write(_buffer, buffer_u8,  max(0, round(_backup[$ "slots"] ?? 0)));
    buffer_write(_buffer, buffer_u8,  clamp(_enabled_mod_count, 0, 255));

    for (var i = 0; i < _enabled_mod_count; ++i)
    {
        buffer_write(_buffer, buffer_string, string(_enabled_mods[i]));
    }
}

function file_save_world_global(_current_world)
{
    var _buffer = buffer_create(1024, buffer_grow, 1);

    file_write_world_global_data(_buffer, _current_world);

    buffer_save_compressed(_buffer, $"{PROGRAM_DIRECTORY_WORLDS}/{_current_world.uuid}/global.dat");
    buffer_delete(_buffer);
}
