function BackgroundData() constructor
{
    ___sprite = [];
    ___sprite_width  = [];
    ___sprite_height = [];
    
    ___sprite_length = 0;
    
    static add_sprite = function(_sprite)
    {
        array_push(___sprite, _sprite);
        array_push(___sprite_width,  sprite_get_width(_sprite));
        array_push(___sprite_height, sprite_get_height(_sprite));
        
        ++___sprite_length;
        
        return self;
    }
    
    static get_sprite = function(_index)
    {
        return ___sprite[_index];
    }
    
    static get_sprite_width = function(_index)
    {
        return ___sprite_width[_index];
    }
    
    static get_sprite_height = function(_index)
    {
        return ___sprite_height[_index];
    }
    
    static get_sprite_length = function()
    {
        return ___sprite_length;
    }
}