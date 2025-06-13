function Tile(_id, _item_data = global.item_data) constructor
{
    ___id = _id;
    
    static get_id = function()
    {
        return self[$ "___id"];
    }
    
    static set_variant = function(_variant)
    {
        ___variant = _variant;
        
        return self;
    }
    
    static get_variant = function()
    {
        return self[$ "___variant"];
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
        ___value = (___value & 0b111111111_0000_0000_11111111_11111111_1111_1111) | ((_yscale + 8) << 28) | ((_xscale + 8) << 24);
        
        return self;
    }
    
    static set_xscale = function(_xscale)
    {
        ___value = (___value & 0b111111111_1111_0000_11111111_11111111_1111_1111) | ((_xscale + 8) << 24);
        
        return self;
    }
    
    static set_yscale = function(_yscale)
    {
        ___value = (___value & 0b111111111_0000_1111_11111111_11111111_1111_1111) | ((_yscale + 8) << 28);
        
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
        ___value = (___value & 0b111111111_1111_1111_00000000_11111111_1111_1111) | (_index << 16);
        
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
    }
    
    static get_rotation = function()
    {
        return (___value >> 32) & 0b111111111;
    }
}