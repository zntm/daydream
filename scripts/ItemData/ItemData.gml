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
    static __item_type = {
        "default":     ITEM_TYPE_BIT.DEFAULT,
        "solid":       ITEM_TYPE_BIT.SOLID,
        "untouchable": ITEM_TYPE_BIT.UNTOUCHABLE
    }

    ___type = 0;
    
    static set_type = function(_value)
    {
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
    
    static set_harvest = function(_harvest)
    {
        ___harvest_value = (_harvest.level << 16) | _harvest.hardness;
        
        var _harvest_type = _harvest[$ "type"];
        
        if (_harvest_type != undefined)
        {
            ___harvest_type = __item_type[$ _harvest_type];
        }
        
        return self;
    }
    
    static get_harvest_hardness = function()
    {
        return ___harvest_value & 0xffff;
    }
    
    static get_hardvest_level = function()
    {
        return (___harvest_value >> 16) & 0xff;
    }
    
    static get_hardvest_type = function()
    {
        return self[$ "___harvest_type"];
    }
    
    static set_drop = function(_drop)
    {
        var _drop_chance = _drop[$ "chance"];
        
        if (_drop_chance != undefined)
        {
            ___drop_chance = _drop_chance;
        }
        
        var _drop_item = _drop[$ "item"];
        
        if (_drop_item != undefined)
        {
            ___drop_item = _drop_item;
        }
        
        var _drop_loot = _drop[$ "loot"];
        
        if (_drop_loot != undefined)
        {
            ___drop_loot = _drop_loot;
        }
        
        return self;
    }
    
    static get_drop_chance = function()
    {
        return self[$ "___drop_chance"] ?? 1;
    }
    
    static get_drop_item = function()
    {
        return self[$ "___drop_item"];
    }
    
    static get_drop_loot = function()
    {
        return self[$ "___drop_loot"];
    }
    
    #region Boolean
    
    ___boolean = 0;
    
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