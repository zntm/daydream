enum ITEM_TYPE {
    DEFAULT,
    SOLID,
    PLATFORM,
    UNTOUCHABLE,
    TOOL,
    ACCESSORY
}

enum ITEM_TYPE_BIT {
    DEFAULT     = 1 << ITEM_TYPE.DEFAULT,
    SOLID       = 1 << ITEM_TYPE.SOLID,
    PLATFORM    = 1 << ITEM_TYPE.PLATFORM,
    UNTOUCHABLE = 1 << ITEM_TYPE.UNTOUCHABLE,
    TOOL        = 1 << ITEM_TYPE.TOOL,
    ACCESSORY   = 1 << ITEM_TYPE.ACCESSORY
}

global.item_type = {
    "default":     ITEM_TYPE_BIT.DEFAULT,
    "solid":       ITEM_TYPE_BIT.SOLID,
    "platform":    ITEM_TYPE_BIT.PLATFORM,
    "untouchable": ITEM_TYPE_BIT.UNTOUCHABLE,
    "tool":        ITEM_TYPE_BIT.TOOL,
    "accessory":   ITEM_TYPE_BIT.ACCESSORY
}

global.item_armor_type = {
    helmet: INVENTORY_SLOT_TYPE.ARMOR_HELMET,
    breastplate: INVENTORY_SLOT_TYPE.ARMOR_BREASTPLATE,
    leggings: INVENTORY_SLOT_TYPE.ARMOR_LEGGINGS,
    accessory: INVENTORY_SLOT_TYPE.ACCESSORY
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
    
    static set_item = function(_data)
    {
        static __item_armor_type = global.item_armor_type;
        
        if (_data != undefined)
        {
            ___item_damage = _data[$ "damage"];
            
            var _consumable = _data[$ "consumable"];
            
            if (_consumable != undefined)
            {
                ___item_consumable_hp = _consumable.hp;
                ___item_consumable_saturation = _consumable.saturation;
                
                var _cooldown = _consumable[$ "cooldown"];
                
                if (_cooldown != undefined)
                {
                    ___item_consumable_cooldown_id = _cooldown.id;
                    ___item_consumable_cooldown_second = _cooldown.second;
                }
                
                var _sfx = _consumable[$ "sfx"];
                
                if (_sfx != undefined)
                {
                    ___item_consumable_sfx_id = _sfx.id;
                }
            }
            
            var _durability = _data[$ "durability"];
            
            if (_durability != undefined)
            {
                ___item_durability_amount = _durability.amount;
                
                var _bar = _durability.bar;
                
                ___item_durability_bar        = _bar;
                ___item_durability_bar_length = array_length(_bar.data);
            }
            
            var _armor = _data[$ "armor"];
            
            if (_armor != undefined)
            {
                ___item_armor_type = __item_armor_type[$ _armor.type];
                ___item_armor_defense = _armor[$ "defense"];
                
                var _attribute = _armor[$ "attribute"];
                
                if (_attribute != undefined)
                {
                    ___item_armor_attribute = new Attribute()
                        .set_boolean(_attribute[$ "boolean"])
                        .set_collision_box(_attribute[$ "collision_box"])
                        .set_hit_box(_attribute[$ "hit_box"])
                        .set_eye_level(_attribute[$ "eye_level"])
                        .set_gravity(_attribute[$ "gravity"])
                        .set_jump_count_max(_attribute[$ "jump_count_max"])
                        .set_jump_falloff(_attribute[$ "jump_falloff"])
                        .set_jump_height(_attribute[$ "jump_height"])
                        .set_jump_time(_attribute[$ "jump_time"])
                        .set_movement_speed(_attribute[$ "movement_speed"])
                        .set_regeneration_amount(_attribute[$ "regeneration_amount"])
                        .set_regeneration_time(_attribute[$ "regeneration_time"]);
                }
            }
        }
        
        return self;
    }
    
    static get_item_damage = function()
    {
        return self[$ "___item_damage"] ?? 1;
    }
    
    static get_item_consumable_hp = function()
    {
        return self[$ "___item_consumable_hp"];
    }
    
    static get_item_consumable_saturation = function()
    {
        return self[$ "___item_consumable_saturation"];
    }
    
    static get_item_consumable_cooldown_id = function()
    {
        return self[$ "___item_consumable_cooldown_id"];
    }
    
    static get_item_consumable_cooldown_second = function()
    {
        return self[$ "___item_consumable_cooldown_second"];
    }
    
    static get_item_consumable_sfx_id = function()
    {
        return self[$ "___item_consumable_sfx_id"];
    }
    
    static get_item_durability_amount = function()
    {
        return self[$ "___item_durability_amount"] ?? 0;
    }
       
    static get_item_armor_type = function()
    {
        return self[$ "___item_armor_type"];
    }
    
    static get_item_armor_defense = function()
    {
        return self[$ "___item_armor_defense"];
    }
    
    static get_item_armor_attribute = function()
    {
        return self[$ "___item_armor_attribute"];
    }
    
    static get_item_durability_bar = function()
    {
        return self[$ "___item_durability_bar"];
    }
    
    static get_item_durability_bar_length = function()
    {
        return self[$ "___item_durability_bar_length"];
    }
    
    static set_placement = function(_placement)
    {
        static __chunk_depth = global.chunk_depth;
        
        static __condition_type = {
            "every": TILE_PLACEMENT_CONDITION_TYPE.EVERY,
            "some":  TILE_PLACEMENT_CONDITION_TYPE.SOME
        }
        
        static __item_type = global.item_type;
        
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
                    
                    var _type = 0;
                    var _types = _value[$ "type"];
                    
                    if (is_array(_types))
                    {
                        var _types_length = array_length(_types);
                        
                        for (var j = 0; j < _types_length; ++j)
                        {
                            __type |= __item_type[$ _types[j]];
                        }
                    }
                    else
                    {
                        _type = __item_type[$ _types];
                    }
                    
                    _data.type = _type;
                    
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
        return self[$ "___audio_properties_lowpass"] ?? 0;
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
            var _ = function_parse(_data);
            var _length = array_length(_);
            
            ___on_random_tick = _;
            ___on_random_tick_length = _length;
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
    
    static set_on_attack = function(_data)
    {
        if (_data != undefined)
        {
            var _ = function_parse(_data);
            var _length = array_length(_);
            
            ___on_attack = _;
            ___on_attack_length = _length;
        }
        
        return self;
    }
    
    static get_on_attack = function()
    {
        return self[$ "___on_attack"];
    }
    
    static get_on_attack_length = function()
    {
        return self[$ "___on_attack_length"];
    }
    
    static set_on_item_use = function(_data)
    {
        if (_data != undefined)
        {
            var _ = function_parse(_data);
            var _length = array_length(_);
            
            ___on_item_use = _;
            ___on_item_use_length = _length;
        }
        
        return self;
    }
    
    static get_on_item_use = function()
    {
        return self[$ "___on_item_use"];
    }
    
    static get_on_item_use_length = function()
    {
        return self[$ "___on_item_use_length"];
    }
    
    static set_on_tile_use = function(_data)
    {
        if (_data != undefined)
        {
            var _ = function_parse(_data);
            var _length = array_length(_);
            
            ___on_tile_use = _;
            ___on_tile_use_length = _length;
        }
        
        return self;
    }
    
    static get_on_tile_use = function()
    {
        return self[$ "___on_tile_use"];
    }
    
    static get_on_tile_use_length = function()
    {
        return self[$ "___on_tile_use_length"];
    }
    
    static set_light = function(_light)
    {
        if (_light != undefined)
        {
            ___light = hex_parse(_light);
        }
        
        return self;
    }
    
    static get_light = function()
    {
        return self[$ "___light"];
    }
    
    static has_light = function()
    {
        return (self[$ "___light"] != undefined);
    }
    
    static set_container = function(_container)
    {
        if (_container != undefined)
        {
            ___container_length = _container.length;
            ___container_invalid = _container[$ "invalid"];
        }
        
        return self;
    }
    
    static get_container_length = function()
    {
        return self[$ "___container_length"] ?? 0;
    }
    
    static get_container_invalid = function()
    {
        return self[$ "___container_invalid"];
    }
    
    static set_components = function(_components)
    {
        if (_components != undefined)
        {
            var _names = struct_get_names(_components);
            var _length = array_length(_names);
            
            ___components = {}
            ___components_names = _names;
            ___components_length = _length;
            
            for (var i = 0; i < _length; ++i)
            {
                var _name = _names[i];
                
                ___components[$ _name] = _components[$ _name];
            }
        }
        
        return self;
    }
    
    static get_component = function(_name)
    {
        return ___components[$ _name];
    }
    
    static get_components_names = function()
    {
        return self[$ "___components_names"];
    }
    
    static get_components_length = function()
    {
        return self[$ "___components_length"] ?? 0;
    }
}