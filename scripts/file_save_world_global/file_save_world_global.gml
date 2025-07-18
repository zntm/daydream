function file_save_world_global(_world_save_data)
{
    var _buffer = buffer_create(0xff, buffer_grow, 1);
    
    buffer_write(_buffer, buffer_u16, PROGRAM_VERSION_MAJOR);
    buffer_write(_buffer, buffer_u16, PROGRAM_VERSION_MINOR);
    buffer_write(_buffer, buffer_u16, PROGRAM_VERSION_PATCH);
    buffer_write(_buffer, buffer_u16, PROGRAM_VERSION_TYPE);
    
    buffer_write(_buffer, buffer_f64, datetime_to_unix());
    
    buffer_write(_buffer, buffer_string, _world_save_data.name);
    buffer_write(_buffer, buffer_f64, _world_save_data.seed);
    
    buffer_write(_buffer, buffer_string, _world_save_data.dimension);
    
    buffer_write(_buffer, buffer_f64, _world_save_data.time);
    buffer_write(_buffer, buffer_u64, _world_save_data.day);
    
    buffer_write(_buffer, buffer_f32, _world_save_data.weather_wind);
    buffer_write(_buffer, buffer_f32, _world_save_data.weather_storm);
    
    buffer_save_compressed(_buffer, $"{PROGRAM_DIRECTORY_WORLDS}/{_world_save_data.uuid}/global.dat");
    
    buffer_delete(_buffer);
}