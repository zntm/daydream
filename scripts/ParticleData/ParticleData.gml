enum PARTICLE_PROPERTIES_BOOLEAN {
    IS_ADDITIVE             = 1 << 0,
    IS_DESTROY_ON_COLLISION = 1 << 1,
    IS_FADE_OUT             = 1 << 2,
    HAS_COLLISION           = 1 << 3,
    HAS_STRETCHED_ANIMATION = 1 << 4
}

enum PARTICLE_MOVEMENT_TYPE {
    CONSTANT,
    REFERENCE
}

function ParticleData(_namespace, _id, _sprite) : ParentData(_namespace, _id) constructor
{
    static __set_value = function(_name, _value)
    {
        if (_value != undefined)
        {
            self[$ _name] = _value;
        }
    }
    
    static __set_smart_value = function(_name, _value)
    {
        if (_value != undefined)
        {
            self[$ _name] = smart_value_parse(_value);
        }
    }
    
    ___sprite = _sprite;
    
    static get_sprite = function()
    {
        return ___sprite;
    }
    
    #region Properties
    
    ___properties = 0;
    
    static set_properties = function(_properties)
    {
        static __properties = {
            "phantasia:is_additive":             PARTICLE_PROPERTIES_BOOLEAN.IS_ADDITIVE,
            "phantasia:is_destroy_on_collision": PARTICLE_PROPERTIES_BOOLEAN.IS_DESTROY_ON_COLLISION,
            "phantasia:is_fade_out":             PARTICLE_PROPERTIES_BOOLEAN.IS_FADE_OUT,
            "phantasia:has_collision":           PARTICLE_PROPERTIES_BOOLEAN.HAS_COLLISION,
            "phantasia:has_stretch_animation":   PARTICLE_PROPERTIES_BOOLEAN.HAS_STRETCHED_ANIMATION
        }
        
        if (_properties != undefined)
        {
            var _length = array_length(_properties);
            
            for (var i = 0; i < _length; ++i)
            {
                var _property = _properties[i];
                
                ___properties |= __properties[$ _property];
            }
        }
        
        return self;
    }
    
    static is_additive = function()
    {
        return !!(___properties & PARTICLE_PROPERTIES_BOOLEAN.IS_ADDITIVE);
    }
    
    static is_destroy_on_collision = function()
    {
        return !!(___properties & PARTICLE_PROPERTIES_BOOLEAN.IS_DESTROY_ON_COLLISION);
    }
    
    static is_fade_out = function()
    {
        return !!(___properties & PARTICLE_PROPERTIES_BOOLEAN.IS_FADE_OUT);
    }
    
    static has_collision = function()
    {
        return !!(___properties & PARTICLE_PROPERTIES_BOOLEAN.HAS_COLLISION);
    }
    
    static has_stretch_animation = function()
    {
        return !!(___properties & PARTICLE_PROPERTIES_BOOLEAN.HAS_STRETCHED_ANIMATION);
    }
    
    #endregion
    
    static set_lifetime = function(_lifetime)
    {
        ___lifetime = smart_value_parse(_lifetime);
        
        return self;
    }
    
    static get_lifetime = function()
    {
        return ___lifetime;
    }
    
    static set_physics = function(_physics)
    {
        if (_physics != undefined)
        {
            // Handle xspeed directly under physics
            var _xspeed = _physics[$ "xspeed"];
            
            if (_xspeed != undefined)
            {
                var _type = _xspeed[$ "type"];
                
                if (_type == "reference")
                {
                    __set_value("___xspeed_type", PARTICLE_MOVEMENT_TYPE.REFERENCE);
                    __set_value("___xspeed", _xspeed.value);
                }
                else// if (_type == "smart_value:random" or other)
                {
                    __set_value("___xspeed_type", PARTICLE_MOVEMENT_TYPE.CONSTANT);
                    __set_smart_value("___xspeed", _xspeed);
                }
                
                __set_smart_value("___xspeed_offset", _xspeed[$ "offset"]);
                __set_smart_value("___xspeed_multiplier", _xspeed[$ "multiplier"]);
            }
            
            // Handle yspeed directly under physics
            var _yspeed = _physics[$ "yspeed"];
            
            if (_yspeed != undefined)
            {
                var _type = _yspeed[$ "type"];
                
                if (_type == "reference")
                {
                    __set_value("___yspeed_type", PARTICLE_MOVEMENT_TYPE.REFERENCE);
                    __set_value("___yspeed", _yspeed.value);
                }
                else// if (_type == "smart_value:random" or other)
                {
                    __set_value("___yspeed_type", PARTICLE_MOVEMENT_TYPE.CONSTANT);
                    __set_smart_value("___yspeed", _yspeed);
                }
                
                __set_smart_value("___yspeed_offset", _yspeed[$ "offset"]);
                __set_smart_value("___yspeed_multiplier", _yspeed[$ "multiplier"]);
            }
            
            __set_smart_value("___scale", _physics[$ "scale"]);
            
            var _rotation = _physics[$ "rotation"];
            
            if (_rotation != undefined)
            {
                __set_smart_value("___rotation_increment", _rotation[$ "increment"]);
                __set_smart_value("___rotation", _rotation[$ "value"]);
            }
            
            var _on_collision = _physics[$ "on_collision"];
            
            if (_on_collision != undefined)
            {
                // Handle on_collision xspeed
                var _x = _on_collision[$ "xspeed"];
                
                if (_x != undefined)
                {
                    var _type = _x[$ "type"];
                    
                    if (_type == "reference")
                    {
                        __set_value("___on_collision_xspeed_type", PARTICLE_MOVEMENT_TYPE.REFERENCE);
                        __set_value("___on_collision_xspeed", _x.value);
                    }
                    else// if (_type == "smart_value:random" or other)
                    {
                        __set_value("___on_collision_xspeed_type", PARTICLE_MOVEMENT_TYPE.CONSTANT);
                        __set_smart_value("___on_collision_xspeed", _x);
                    }
                    
                    __set_smart_value("___on_collision_xspeed_offset", _x[$ "offset"]);
                    __set_smart_value("___on_collision_xspeed_multiplier", _x[$ "multiplier"]);
                }
                
                // Handle on_collision yspeed
                var _y = _on_collision[$ "yspeed"];
                
                if (_y != undefined)
                {
                    var _type = _y[$ "type"];
                    
                    if (_type == "reference")
                    {
                        __set_value("___on_collision_yspeed_type", PARTICLE_MOVEMENT_TYPE.REFERENCE);
                        __set_value("___on_collision_yspeed", _y.value);
                    }
                    else// if (_type == "smart_value:random" or other)
                    {
                        __set_value("___on_collision_yspeed_type", PARTICLE_MOVEMENT_TYPE.CONSTANT);
                        __set_smart_value("___on_collision_yspeed", _y);
                    }
                    
                    __set_smart_value("___on_collision_yspeed_offset", _y[$ "offset"]);
                    __set_smart_value("___on_collision_yspeed_multiplier", _y[$ "multiplier"]);
                }
            }
        }
        
        return self;
    }
    
    static set_attribute = function(_attributes)
    {
        if (_attributes != undefined)
        {
            __set_smart_value("___gravity", _attributes[$ "gravity"]);
        }
        
        return self;
    }
    
    static get_gravity = function()
    {
        return self[$ "___gravity"] ?? 0;
    }
    
    static get_xspeed_type = function()
    {
        return self[$ "___xspeed_type"] ?? PARTICLE_MOVEMENT_TYPE.CONSTANT;
    }
    
    static get_xspeed = function()
    {
        return self[$ "___xspeed"] ?? 0;
    }
    
    static get_xspeed_offset = function()
    {
        return self[$ "___xspeed_offset"] ?? 0;
    }
    
    static get_xspeed_multiplier = function()
    {
        return self[$ "___xspeed_multiplier"] ?? 1;
    }
    
    static get_yspeed_type = function()
    {
        return self[$ "___yspeed_type"] ?? PARTICLE_MOVEMENT_TYPE.CONSTANT;
    }
    
    static get_yspeed = function()
    {
        return self[$ "___yspeed"] ?? 0;
    }
    
    static get_yspeed_offset = function()
    {
        return self[$ "___yspeed_offset"] ?? 0;
    }
    
    static get_yspeed_multiplier = function()
    {
        return self[$ "___yspeed_multiplier"] ?? 1;
    }
    
    static get_scale = function()
    {
        return self[$ "___scale"] ?? 1;
    }
    
    static get_rotation_increment = function()
    {
        return self[$ "___rotation_increment"] ?? 0;
    }
    
    static get_rotation = function()
    {
        return self[$ "___rotation"] ?? 0;
    }
    
    static get_on_collision_xspeed_type = function()
    {
        return self[$ "___on_collision_xspeed_type"] ?? PARTICLE_MOVEMENT_TYPE.CONSTANT;
    }
    
    static get_on_collision_xspeed = function()
    {
        return self[$ "___on_collision_xspeed"] ?? 0;
    }
    
    static get_on_collision_xspeed_offset = function()
    {
        return self[$ "___on_collision_xspeed_offset"] ?? 0;
    }
    
    static get_on_collision_xspeed_multiplier = function()
    {
        return self[$ "___on_collision_xspeed_multiplier"] ?? 1;
    }
    
    static get_on_collision_yspeed_type = function()
    {
        return self[$ "___on_collision_yspeed_type"] ?? PARTICLE_MOVEMENT_TYPE.CONSTANT;
    }
    
    static get_on_collision_yspeed = function()
    {
        return self[$ "___on_collision_yspeed"] ?? 0;
    }
    
    static get_on_collision_yspeed_offset = function()
    {
        return self[$ "___on_collision_yspeed_offset"] ?? 0;
    }
    
    static get_on_collision_yspeed_multiplier = function()
    {
        return self[$ "___on_collision_yspeed_multiplier"] ?? 1;
    }
    
    static get_attribute = function()
    {
        return self[$ "___attributes"];
    }
}