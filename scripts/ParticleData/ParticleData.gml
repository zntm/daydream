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
    
    static set_speed = function(_xspeed, _yspeed)
    {
        ___xspeed = _xspeed;
        ___yspeed = _yspeed;
        
        return self;
    }
    
    static get_xspeed = function()
    {
        return self[$ "___xspeed"] ?? 0;
    }
    
    static get_yspeed = function()
    {
        return self[$ "___yspeed"] ?? 0;
    }
    
    static set_collision_box = function(_collision_box)
    {
        if (_collision_box != undefined)
        {
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
    
    static get_collision_box_type = function()
    {
        return (___colliison_box >> 32) & 0xff;
    }
}

/*
{
    sprite:   _sprite,
    boolean: (_requires_sunlight << 5) | (_destroy_on_collision << 4) | ((_json[$ "additive"] ?? false) << 3) | ((_json[$ "stretch_animation"] ?? false) << 2) | (((_json[$ "collision"] ?? true) || (_destroy_on_collision) || (_xspeed_on_collision != undefined) || (_yspeed_on_collision != undefined)) << 1) | (_json[$ "fade_out"] ?? false),
    
    xspeed: _json[$ "xspeed"] ?? 0,
    yspeed: _json[$ "yspeed"] ?? 0,
    
    scale:   _json[$ "scale"] ?? 1,
    gravity: _json[$ "gravity"] ?? PHYSICS_GLOBAL_GRAVITY,
    
    rotation: _json[$ "rotation"] ?? 0,
    lifetime: _json.lifetime,
    
    xspeed_on_collision: _xspeed_on_collision,
    yspeed_on_collision: _yspeed_on_collision,
    
    animation_speed: _json[$ "animation_speed"] ?? 1,
    
    sprite_xoffset: _sprite_xoffset,
    sprite_yoffset: _sprite_yoffset,
    
    bbox_left: _bbox_left,
    bbox_top: _bbox_top,
    bbox_right: _bbox_right,
    bbox_bottom: _bbox_bottom,
}
 */