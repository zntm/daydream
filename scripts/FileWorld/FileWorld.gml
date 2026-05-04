function FileWorld(_uuid, _name, _seed, _last_opened) constructor
{
    ___uuid = _uuid;
    
    static get_uuid = function()
    {
        return ___uuid;
    }
    
    ___name = _name;
    
    static get_name = function()
    {
        return ___name;
    }
    
    ___seed = _seed;
    
    static get_seed = function()
    {
        return ___seed;
    }
    
    ___last_opened = _last_opened;
    
    static get_last_opened = function()
    {
        return ___last_opened;
    }
    
    static set_version = function(_version)
    {
        ___version = _version;
        return self;
    }
    
    static get_version = function()
    {
        return self[$ "___version"];
    }
    
    static set_dimension = function(_dimension)
    {
        ___dimension = _dimension;
        
        return self;
    }
    
    static get_dimension = function()
    {
        return self[$ "___dimension"];
    }
    
    static set_time = function(_time, _day)
    {
        ___time = _time;
        ___day  = _day;
        
        return self;
    }
    
    static get_time = function()
    {
        return self[$ "___time"] ?? 0;
    }
    
    static get_day = function()
    {
        return self[$ "___day"] ?? 0;
    }
    
    static set_weather = function(_wind, _storm)
    {
        ___weather_wind  = _wind;
        ___weather_storm = _storm;
        
        return self;
    }
    
    static get_weather_wind = function()
    {
        return self[$ "___weather_wind"];
    }
    
    static get_weather_storm = function()
    {
        return self[$ "___weather_storm"];
    }
    
    static set_statistics = function(_statistics)
    {
        ___statistics = _statistics;
        
        return self;
    }
    
    static get_statistics = function()
    {
        return self[$ "___statistics"];
    }
    
    static set_difficulty = function(_difficulty)
    {
        ___difficulty = _difficulty;
        
        return self;
    }
    
    static get_difficulty = function()
    {
        return self[$ "___difficulty"] ?? 1.0;
    }
    
    static set_size = function(_size)
    {
        ___size = _size;
        
        return self;
    }
    
    static get_size = function()
    {
        return self[$ "___size"] ?? 0;
    }
    
    static set_backup = function(_backup)
    {
        ___backup = variable_clone(_backup);
        return self;
    }
    
    static get_backup = function()
    {
        return variable_clone(self[$ "___backup"] ?? {
            interval_minutes: 0,
            slots: 0
        });
    }
    
    static set_enabled_mods = function(_enabled_mods)
    {
        ___enabled_mods = variable_clone(_enabled_mods);
        return self;
    }
    
    static get_enabled_mods = function()
    {
        return variable_clone(self[$ "___enabled_mods"] ?? world_get_default_enabled_mods());
    }
}
