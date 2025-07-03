function Attribute() constructor
{
    static set_boolean = function(_boolean)
    {
        if (_boolean != undefined)
        {
            ___boolean = _boolean;
        }
        
        return self;
    }
    
    static set_collision_box = function(_collision_box)
    {
        if (_collision_box != undefined)
        {
            ___collision_box = _collision_box;
        }
        
        return self;
    }
    
    static get_collision_box_width = function()
    {
        return self[$ "___collision_box"].width;
    }
    
    static get_collision_box_height = function()
    {
        return self[$ "___collision_box"].height;
    }
    
    static set_hit_box = function(_hit_box)
    {
        if (_hit_box != undefined)
        {
            ___hit_box = _hit_box;
        }
        
        return self;
    }
    
    static get_hit_box_width = function()
    {
        return self[$ "___hit_box"].width;
    }
    
    static get_hit_box_height = function()
    {
        return self[$ "___hit_box"].height;
    }
    
    static set_eye_level = function(_eye_level)
    {
        if (_eye_level != undefined)
        {
            ___eye_level = _eye_level;
        }
        
        return self;
    }
    
    static get_eye_level = function()
    {
        return self[$ "___eye_level"] ?? 8;
    }
    
    static set_gravity = function(_gravity)
    {
        if (_gravity != undefined)
        {
            ___gravity = _gravity;
        }
        
        return self;
    }
    
    static get_gravity = function()
    {
        return self[$ "___gravity"] ?? 0.72;
    }
    
    static set_jump_count_max = function(_jump_count_max)
    {
        if (_jump_count_max != undefined)
        {
            ___jump_count_max = _jump_count_max;
        }
        
        return self;
    }
    
    static get_jump_count_max = function()
    {
        return self[$ "___jump_count_max"] ?? 1;
    }
    
    static set_jump_falloff = function(_jump_falloff)
    {
        if (_jump_falloff != undefined)
        {
            ___jump_falloff = _jump_falloff;
        }
        
        return self;
    }
    
    static get_jump_falloff = function()
    {
        return self[$ "___jump_falloff"] ?? 2.2;
    }
    
    static set_jump_height = function(_jump_height)
    {
        if (_jump_height != undefined)
        {
            ___jump_height = _jump_height;
        }
        
        return self;
    }
    
    static get_jump_height = function()
    {
        return self[$ "___jump_height"] ?? 28.5;
    }

    static set_jump_time = function(_jump_time)
    {
        if (_jump_time != undefined)
        {
            ___jump_time = _jump_time;
        }
        
        return self;
    }
    
    static get_jump_time = function()
    {
        return self[$ "___jump_time"] ?? 12;
    }
    
    static set_movement_speed = function(_speed)
    {
        if (_speed != undefined)
        {
            ___movement_speed = _speed;
        }
        
        return self;
    }
    
    static get_movement_speed = function()
    {
        return self[$ "___movement_speed"] ?? 3.1;
    }
}