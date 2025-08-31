function ProjectileData(_namespace, _id) : ParentData(_namespace, _id) constructor
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
    
    static set_sprite = function(_sprite)
    {
        ___sprite = _sprite;
        
        return self;
    }
    
    static get_sprite = function()
    {
        return ___sprite;
    }
    
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
                __set_smart_value("___rotation_increment", _rotation[$ "increment"]);
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
    
    static set_attribute = function(_attributes)
    {
        ___attributes = _attributes;
        
        return self;
    }
    
    static get_attribute = function(_attributes)
    {
        return self[$ "___attributes"];
    }
}