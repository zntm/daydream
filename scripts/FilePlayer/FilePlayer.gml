function FilePlayer(_uuid, _name, _last_opened) constructor
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
    
    static set_attire = function(_attire)
    {
        ___attire = _attire;
        
        return self;
    }
    
    static get_attire = function()
    {
        return ___attire;
    }
    
    static set_hp = function(_hp, _hp_max)
    {
        ___hp     = _hp;
        ___hp_max = _hp_max;
        
        return self;
    }
    
    static get_hp = function()
    {
        return ___hp;
    }
    
    static get_hp_max = function()
    {
        return ___hp_max;
    }
    
    static set_effects = function(_effects)
    {
        ___effects = _effects;
        
        return self;
    }
    
    static get_effects = function()
    {
        return self[$ "___effects"];
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
    
    static set_achievements = function(_achievements)
    {
        ___achievements = _achievements;
        
        return self;
    }
    
    static get_achievements = function()
    {
        return self[$ "___achievements"];
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
    
    static save = function()
    {
        var _player_info = {
            uuid: ___uuid,
            name: ___name,
            hp: ___hp,
            hp_max: ___hp_max,
            attire: ___attire
        }
        
        file_save_player_global(_player_info);
    }
}
