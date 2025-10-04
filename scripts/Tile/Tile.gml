function Tile(_id, _item_data = global.item_data) constructor
{
    ___id = _id;
    
    static get_id = function()
    {
        return self[$ "___id"];
    }
    
    // set_offset(0, 0);
    // set_scale(1, 1);
    // ___value = 0;
    
    ___value = (9 << 28) | (9 << 24) | (8 << 4) | (8 << 0);
    
    static set_offset = function(_xoffset, _yoffset)
    {
        ___value = (___value & 0b111111111_1111_1111_11111111_11111111_0000_0000) | ((_yoffset + 8) << 4) | ((_xoffset + 8) << 0);
        
        return self;
    }
    
    static set_xoffset = function(_xoffset)
    {
        ___value = (___value & 0b111111111_1111_0000_11111111_11111111_1111_0000) | ((_xoffset + 8) << 0);
        
        return self;
    }
    
    static set_yoffset = function(_yoffset)
    {
        ___value = (___value & 0b111111111_0000_1111_11111111_11111111_0000_1111) | ((_yoffset + 8) << 4);
        
        return self;
    }
    
    static get_xoffset = function()
    {
        return ((___value >> 0) & 0b1111) - 8;
    }
    
    static get_yoffset = function()
    {
        return ((___value >> 4) & 0b1111) - 8;
    }
    
    static set_scale = function(_xscale, _yscale)
    {
        // ___value = (___value & 0b111111111_0000_0000_11111111_11111111_1111_1111) | ((_yscale + 8) << 28) | ((_xscale + 8) << 24);
        
        set_xscale(_xscale);
        set_yscale(_yscale);
        
        return self;
    }
    
    static set_xscale = function(_xscale)
    {
        if (_xscale != undefined)
        {
            ___value = (___value & 0b111111111_1111_0000_11111111_11111111_1111_1111) | ((_xscale + 8) << 24);
        }
        
        return self;
    }
    
    static set_yscale = function(_yscale)
    {
        if (_yscale != undefined)
        {
            ___value = (___value & 0b111111111_1111_0000_11111111_11111111_1111_1111) | ((_yscale + 8) << 24);
        }
        
        // ___value = (___value & 0b111111111_0000_1111_11111111_11111111_1111_1111) | ((_yscale + 8) << 28);
        
        return self;
    }
    
    static get_xscale = function()
    {
        return ((___value >> 24) & 0b1111) - 8;
    }
    
    static get_yscale = function()
    {
        return ((___value >> 28) & 0b1111) - 8;
    }
    
    static set_index = function(_index)
    {
        ___value = (___value & 0b111111111_1111_1111_11111111_00000000_1111_1111) | (_index << 8);
        
        return self;
    }
    
    static get_index = function()
    {
        return (___value >> 8) & 0b11111111;
    }
    
    static set_index_offset = function(_index)
    {
        if (_index != undefined)
        {
            ___value = (___value & 0b111111111_1111_1111_00000000_11111111_1111_1111) | (_index << 16);
        }
        
        return self;
    }
    
    static get_index_offset = function()
    {
        return (___value >> 16) & 0b11111111;
    }
    
    static set_rotation = function(_rotation)
    {
        _rotation = ((_rotation % 360) + 360) % 360;
        
        ___value = (___value & 0b000000000_1111_1111_11111111_11111111_1111_1111) | (_rotation << 32);
        
        return self;
    }
    
    static get_rotation = function()
    {
        return (___value >> 32) & 0b111111111;
    }
    
    static set_component = function(_name, _value)
    {
        self[$ "___component"] ??= {}
        self[$ "___component_length"] ??= 0;
        
        ___component[$ _name] = _name;
        
        return self;
    }
    
    static get_component = function(_name)
    {
        var _component = self[$ "___component"];
        
        if (_component == undefined)
        {
            return undefined;
        }
        
        if (_name == undefined)
        {
            return undefined;
        }
        
        return _component[$ _name];
    }
    
    static get_component_names = function(_name)
    {
        var _component = self[$ "___component"];
        
        if (_component == undefined)
        {
            return undefined;
        }
        
        return struct_get_names(_component);
    }
    
    static get_component_length = function()
    {
        return self[$ "___component_length"] ?? 0;
    }
    
    var _data = _item_data[$ get_id()];
    
    var _inventory_length = _data.get_tile_inventory_length();
    
    if (_inventory_length > 0)
    {
        ___inventory = array_create(_inventory_length, INVENTORY_EMPTY);
    }
    
    static set_inventory = function(_inventory)
    {
        ___inventory = _inventory;
        
        return self;
    }
    
    static get_inventory = function()
    {
        return self[$ "___inventory"];
    }
    
    static set_instance_light = function(_id)
    {
        ___instance_light = _id;
        
        return self;
    }
    
    static get_instance_light = function()
    {
        return self[$ "___instance_light"] ?? noone;
    }
    
    static set_instance_crafting_station = function(_id)
    {
        ___instance_crafting_station = _id;
        
        return self;
    }
    
    static get_instance_crafting_station = function()
    {
        return self[$ "___instance_crafting_station"] ?? noone;
    }
    
    static set_instance_container = function(_id)
    {
        ___instance_container = _id;
        
        return self;
    }
    
    static get_instance_container = function()
    {
        return self[$ "___instance_container"] ?? noone;
    }
}