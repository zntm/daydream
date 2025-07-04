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
    
    static set_version = function(_major, _minor, _patch, _type)
    {
        ___version_major = _major;
        ___version_minor = _minor;
        ___version_patch = _patch;
        ___version_type  = _type;
        
        return self;
    }
    
    static get_version_major = function()
    {
        return ___version_major;
    }
    
    static get_version_minor = function()
    {
        return ___version_minor;
    }
    
    static get_version_patch = function()
    {
        return ___version_patch;
    }
    
    static get_version_type = function()
    {
        return ___version_type;
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
}