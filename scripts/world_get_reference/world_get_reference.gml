function world_get_reference(_value)
{
    if (_value == "phantasia:time")
    {
        return global.current_world.time;
    }
    
    if (_value == "phantasia:day")
    {
        return global.current_world.day;
    }
    
    if (_value == "phantasia:weather_wind")
    {
        return global.current_world.weather.wind;
    }
    
    if (_value == "phantasia:weather_storm")
    {
        return global.current_world.weather.storm;
    }
    
    return _value;
}