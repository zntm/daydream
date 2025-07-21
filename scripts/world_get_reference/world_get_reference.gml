function world_get_reference(_value)
{
    if (_value == "phantasia:weather_wind")
    {
        return global.world_save_data.weather_wind;
    }
    
    if (_value == "phantasia:weather_storm")
    {
        return global.world_save_data.weather_storm;
    }
    
    return _value;
}