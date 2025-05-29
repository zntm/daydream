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
    IS_WALL    = 1 << 1,
    IS_FOLIAGE = 1 << 2
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
    
    static set_sprite = function(_sprite)
    {
        ___sprite = _sprite;
        ___sprite_size = (sprite_get_height(_sprite) << 24) | (sprite_get_width(_sprite) << 16) | ((sprite_get_yoffset(_sprite) + 0x80) << 8) | (sprite_get_xoffset(_sprite) + 0x80);
        
        return self;
    }
    
    static get_sprite = function()
    {
        return ___sprite;
    }
    
    static get_sprite_xoffset = function()
    {
        return (___sprite_size & 0xff) - 0x80;
    }
    
    static get_sprite_yoffset = function()
    {
        return ((___sprite_size >> 8) & 0xff) - 0x80;
    }
    
    static get_sprite_width = function()
    {
        return (___sprite_size >> 16) & 0xff;
    }
    
    static get_sprite_height = function()
    {
        return (___sprite_size >> 24) & 0xff;
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
    
    static set_inventory = function(_inventory)
    {
        _inventory = init_tag_value(_inventory);
        
        ___inventory_value = (_inventory.size << 32) | (_inventory.index << 16) | _inventory.max;
        
        return self;
    }
    
    static get_inventory_max = function()
    {
        return ___inventory_value & 0xffff;
    }
    
    static get_inventory_index = function()
    {
        return (___inventory_value >> 16) & 0xffff;
    }
    
    static get_inventory_size = function()
    {
        return (___inventory_value >> 32) & 0xffff;
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
            _placement = init_tag_value(_placement);
            
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
            
            var _requirement = _placement[$ "requirement"];
            
            if (_requirement != undefined)
            {
                ___placement_requirement = _requirement;
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
    
    static get_placement_requirement = function()
    {
        return self[$ "___placement_requirement"];
    }
    
    static set_harvest = function(_harvest)
    {
        _harvest = init_tag_value(_harvest);
        
        ___harvest_value = (_harvest.level << 16) | _harvest.hardness;
        
        var _type = _harvest[$ "type"];
        
        if (_type != undefined)
        {
            ___harvest_type = __item_type[$ _type];
        }
        
        var _particle = _harvest[$ "particle"];
        
        if (_particle != undefined)
        {
            var _length = array_length(_particle);
            
            for (var i = 0; i < _length; ++i)
            {
                _particle[@ i] = hex_parse(_particle[i]);
            }
            
            ___harvest_particle = _particle;
        }
        
        return self;
    }
    
    static get_harvest_hardness = function()
    {
        return ___harvest_value & 0xffff;
    }
    
    static get_harvest_level = function()
    {
        return (___harvest_value >> 16) & 0xff;
    }
    
    static get_harvest_type = function()
    {
        return self[$ "___harvest_type"];
    }
    
    static get_harvest_particle = function()
    {
        return self[$ "___harvest_particle"];
    }
    
    static set_durability = function(_durability)
    {
        if (_durability != undefined)
        {
            _durability = init_tag_value(_durability);
            
            ___durability_amount = _durability.amount;
            
            var _bar = _durability.bar;
            
            ___durability_bar        = _bar;
            ___durability_bar_length = array_length(_bar.data);
        }
        
        return self;
    }
    
    static get_durability_amount = function()
    {
        return self[$ "___durability_amount"] ?? 0;
    }
    
    static get_durability_bar = function()
    {
        return self[$ "___durability_bar"];
    }
    
    static get_durability_bar_length = function()
    {
        return self[$ "___durability_bar_length"];
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
    
    static set_is_wall = function(_is_wall)
    {
        if (_is_wall)
        {
            ___boolean |= ITEM_BOOLEAN.IS_WALL;
        }
        
        return self;
    }
    
    static is_wall = function()
    {
        return !!(___boolean & ITEM_BOOLEAN.IS_WALL);
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
    
    #endregion
    
    #region Inventory
    
    static set_inventory_scale = function(_scale)
    {
        ___inventory_scale = _scale;
        
        return self;
    }
    
    static get_inventory_scale = function(_scale)
    {
        return self[$ "___inventory_scale"] ?? 1;
    }
    
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