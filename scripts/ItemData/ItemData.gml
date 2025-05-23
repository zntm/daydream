enum ITEM_TYPE {
    DEFAULT,
    SOLID,
    PLATFORM,
    UNTOUCHABLE,
    SWORD,
    PICKAXE,
    AXE,
    SHOVEL
}

enum ITEM_TYPE_BIT {
    DEFAULT     = 1 << ITEM_TYPE.DEFAULT,
    SOLID       = 1 << ITEM_TYPE.SOLID,
    PLATFORM    = 1 << ITEM_TYPE.PLATFORM,
    UNTOUCHABLE = 1 << ITEM_TYPE.UNTOUCHABLE,
    SWORD       = 1 << ITEM_TYPE.SWORD,
    PICKAXE     = 1 << ITEM_TYPE.PICKAXE,
    AXE         = 1 << ITEM_TYPE.AXE,
    SHOVEL      = 1 << ITEM_TYPE.SHOVEL
}

enum ITEM_BOOLEAN {
    IS_TILE    = 1 << 0,
    IS_FOLIAGE = 1 << 1
}

enum TILE_ANIMATION_TYPE {
    DEFAULT,
    CONNECTED,
    INCREMENT,
    FOLIAGE
}

enum TILE_COLLISION_BOX_TYPE {
    RECTANGLE,
    TRIANGLE
}

enum INVENTORY_SLOT_TYPE {
    BASE              = 1 << 0,
    ARMOR_HELMET      = 1 << 1,
    ARMOR_BREASTPLATE = 1 << 2,
    ARMOR_LEGGINGS    = 1 << 3,
    ACCESSORY         = 1 << 4,
    CONTAINER         = 1 << 5,
    CRAFTABLE         = 1 << 6
}

function ItemData() constructor
{
    static __item_type = {
        "default":     ITEM_TYPE_BIT.DEFAULT,
        "solid":       ITEM_TYPE_BIT.SOLID,
        "platform":    ITEM_TYPE_BIT.PLATFORM,
        "untouchable": ITEM_TYPE_BIT.UNTOUCHABLE,
        "sword":       ITEM_TYPE_BIT.SWORD,
        "pickaxe":     ITEM_TYPE_BIT.PICKAXE,
        "axe":         ITEM_TYPE_BIT.AXE,
        "shovel":      ITEM_TYPE_BIT.SHOVEL,
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
    
    static set_animation_type = function(_type)
    {
        static __animation_type = {
            "default":   TILE_ANIMATION_TYPE.DEFAULT,
            "connected": TILE_ANIMATION_TYPE.CONNECTED,
            "increment": TILE_ANIMATION_TYPE.INCREMENT,
            "foliage":   TILE_ANIMATION_TYPE.FOLIAGE
        }
        
        ___animation_type = __animation_type[$ _type];
        
        return self;
    }
    
    static get_animation_type = function()
    {
        return self[$ "___animation_type"] ?? TILE_ANIMATION_TYPE.DEFAULT;
    }
    
    static set_placement = function(_placement)
    {
        if (_placement != undefined)
        {
            var _index = _placement[$ "index"];
            
            if (_index != undefined)
            {
                ___placement_index = init_smart_value(_index);
            }
            
            var _index_offset = _placement[$ "index_offset"];
            
            if (_index_offset != undefined)
            {
                ___placement_index_offset = init_smart_value(_index_offset);
            }
        }
        
        return self;
    }
    
    static get_placement_index = function()
    {
        return self[$ "___placement_index"] ?? 0;
    }
    
    static get_placement_index_offset = function()
    {
        return self[$ "___placement_index_offset"] ?? 0;
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
        if (_drop != undefined)
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
    
    static set_collision_box = function(_collision_box)
    {
        static __collision_box_type = {
            "rectangle": TILE_COLLISION_BOX_TYPE.RECTANGLE,
            "triangle":  TILE_COLLISION_BOX_TYPE.TRIANGLE
        }
        
        ___colliison_box = (__collision_box_type[$ _collision_box.type] << 32) | ((_collision_box.bottom + 0x80) << 24) | ((_collision_box.right + 0x80) << 16) | ((_collision_box.top + 0x80) << 8) | (_collision_box.left + 0x80);
        
        delete _collision_box;
        
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
    
    #region Boolean
    
    ___boolean = 0;
    
    static set_is_tile = function(_is_tile)
    {
        if (_is_tile)
        {
            ___boolean |= ITEM_BOOLEAN.IS_TILE;
            
            set_animation_type("connected");
        }
        
        return self;
    }
    
    static is_tile = function()
    {
        return !!(___boolean & ITEM_BOOLEAN.IS_TILE);
    }
    
    static set_is_foliage = function(_is_foliage)
    {
        if (_is_foliage)
        {
            ___boolean |= ITEM_BOOLEAN.IS_FOLIAGE;
            
            set_animation_type("foliage");
        }
        
        return self;
    }
    
    static is_foliage = function()
    {
        return !!(___boolean & ITEM_BOOLEAN.IS_FOLIAGE);
    }
    
    static set_durability = function(_durability)
    {
        ___durability = _durability;
        
        return self;
    }
    
    static get_durability = function()
    {
        return self[$ "___durability"] ?? 0;
    }
    
    #endregion
    
    #region Inventory
    
    static set_item_inventory_length = function(_length)
    {
        if (_length != undefined)
        {
            ___item_inventory_length = _length;
        }
        
        return self;
    }
    
    static get_item_inventory_length = function()
    {
        return self[$ "___item_inventory_length"] ?? 0;
    }
    
    static set_tile_inventory_length = function(_length)
    {
        if (_length != undefined)
        {
            ___tile_inventory_length = _length;
        }
        
        return self;
    }
    
    static get_tile_inventory_length = function()
    {
        return self[$ "___tile_inventory_length"] ?? 0;
    }
    
    #endregion
}