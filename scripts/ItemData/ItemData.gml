enum ITEM_TYPE {
    DEFAULT,
    SOLID,
    UNTOUCHABLE
}

enum ITEM_TYPE_BIT {
    DEFAULT     = 1 << ITEM_TYPE.DEFAULT,
    SOLID       = 1 << ITEM_TYPE.SOLID,
    UNTOUCHABLE = 1 << ITEM_TYPE.UNTOUCHABLE
}

enum ITEM_BOOLEAN {
    IS_OBSTRUCTING,
    IS_OBSTRUCTABLE,
    IS_TILE,
    IS_FOLIAGE
}

enum TILE_ANIMATION_TYPE {
    DEFAULT,
    CONNECTED,
    INCREMENT,
    FOLIAGE
}

function ItemData() constructor
{
    ___type = 0;
    
    static set_type = function(_value)
    {
        static __item_type = {
            "default":     ITEM_TYPE_BIT.DEFAULT,
            "solid":       ITEM_TYPE_BIT.SOLID,
            "untouchable": ITEM_TYPE_BIT.UNTOUCHABLE
        }
        
        if (typeof(_value) == "string")
        {
            ___type |= __item_type[$ _value];
        }
        else
        {
            var _length = array_length(_value);
            
            for (var i = 0; i < _length; ++i)
            {
                ___type |= __item_type[$ _value[i]];
            }
        }
        
        return self;
    }
    
    static get_type = function()
    {
        return ___type;
    }
    
    static has_type = function(_type)
    {
        return !!(___type & _type);
    }
    
    static set_edge_padding = function(_edge_padding)
    {
        if (is_tile())
        {
            ___edge_padding = _edge_padding;
        }
        
        return self;
    }
    
    static get_edge_padding = function()
    {
        return self[$ "___edge_padding"];
    }
    
    #region Boolean
    
    ___boolean = 0;
    
    static set_is_obstructable = function(_is_obstructable)
    {
        if (_is_obstructable)
        {
            ___boolean |= 1 << ITEM_BOOLEAN.IS_OBSTRUCTABLE;
        }
        
        return self;
    }
    
    static is_obstructable = function()
    {
        return !!(___boolean & (1 << ITEM_BOOLEAN.IS_OBSTRUCTABLE));
    }
    
    static set_is_obstructing = function(_is_obstructing)
    {
        if (_is_obstructing)
        {
            ___boolean |= 1 << ITEM_BOOLEAN.IS_OBSTRUCTING;
        }
        
        return self;
    }
    
    static is_obstructing = function()
    {
        return !!(___boolean & (1 << ITEM_BOOLEAN.IS_OBSTRUCTING));
    }
    
    static set_is_tile = function(_is_tile)
    {
        if (_is_tile)
        {
            ___boolean |= 1 << ITEM_BOOLEAN.IS_TILE;
            
            set_animation_type("connected");
        }
        
        return self;
    }
    
    static is_tile = function()
    {
        return !!(___boolean & (1 << ITEM_BOOLEAN.IS_TILE));
    }
    
    static set_is_foliage = function(_is_foliage)
    {
        if (_is_foliage)
        {
            ___boolean |= 1 << ITEM_BOOLEAN.IS_FOLIAGE;
            
            set_animation_type("foliage");
        }
        
        return self;
    }
    
    static is_foliage = function()
    {
        return !!(___boolean & (1 << ITEM_BOOLEAN.IS_FOLIAGE));
    }
    
    #endregion
    
    static set_animation_type = function(_type)
    {
        static __animation_type = {
            "default": TILE_ANIMATION_TYPE.DEFAULT,
            "connected": TILE_ANIMATION_TYPE.CONNECTED,
            "increment": TILE_ANIMATION_TYPE.INCREMENT,
            "foliage": TILE_ANIMATION_TYPE.FOLIAGE
        }
        
        ___animation_type = __animation_type[$ _type];
        
        return self;
    }
    
    static get_animation_type = function()
    {
        return self[$ "___animation_type"] ?? TILE_ANIMATION_TYPE.DEFAULT;
    }
}