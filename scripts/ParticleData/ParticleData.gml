enum PARTICLE_PROPERTIES_BOOLEAN {
    IS_ADDITIVE             = 1 << 0,
    IS_DESTROY_ON_COLLISION = 1 << 1,
    HAS_COLLISION           = 1 << 2,
    HAS_STRETCHED_ANIMATION = 1 << 3
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
    
    static set_size = function(_size)
    {
        if (_size != undefined)
        {
            __set_smart_value("___xscale_min", _size[$ "xscale_min"]);
            __set_smart_value("___xscale_max", _size[$ "xscale_max"]);
            __set_smart_value("___xscale_increment", _size[$ "xscale_increment"]);
            __set_smart_value("___xscale_wiggle", _size[$ "xscale_wiggle"]);
            
            __set_smart_value("___yscale_min", _size[$ "yscale_min"]);
            __set_smart_value("___yscale_max", _size[$ "yscale_max"]);
            __set_smart_value("___yscale_increment", _size[$ "yscale_increment"]);
            __set_smart_value("___yscale_wiggle", _size[$ "yscale_wiggle"]);
        }
        
        return self;
    }
    
    static get_xscale_min = function()
    {
        return self[$ "___xscale_min"] ?? 1;
    }
    
    static get_xscale_max = function()
    {
        return self[$ "___xscale_max"] ?? 1;
    }
    
    static get_xscale_increment = function()
    {
        return self[$ "___xscale_increment"] ?? 0;
    }
    
    static get_xscale_wiggle = function()
    {
        return self[$ "___xscale_wiggle"] ?? 0;
    }
    
    static get_yscale_min = function()
    {
        return self[$ "___yscale_min"] ?? 1;
    }
    
    static get_yscale_max = function()
    {
        return self[$ "___yscale_max"] ?? 1;
    }
    
    static get_yscale_increment = function()
    {
        return self[$ "___yscale_increment"] ?? 0;
    }
    
    static get_yscale_wiggle = function()
    {
        return self[$ "___yscale_wiggle"] ?? 0;
    }
    
    static set_orientation = function(_orientation)
    {
        if (_orientation != undefined)
        {
            __set_smart_value("___angle_min", _orientation[$ "angle_min"]);
            __set_smart_value("___angle_max", _orientation[$ "angle_max"]);
            __set_smart_value("___angle_increment", _orientation[$ "angle_increment"]);
            __set_smart_value("___angle_wiggle", _orientation[$ "angle_wiggle"]);
            
            __set_value("___angle_relative", _orientation[$ "angle_relative"]);
        }
        
        return self;
    }
    
    static get_angle_min = function()
    {
        return self[$ "___angle_min"] ?? 0;
    }
    
    static get_angle_max = function()
    {
        return self[$ "___angle_max"] ?? 0;
    }
    
    static get_angle_increment = function()
    {
        return self[$ "___angle_increment"] ?? 0;
    }
    
    static get_angle_wiggle = function()
    {
        return self[$ "___angle_wiggle"] ?? 0;
    }
    
    static get_angle_relative = function()
    {
        return self[$ "___angle_relative"] ?? false;
    }
    
    static set_colour = function(_colour)
    {
        if (_colour != undefined)
        {
            __set_value("___colour1", _colour[$ "colour1"]);
            __set_value("___colour2", _colour[$ "colour2"]);
            __set_value("___colour3", _colour[$ "colour3"]);
            
            __set_smart_value("___alpha1", _colour[$ "alpha1"]);
            __set_smart_value("___alpha2", _colour[$ "alpha2"]);
            __set_smart_value("___alpha3", _colour[$ "alpha3"]);
        }
        
        return self;
    }
    
    static get_colour1 = function()
    {
        return self[$ "___colour1"];
    }
    
    static get_colour2 = function()
    {
        return self[$ "___colour2"];
    }
    
    static get_colour3 = function()
    {
        return self[$ "___colour3"];
    }
    
    static get_alpha1 = function()
    {
        return self[$ "___alpha1"] ?? 1;
    }
    
    static get_alpha2 = function()
    {
        return self[$ "___alpha2"]
    }
    
    static get_alpha3 = function()
    {
        return self[$ "___alpha3"];
    }
    
    static set_speed = function(_speed)
    {
        if (_speed != undefined)
        {
            __set_smart_value("___speed_min", _speed[$ "speed_min"]);
            __set_smart_value("___speed_max", _speed[$ "speed_max"]);
            __set_smart_value("___speed_increment", _speed[$ "speed_increment"]);
            __set_smart_value("___speed_wiggle", _speed[$ "speed_wiggle"]);
        }
        
        return self;
    }
    
    static get_speed_min = function()
    {
        return self[$ "___speed_min"] ?? 0;
    }
    
    static get_speed_max = function()
    {
        return self[$ "___speed_max"] ?? 0;
    }
    
    static get_speed_increment = function()
    {
        return self[$ "___speed_increment"] ?? 0;
    }
    
    static get_speed_wiggle = function()
    {
        return self[$ "___speed_wiggle"] ?? 0;
    }
    
    static set_direction = function(_direction)
    {
        if (_direction != undefined)
        {
            __set_smart_value("___direction_min", _direction[$ "direction_min"]);
            __set_smart_value("___direction_max", _direction[$ "direction_max"]);
            __set_smart_value("___direction_increment", _direction[$ "direction_increment"]);
            __set_smart_value("___direction_wiggle", _direction[$ "direction_wiggle"]);
        }
        
        return self;
    }
    
    static get_direction_min = function()
    {
        return self[$ "___direction_min"] ?? 0;
    }
    
    static get_direction_max = function()
    {
        return self[$ "___direction_max"] ?? 0;
    }
    
    static get_direction_increment = function()
    {
        return self[$ "___direction_increment"] ?? 0;
    }
    
    static get_direction_wiggle = function()
    {
        return self[$ "___direction_wiggle"] ?? 0;
    }
    
    static set_gravity = function(_gravity)
    {
        if (_gravity != undefined)
        {
            __set_smart_value("___gravity_amount", _gravity[$ "gravity_amount"]);
            __set_smart_value("___gravity_direction", _gravity[$ "gravity_direction"]);
            
            __set_smart_value("___gravity_point_x", _gravity[$ "gravity_point_x"]);
            __set_smart_value("___gravity_point_y", _gravity[$ "gravity_point_y"]);
            
            var _func = _gravity[$ "gravity_point_function"];
            
            if (_func != undefined)
            {
                __set_value("___gravity_point_function_source", _func);
                
                try
                {
                    var _bytecode = proglang_compile(_func);
                    
                    __set_value("___gravity_point_function", _bytecode);
                }
                catch (e)
                {
                }
            }
        }
        
        return self;
    }
    
    static get_gravity_amount = function()
    {
        return self[$ "___gravity_amount"] ?? 0;
    }
    
    static get_gravity_direction = function()
    {
        return self[$ "___gravity_direction"] ?? 270;
    }
    
    static get_gravity_point_x = function()
    {
        return self[$ "___gravity_point_x"]; 
    }
    
    static get_gravity_point_y = function()
    {
        return self[$ "___gravity_point_y"]; 
    }
    
    static get_gravity_point_function = function()
    {
        return self[$ "___gravity_point_function"]; 
    }
}