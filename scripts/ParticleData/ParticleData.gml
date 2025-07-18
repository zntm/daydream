enum PARTICLE_PROPERTIES_BOOLEAN {
    IS_DESTROY_ON_COLLISION = 1 << 0,
    IS_FADE_OUT             = 1 << 1,
    HAS_COLLISION           = 1 << 2,
    HAS_STRETCHED_ANIMATION = 1 << 3
}

enum PARTICLE_MOVEMENT_TYPE {
    CONSTANT,
    REFERENCE
}

enum PARTICLE_ROTATION_TYPE {
    CONSTANT,
    INCREMENT
}

function ParticleData(_sprite, _sprite_data) constructor
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
    
    __set_smart_value("___sprite_speed", _sprite_data[$ "speed"]);
    
    static get_sprite = function()
    {
        return ___sprite;
    }
    
    static get_sprite_speed = function()
    {
        return ___sprite_speed;
    }
    
    #region Properties
    
    ___properties = 0;
    
    static set_properties = function(_properties)
    {
        static __properties = {
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
            __set_value("___gravity", _physics[$ "gravity"]);
            
            var _speed = _physics[$ "speed"];
            
            if (_speed != undefined)
            {
                var _x = _speed[$ "x"];
                
                if (_x != undefined)
                {
                    var _type = _x[$ "type"];
                    
                    if (_type == "reference")
                    {
                        __set_value("___xspeed_type", PARTICLE_MOVEMENT_TYPE.REFERENCE);
                        __set_value("___xspeed", _x.value);
                    }
                    else// if (_type == "number")
                    {
                        __set_value("___xspeed_type", PARTICLE_MOVEMENT_TYPE.CONSTANT);
                    	__set_smart_value("___xspeed", _x.value);
                    }
                    
                    __set_smart_value("___xspeed_offset", _x[$ "offset"]);
                    __set_smart_value("___xspeed_multiplier", _x[$ "multiplier"]);
                }
                
                var _y = _speed[$ "y"];
                
                if (_y != undefined)
                {
                    var _type = _y[$ "type"];
                    
                    if (_type == "reference")
                    {
                        __set_value("___yspeed_type", PARTICLE_MOVEMENT_TYPE.REFERENCE);
                        __set_value("___yspeed", _y.value);
                    }
                    else// if (_type == "number")
                    {
                        __set_value("___yspeed_type", PARTICLE_MOVEMENT_TYPE.CONSTANT);
                    	__set_smart_value("___yspeed", _y.value);
                    }
                    
                    __set_smart_value("___yspeed_offset", _y[$ "offset"]);
                    __set_smart_value("___yspeed_multiplier", _y[$ "multiplier"]);
                }
            }
            
            __set_smart_value("___scale", _physics[$ "scale"]);
            
            var _rotation = _physics[$ "rotation"];
            
            if (_rotation != undefined)
            {
                var _type = _rotation[$ "type"];
                
                if (_type == "increment")
                {
                    __set_value("___rotation_type", PARTICLE_ROTATION_TYPE.INCREMENT);
                }
                else// if (_type == "constant")
                {
                    __set_value("___rotation_type", PARTICLE_ROTATION_TYPE.CONSTANT);
                }
                
                __set_smart_value("___rotation", _rotation.value);
            }
            
            var _on_collision = _physics[$ "on_collision"];
            
            if (_on_collision != undefined)
            {
                var _on_collision_speed = _on_collision[$ "speed"];
                
                if (_on_collision_speed != undefined)
                {
                    var _x = _on_collision_speed[$ "x"];
                    
                    if (_x != undefined)
                    {
                        var _type = _x[$ "type"];
                        
                        if (_type == "reference")
                        {
                            __set_value("___on_collision_xspeed_type", PARTICLE_MOVEMENT_TYPE.REFERENCE);
                            __set_value("___on_collision_xspeed", _x.value);
                        }
                        else// if (_type == "number")
                        {
                            __set_value("___on_collision_xspeed_type", PARTICLE_MOVEMENT_TYPE.CONSTANT);
                        	__set_smart_value("___on_collision_xspeed", _x.value);
                        }
                        
                        __set_smart_value("___on_collision_xspeed_offset", _x[$ "offset"]);
                        __set_smart_value("___on_collision_xspeed_multiplier", _x[$ "multiplier"]);
                    }
                    
                    var _y = _on_collision_speed[$ "y"];
                    
                    if (_y != undefined)
                    {
                        var _type = _y[$ "type"];
                        
                        if (_type == "reference")
                        {
                            __set_value("___on_collision_yspeed_type", PARTICLE_MOVEMENT_TYPE.REFERENCE);
                            __set_value("___on_collision_yspeed", _y.value);
                        }
                        else// if (_type == "number")
                        {
                            __set_value("___on_collision_yspeed_type", PARTICLE_MOVEMENT_TYPE.CONSTANT);
                        	__set_smart_value("___on_collision_yspeed", _y.value);
                        }
                        
                        __set_smart_value("___on_collision_yspeed_offset", _y[$ "offset"]);
                        __set_smart_value("___on_collision_yspeed_multiplier", _y[$ "multiplier"]);
                    }
                }
            }
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
    
    static get_rotation_type = function()
    {
        return self[$ "___rotation_type"] ?? PARTICLE_ROTATION_TYPE.CONSTANT;
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
}