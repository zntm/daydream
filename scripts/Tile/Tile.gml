function Tile(_id, _item_data = global.item_data) constructor
{
    ___id = _id;
    
    get_id = function()
    {
        return ___id;
    }
    
    var _data = _item_data[$ _id];
    
    if (_data == undefined)
    {
        get_tile_components_length = function() { return 0; }
        get_tile_inventory_length = function() { return 0; }
        get_tile_components_names = function() { return []; }
        get_components_length = function() { return 0; }
        get_component = function() { return undefined; }
        get_inventory = function() { return undefined; }
        
        show_debug_message($"[TILE] Warning: Created tile with invalid ID: {_id}");
        exit; 
    }
    
    // set_offset(0, 0);
    // set_scale(1, 1);
    // ___value = 0;
    
    ___value = (9 << 28) | (9 << 24) | (8 << 4) | (8 << 0);
    
    set_offset = function(_xoffset, _yoffset)
    {
        ___value = (___value & 0b111111111_1111_1111_11111111_11111111_0000_0000) | ((_yoffset + 8) << 4) | ((_xoffset + 8) << 0);
        
        return self;
    }
    
    set_xoffset = function(_xoffset)
    {
        ___value = (___value & 0b111111111_1111_0000_11111111_11111111_1111_0000) | ((_xoffset + 8) << 0);
        
        return self;
    }
    
    set_yoffset = function(_yoffset)
    {
        ___value = (___value & 0b111111111_0000_1111_11111111_11111111_0000_1111) | ((_yoffset + 8) << 4);
        
        return self;
    }
    
    get_xoffset = function()
    {
        return ((___value >> 0) & 0b1111) - 8;
    }
    
    get_yoffset = function()
    {
        return ((___value >> 4) & 0b1111) - 8;
    }
    
    set_scale = function(_xscale, _yscale)
    {
        // ___value = (___value & 0b111111111_0000_0000_11111111_11111111_1111_1111) | ((_yscale + 8) << 28) | ((_xscale + 8) << 24);
        
        set_xscale(_xscale);
        set_yscale(_yscale);
        
        return self;
    }
    
    set_xscale = function(_xscale)
    {
        if (_xscale != undefined)
        {
            ___value = (___value & 0b111111111_1111_0000_11111111_11111111_1111_1111) | ((_xscale + 8) << 24);
        }
        
        return self;
    }
    
    set_yscale = function(_yscale)
    {
        if (_yscale != undefined)
        {
            ___value = (___value & 0b111111111_1111_0000_11111111_11111111_1111_1111) | ((_yscale + 8) << 24);
        }
        
        // ___value = (___value & 0b111111111_0000_1111_11111111_11111111_1111_1111) | ((_yscale + 8) << 28);
        
        return self;
    }
    
    get_xscale = function()
    {
        return ((___value >> 24) & 0b1111) - 8;
    }
    
    get_yscale = function()
    {
        return ((___value >> 28) & 0b1111) - 8;
    }
    
    set_index = function(_index)
    {
        ___value = (___value & 0b111111111_1111_1111_11111111_00000000_1111_1111) | (_index << 8);
        
        return self;
    }
    
    get_index = function()
    {
        return (___value >> 8) & 0b11111111;
    }
    
    set_index_offset = function(_index)
    {
        if (_index != undefined)
        {
            ___value = (___value & 0b111111111_1111_1111_00000000_11111111_1111_1111) | (_index << 16);
        }
        
        return self;
    }
    
    get_index_offset = function()
    {
        return (___value >> 16) & 0b11111111;
    }
    
    set_rotation = function(_rotation)
    {
        _rotation = ((_rotation % 360) + 360) % 360;
        
        ___value = (___value & 0b000000000_1111_1111_11111111_11111111_1111_1111) | (_rotation << 32);
        
        return self;
    }
    
    get_rotation = function()
    {
        return (___value >> 32) & 0b111111111;
    }
    
    set_component = function(_name, _value)
    {
        self[$ "___components"] ??= {}
        
        var _data = global.item_data[$ get_id()];
        
        var _component = _data.get_tile_component(_name);
        
        // If component definition doesn't exist, just store the value directly
        if (_component == undefined)
        {
            ___components[$ _name] = _value;
            return self;
        }
        
        var _type = _component.type;
        
        if (_type == "string")
        {
            var _max = _component[$ "max"];
            
            if (_max != undefined) && (string_length(_value) > _max)
            {
                _value = string_copy(_value, 1, _max);
            }
        }
        else if (_type == "integer")
        {
            _value = floor(_value);
            
            var _min = _component[$ "min"];
            
            if (_min != undefined) && (_value < _min)
            {
                _value = _min;
            }
            
            var _max = _component[$ "max"];
            
            if (_max != undefined) && (_value > _max)
            {
                _value = _max;
            }
        }
        else if (_type == "float")
        {
            var _min = _component[$ "min"];
            
            if (_min != undefined) && (_value < _min)
            {
                _value = _min;
            }
            
            var _max = _component[$ "max"];
            
            if (_max != undefined) && (_value > _max)
            {
                _value = _max;
            }
        }
        
        ___components[$ _name] = _value;
        
        return self;
    }
    
    var _components_length = _data.get_tile_components_length();
    
    if (_components_length > 0)
    {
        ___components_length = _components_length;
        
        var _names = _data.get_tile_components_names();
        
        for (var i = 0; i < _components_length; ++i)
        {
            var _name = _names[i];
            
            var _ = _data.get_tile_component(_name);
            
            set_component(_name, _[$ "default"]);
        }
    }
    
    get_component = function(_name)
    {
        if (_name == undefined)
        {
            return undefined;
        }
        
        var _component = self[$ "___components"];
        
        if (_component == undefined)
        {
            return undefined;
        }
        
        return _component[$ _name];
    }
    
    get_components_length = function()
    {
        return self[$ "___components_length"] ?? 0;
    }
    
    var _inventory_length = _data.get_tile_inventory_length();
    
    if (_inventory_length > 0)
    {
        ___inventory = array_create(_inventory_length, INVENTORY_EMPTY);
    }
    
    set_inventory = function(_inventory)
    {
        ___inventory = _inventory;
        
        return self;
    }
    
    get_inventory = function()
    {
        return self[$ "___inventory"];
    }
    
    set_instance_light = function(_id)
    {
        ___instance_light = _id;
        
        return self;
    }
    
    get_instance_light = function()
    {
        return self[$ "___instance_light"] ?? noone;
    }
    
    set_instance_crafting_station = function(_id)
    {
        ___instance_crafting_station = _id;
        
        return self;
    }
    
    get_instance_crafting_station = function()
    {
        return self[$ "___instance_crafting_station"] ?? noone;
    }
    
    set_instance_container = function(_id)
    {
        ___instance_container = _id;
        
        return self;
    }
    
    get_instance_container = function()
    {
        return self[$ "___instance_container"] ?? noone;
    }
}