enum PARTICLE_BOOLEAN {
    HAS_COLLISION = 1 << 0
}

function ParticleData(_sprite) constructor
{
    ___sprite = _sprite;
    
    static get_sprite = function()
    {
        return ___sprite;
    }
    
    static set_sprite_offset = function(_sprite_xoffset, _sprite_yoffset)
    {
        ___sprite_offset = ((_sprite_yoffset + 0x80) << 8) | (_sprite_xoffset + 0x80);
        
        return self;
    }
    
    static get_sprite_xoffset = function()
    {
        return (___sprite_offset & 0xff) - 0x80;
    }
    
    static get_sprite_yoffset = function()
    {
        return ((___sprite_offset >> 8) & 0xff) - 0x80;
    }
    
    static set_velocity = function(_xvelocity, _yvelocity)
    {
        if (_xvelocity != undefined)
        {
            ___xvelocity = _xvelocity;
        }
        
        if (_yvelocity != undefined)
        {
            ___yvelocity = _yvelocity;
        }
        
        return self;
    }
    
    static get_xvelocity = function()
    {
        return self[$ "___xvelocity"] ?? 0;
    }
    
    static get_yvelocity = function()
    {
        return self[$ "___yvelocity"] ?? 0;
    }
    
    static set_velocity_on_collision = function(_xvelocity, _yvelocity)
    {
        if (_xvelocity != undefined)
        {
            ___xvelocity_on_collision = _xvelocity;
        }
        
        if (_yvelocity != undefined)
        {
            ___yvelocity_on_collision = _yvelocity;
        }
        
        return self;
    }
    
    static get_xvelocity_on_collision = function()
    {
        return self[$ "___xvelocity_on_collision"] ?? 0;
    }
    
    static get_yvelocity_on_collision = function()
    {
        return self[$ "___yvelocity_on_collision"] ?? 0;
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
        return self[$ "___gravity"] ?? 0;
    }
    
    ___boolean = 0;
    
    static has_collision = function()
    {
        return !!(___boolean & PARTICLE_BOOLEAN.HAS_COLLISION);
    }
    
    static set_collision_box = function(_collision_box)
    {
        if (_collision_box != undefined)
        {
            ___boolean |= PARTICLE_BOOLEAN.HAS_COLLISION;
            
            ___colliison_box = ((_collision_box.bottom + 0x80) << 24) | ((_collision_box.right + 0x80) << 16) | ((_collision_box.top + 0x80) << 8) | (_collision_box.left + 0x80);
        }
        
        return self;
    }
    
    static get_collision_box_left = function()
    {
        return ((___colliison_box >> 0) & 0xff) - 0x80;
    }
    
    static get_collision_box_top = function()
    {
        return ((___colliison_box >> 8) & 0xff) - 0x80;
    }
    
    static get_collision_box_right = function()
    {
        return ((___colliison_box >> 16) & 0xff) - 0x80;
    }
    
    static get_collision_box_bottom = function()
    {
        return ((___colliison_box >> 24) & 0xff) - 0x80;
    }
}