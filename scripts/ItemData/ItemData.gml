enum ITEM_TYPE {
    DEFAULT,
    SOLID,
    PLATFORM,
    UNTOUCHABLE,
    TOOL
}

enum ITEM_TYPE_BIT {
    DEFAULT     = 1 << ITEM_TYPE.DEFAULT,
    SOLID       = 1 << ITEM_TYPE.SOLID,
    PLATFORM    = 1 << ITEM_TYPE.PLATFORM,
    UNTOUCHABLE = 1 << ITEM_TYPE.UNTOUCHABLE,
    TOOL        = 1 << ITEM_TYPE.TOOL
}

global.item_type = {
    "default":     ITEM_TYPE_BIT.DEFAULT,
    "solid":       ITEM_TYPE_BIT.SOLID,
    "platform":    ITEM_TYPE_BIT.PLATFORM,
    "untouchable": ITEM_TYPE_BIT.UNTOUCHABLE,
    "tool":        ITEM_TYPE_BIT.TOOL
}

enum ITEM_PROPERTIES_BOOLEAN {
    IS_TILE             = 1 << 0,
    IS_WALL             = 1 << 1,
    IS_FOLIAGE          = 1 << 2,
    IS_CRAFTING_STATION = 1 << 3,
    IS_TRANSPARENT      = 1 << 4,
    CAN_FLIP_ON_X       = 1 << 5,
    CAN_FLIP_ON_Y       = 1 << 6
}

enum TILE_ANIMATION_TYPE {
    DEFAULT,
    CONNECTED,
    CONNECTED_TO_SELF,
    INCREMENT,
    FOLIAGE
}

enum TILE_COLLISION_BOX_TYPE {
    RECTANGLE,
    TRIANGLE
}

enum TILE_PLACEMENT_CONDITION_TYPE {
    EVERY,
    SOME
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

function ItemData(_namespace, _id) : ParentData(_namespace, _id) constructor
{
    ___type = 0;
    
    static set_type = function(_value)
    {
        static __item_type = global.item_type;
        
        if (is_string(_value))
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
    
    static set_rarity = function(_rarity)
    {
        if (_rarity != undefined)
        {
            ___rarity = _rarity;
        }
        
        return self;
    }
    
    static get_rarity = function()
    {
        return self[$ "___rarity"];
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
    
    ___inventory_value = 0;
    
    static set_inventory = function(_inventory)
    {
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
            "default":           TILE_ANIMATION_TYPE.DEFAULT,
            "connected":         TILE_ANIMATION_TYPE.CONNECTED,
            "connected_to_self": TILE_ANIMATION_TYPE.CONNECTED_TO_SELF,
            "increment":         TILE_ANIMATION_TYPE.INCREMENT,
            "foliage":           TILE_ANIMATION_TYPE.FOLIAGE
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
        static __chunk_depth = global.chunk_depth;
        
        static __condition_type = {
            "every": TILE_PLACEMENT_CONDITION_TYPE.EVERY,
            "some":  TILE_PLACEMENT_CONDITION_TYPE.SOME
        }
        
        if (_placement != undefined)
        {
            var _index = _placement[$ "index"];
            
            if (_index != undefined)
            {
                ___placement_index = smart_value_parse(_index);
            }
            
            var _index_offset = _placement[$ "index_offset"];
            
            if (_index_offset != undefined)
            {
                ___placement_index_offset = smart_value_parse(_index_offset);
            }
            
            var _condition = _placement[$ "condition"];
            
            if (_condition != undefined)
            {
                var _values = _condition.values;
                var _values_length = array_length(_values);
                
                ___placement_condition = {
                    type: __condition_type[$ _condition[$ "type"] ?? "every"],
                    values: [],
                    values_length: _values_length
                }
                
                for (var i = 0; i < _values_length; ++i)
                {
                    var _value = _values[i];
                    
                    var _z = _value.z;
                    
                    var _data = {
                        id: smart_value_parse(_value.id),
                        z: __chunk_depth[$ _z] ?? _z
                    }
                    
                    var _offset = _value[$ "offset"];
                    
                    if (_offset != undefined)
                    {
                        _data.xoffset = _offset[$ "x"] ?? 0;
                        _data.yoffset = _offset[$ "y"] ?? 0;
                    }
                    else
                    {
                        _data.xoffset = 0;
                        _data.yoffset = 0;
                    }
                    
                    ___placement_condition.values[@ i] = _data;
                }
            }
            
            var _id = _placement[$ "id"];
            
            if (_id != undefined)
            {
                ___placement_id = _id;
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
    
    static get_placement_condition = function()
    {
        return self[$ "___placement_condition"];
    }
    
    static get_placement_id = function()
    {
        return self[$ "___placement_id"];
    }
    
    static set_harvest = function(_harvest)
    {
        static __item_type = global.item_type;
        
        if (_harvest != undefined)
        {
            var _hardness = _harvest[$ "hardness"];
            
            if (_hardness != undefined)
            {
                ___harvest_hardness = _hardness;
            }
            
            var _level = _harvest[$ "level"];
            
            if (_level != undefined)
            {
                ___harvest_level = _level;
            }
            
            var _condition = _harvest[$ "condition"];
            
            if (_condition != undefined)
            {
                ___harvest_condition_id = _condition[$ "id"];
            }
            
            var _particle = _harvest[$ "particle"];
            
            if (_particle != undefined)
            {
                var _colour = _particle[$ "colour"];
                
                if (_colour != undefined)
                {
                    var _length = array_length(_colour);
                    
                    ___harvest_particle_colour = array_create(_length);
                    
                    for (var i = 0; i < _length; ++i)
                    {
                        ___harvest_particle_colour[@ i] = hex_parse(_colour[i]);
                    }
                }
                
                var _frequency = _particle[$ "frequency"];
                
                if (_frequency != undefined)
                {
                    ___harvest_particle_frequency = smart_value_parse(_frequency);
                }
            }
        }
        
        return self;
    }
    
    static get_harvest_hardness = function()
    {
        return self[$ "___harvest_hardness"];
    }
    
    static get_harvest_level = function()
    {
        return self[$ "___harvest_level"] ?? 0;
    }
    
    static get_harvest_condition_id = function()
    {
        return self[$ "___harvest_condition_id"]
    }
    
    static get_harvest_particle_colour = function()
    {
        return self[$ "___harvest_particle_colour"];
    }
    
    static get_harvest_particle_frequency = function()
    {
        return self[$ "___harvest_particle_frequency"] ?? 0;
    }
    
    static has_harvest_condition = function(_type)
    {
        return !!(get_harvest_condition() & _type);
    }
    
    static set_durability = function(_durability)
    {
        if (_durability != undefined)
        {
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
        static __item_type = global.item_type;
        
        if (_drop != undefined)
        {
            var _length = array_length(_drop);
            
            ___drop = [];
            ___drop_length = _length;
            
            for (var i = 0; i < _length; ++i)
            {
                var _data = _drop[i];
                
                ___drop[@ i] = {
                    id: _data.id,
                    amount: _data[$ "amount"],
                    chance: _data[$ "chance"],
                    condition: _data[$ "condition"],
                }
            }
        }
        
        return self;
    }
    
    static get_drop = function(_index)
    {
        var _item = self[$ "___drop"];
        
        return ((_item != undefined) ? _item[_index] : undefined);
    }
    
    static get_drop_length = function()
    {
        return self[$ "___drop_length"] ?? 0;
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
    
    static set_sfx = function(_sfx)
    {
        if (_sfx != undefined)
        {
            var _build = _sfx[$ "build"];
            
            if (_build != undefined)
            {
                ___sfx_build = _build;
            }
            
            var _harvest = _sfx[$ "harvest"];
            
            if (_harvest != undefined)
            {
                ___sfx_harvest = _harvest;
            }
            
            var _step = _sfx[$ "step"];
            
            if (_step != undefined)
            {
                ___sfx_step = _step;
            }
        }
        
        return self;
    }
    
    static get_sfx_build = function()
    {
        return self[$ "___sfx_build"];
    }
    
    static get_sfx_harvest = function()
    {
        return self[$ "___sfx_harvest"];
    }
    
    static get_sfx_step = function()
    {
        return self[$ "___sfx_step"];
    }
    
    static set_audio_properties = function(_audio_properties)
    {
        if (_audio_properties != undefined)
        {
            ___audio_properties_lowpass = _audio_properties[$ "lowpass"];
            ___audio_properties_reverb  = _audio_properties[$ "reverb"];
            
        }
        
        return self;
    }
    
    static get_audio_property_lowpass = function()
    {
        return self[$ "___audio_properties_reverb"] ?? 0;
    }
    
    static get_audio_property_reverb = function()
    {
        return self[$ "___audio_properties_reverb"] ?? 0;
    }
    
    static get_collision_box_left = function()
    {
        return (___colliison_box & 0xff) - 0x80;
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
    
    #region Properties
    
    ___properties = 0;
    
    static set_properties = function(_properties)
    {
        static __properties = {
            "phantasia:is_tile":        set_is_tile,
            "phantasia:is_wall":        set_is_wall,
            "phantasia:is_foliage":     set_is_foliage,
            "phantasia:is_transparent": set_is_transparent,
            "phantasia:can_flip_on_x":  set_can_flip_on_x,
            "phantasia:can_flip_on_y":  set_can_flip_on_y
        }
        
        if (_properties != undefined)
        {
            var _length = array_length(_properties);
            
            for (var i = 0; i < _length; ++i)
            {
                var _property = _properties[i];
                
                __properties[$ _property](true);
            }
        }
        
        return self;
    }
    
    static set_is_tile = function(_is_tile)
    {
        if (_is_tile)
        {
            ___properties |= ITEM_PROPERTIES_BOOLEAN.IS_TILE;
            
            set_animation_type("connected");
        }
        
        return self;
    }
    
    static is_tile = function()
    {
        return !!(___properties & ITEM_PROPERTIES_BOOLEAN.IS_TILE);
    }
    
    static set_is_wall = function(_is_wall)
    {
        if (_is_wall)
        {
            ___properties |= ITEM_PROPERTIES_BOOLEAN.IS_WALL;
        }
        
        return self;
    }
    
    static is_wall = function()
    {
        return !!(___properties & ITEM_PROPERTIES_BOOLEAN.IS_WALL);
    }
    
    static set_is_foliage = function(_is_foliage)
    {
        if (_is_foliage)
        {
            ___properties |= ITEM_PROPERTIES_BOOLEAN.IS_FOLIAGE;
            
            set_animation_type("foliage");
        }
        
        return self;
    }
    
    static is_foliage = function()
    {
        return !!(___properties & ITEM_PROPERTIES_BOOLEAN.IS_FOLIAGE);
    }
    
    static set_is_crafting_station = function(_is_crafting_station)
    {
        if (_is_crafting_station)
        {
            ___properties |= ITEM_PROPERTIES_BOOLEAN.IS_CRAFTING_STATION;
        }
        
        return self;
    }
    
    static is_crafting_station = function()
    {
        return !!(___properties & ITEM_PROPERTIES_BOOLEAN.IS_CRAFTING_STATION);
    }
    
    static set_is_transparent = function(_is_transparent)
    {
        if (_is_transparent)
        {
            ___properties |= ITEM_PROPERTIES_BOOLEAN.IS_TRANSPARENT;
        }
        
        return self;
    }
    
    static is_transparent = function()
    {
        return !!(___properties & ITEM_PROPERTIES_BOOLEAN.IS_TRANSPARENT);
    }
    
    static set_can_flip_on_x = function(_can_flip_on_x)
    {
        if (_can_flip_on_x)
        {
            ___properties |= ITEM_PROPERTIES_BOOLEAN.CAN_FLIP_ON_X;
        }
        
        return self;
    }
    
    static can_flip_on_x = function()
    {
        return !!(___properties & ITEM_PROPERTIES_BOOLEAN.CAN_FLIP_ON_X);
    }
    
    static set_can_flip_on_y = function(_can_flip_on_y)
    {
        if (_can_flip_on_y)
        {
            ___properties |= ITEM_PROPERTIES_BOOLEAN.CAN_FLIP_ON_Y;
        }
        
        return self;
    }
    
    static can_flip_on_y = function()
    {
        return !!(___properties & ITEM_PROPERTIES_BOOLEAN.CAN_FLIP_ON_Y);
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
    
    static set_on_random_tick = function(_data)
    {
        if (_data != undefined)
        {
            var _length = array_length(_data);
            
            ___on_random_tick = array_create(_length);
            ___on_random_tick_length = _length;
            
            for (var i = 0; i < _length; ++i)
            {
                var _ = _data[i];
                
                var _parameters = {}
                
                var _parameter = _[$ "parameter"];
                
                var _parameter_names = struct_get_names(_parameter);
                var _parameter_length = array_length(_parameter_names);
                
                for (var j = 0; j < _parameter_length; ++j)
                {
                    var _name = _parameter_names[j];
                    
                    _parameters[$ _name] = smart_value_parse(_parameter[$ _name]);
                }
                
                var _repeat = _[$ "repeat"];
                
                ___on_random_tick[@ i] = {
                    "function": _[$ "function"],
                    parameter: _parameters,
                    chance: _[$ "chance"] ?? 1,
                    "repeat": ((_repeat != undefined) ? smart_value_parse(_repeat) : 1)
                }
            }
        }
        
        return self;
    }
    
    static get_on_random_tick = function()
    {
        return self[$ "___on_random_tick"];
    }
    
    static get_on_random_tick_length = function()
    {
        return self[$ "___on_random_tick_length"];
    }
}