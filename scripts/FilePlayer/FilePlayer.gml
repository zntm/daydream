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
        return ___Version;
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
        ___hp = _hp;
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
}