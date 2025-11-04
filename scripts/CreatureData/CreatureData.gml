enum CREATURE_HOSTILITY_TYPE {
    PASSIVE,
    HOSTILE
}

enum CREATURE_MOVEMENT_TYPE {
    DEFAULT,
    FLY,
    SWIM
}

function CreatureData(_namespace, _id, _hp, _hostility_type, _movement_type) : ParentData(_namespace, _id) constructor
{
    ___hp = _hp;
    
    static get_hp = function(_hp)
    {
        return ___hp;
    }
    
    ___type = (_hostility_type << 4) | _movement_type;
    
    static get_hostility_type = function()
    {
        return (___type >> 4) & 0xf;
    }
    
    static set_movement_type = function(_type)
    {
        ___type = (___type & 0xf0) | _type;
        
        return self;
    }
    
    static get_movement_type = function()
    {
        return ___type & 0xf;
    }
    
    static __get_sprite = function(_name, _variant)
    {
        var _sprite = self[$ _name];
        
        if (is_struct(_sprite))
        {
            if (_variant != undefined)
            {
                return _sprite[$ _variant] ?? _sprite[$ "default"];
            }
            
            return _sprite[$ "default"];
        }
        
        return _sprite;
    }
    
    static set_sprite_idle = function(_sprite)
    {
        if (_sprite != undefined)
        {
            ___sprite_idle = _sprite;
        }
        
        return self;
    }
    
    static get_sprite_idle = function(_variant)
    {
        return __get_sprite("___sprite_idle", _variant);
    }
    
    static set_sprite_moving = function(_sprite)
    {
        if (_sprite != undefined)
        {
            ___sprite_moving = _sprite;
        }
        
        return self;
    }
    
    static get_sprite_moving = function(_variant)
    {
        return __get_sprite("___sprite_moving", _variant) ?? get_sprite_idle(_variant);
    }
    
    static set_sprite_idle_emissive = function(_sprite)
    {
        if (_sprite != undefined)
        {
            ___sprite_idle_emissive = _sprite;
        }
        
        return self;
    }
    
    static get_sprite_idle_emissive = function(_variant)
    {
        return __get_sprite("___sprite_idle_emissive", _variant);
    }
    
    static set_sprite_moving_emissive = function(_sprite)
    {
        if (_sprite != undefined)
        {
            ___sprite_moving_emissive = _sprite;
        }
        
        return self;
    }
    
    static get_sprite_moving_emissive = function(_variant)
    {
        return __get_sprite("___sprite_moving_emissive", _variant);
    }
    
    static set_light_colour = function(_colour)
    {
        ___light_colour = _colour;
        
        return self;
    }
    
    static get_light_colour = function()
    {
        return self[$ "___light_colour"] ?? c_black;
    }
    /*
    sfx = undefined;
    
    static set_sfx = function(_sfx)
    {
        sfx = _sfx;
        
        return self;
    }
    */
    static set_on_draw = function(_on_draw)
    {
        ___on_draw = _on_draw;
        
        return self;
    }
    
    static get_on_draw = function()
    {
        return self[$ "___on_draw"];
    }
    
    static set_effect_immune = function(_effect_immune)
    {
        ___effect_immune ??= [];
        
        array_push(___effect_immune, _effect_immune);
        
        return self;
    }
    
    static get_effect_immune = function()
    {
        return self[$ "___effect_immune"];
    }
    
    static set_drops = function(_drops)
    {
        ___drops = [];
        
        var _drops_length = array_length(_drops);
        
        for (var i = 0; i < _drops_length; ++i)
        {
            var _drop = _drops[i];
            
            array_push(___drops, new ItemDrop(_drop.id, smart_value_parse(_drop[$ "amount"]), _drop[$ "chance"]));
        }
    }
    
    static get_drops = function()
    {
        return self[$ "___drops"];
    }
    
    static set_attribute = function(_attributes)
    {
        ___attributes = _attributes;
        
        return self;
    }
    
    static get_attribute = function(_attributes)
    {
        return self[$ "___attributes"];
    }
    
    static set_sfx = function(_sfx)
    {
        if (_sfx != undefined)
        {
            ___sfx_interval = smart_value_parse(_sfx.interval);
            
            var _id = _sfx.id;
            
            ___sfx_death = _id[$ "death"];
            ___sfx_hurt = _id[$ "hurt"];
            ___sfx_idle = _id[$ "idle"];
        }
        
        return self;
    }
    
    static get_sfx_interval = function()
    {
        return self[$ "___sfx_interval"];
    }
    
    static get_sfx_death = function()
    {
        return self[$ "___sfx_death"];
    }
    
    static get_sfx_hurt = function()
    {
        return self[$ "___sfx_hurt"];
    }
    
    static get_sfx_idle = function()
    {
        return self[$ "___sfx_idle"];
    }
}