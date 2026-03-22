function file_write_world_global_data(_buffer, _current_world)
{
    var _backup = _current_world[$ "backup"] ?? {};

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
}

function file_save_world_global(_current_world)
{
    var _buffer = buffer_create(1024, buffer_grow, 1);

    file_write_world_global_data(_buffer, _current_world);

    buffer_save_compressed(_buffer, $"{PROGRAM_DIRECTORY_WORLDS}/{_current_world.uuid}/global.dat");
    buffer_delete(_buffer);
}
