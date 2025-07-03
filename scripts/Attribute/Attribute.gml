function Attributes() constructor
{
    static set_collision_box = function(_collision_box)
    {
        ___collision_box = _collision_box;
        
        return self;
    }
    
    static get_collision_box = function()
    {
        return self[$ "___collision_box"];
    }
    
    static set_hit_box = function(_hit_box)
    {
        ___hit_box = _hit_box;
        
        return self;
    }
    
    static get_hit_box = function()
    {
        return self[$ "___hit_box"];
    }
    
    static set_eye_level = function(_eye_level)
    {
        ___eye_level = _eye_level;
        
        return self;
    }
    
    static get_eye_level = function()
    {
        return self[$ "___eye_level"] ?? 8;
    }
    
    static set_gravity = function(_gravity)
    {
        ___gravity = _gravity;
        
        return self;
    }
    
    static get_gravity = function()
    {
        return self[$ "___gravity"] ?? 0.72;
    }
    
    static set_jump_count_max = function(_jump_count_max)
    {
        ___jump_count_max = _jump_count_max;
        
        return self;
    }
    
    static get_jump_count_max = function()
    {
        return self[$ "___jump_count_max"] ?? 1;
    }
    
    static set_jump_height = function(_jump_height)
    {
        ___jump_height = _jump_height;
        
        return self;
    }
    
    static get_jump_height = function()
    {
        return self[$ "___jump_height"] ?? 28.5;
    }
    
    static set_jump_time = function(_jump_time)
    {
        ___jump_time = _jump_time;
        
        return self;
    }
    
    static get_jump_time = function()
    {
        return self[$ "___jump_time"] ?? 12;
    }
    
    static set_movement_speed = function(_speed)
    {
        ___movement_speed = _speed;
        
        return self;
    }
    
    static get_movement_speed = function()
    {
        return self[$ "___movement_speed"] ?? 3.1;
    }
}