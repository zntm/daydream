function Tile(_item_id) constructor
{
    ___item_id = _item_id;
    
    static get_item_id = function()
    {
        return self[$ "___item_id"];
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
    
    ___value = 0;
    
    static set_scale = function(_xscale, _yscale)
    {
        ___value = (___value & 0b111111111_0000_0000_11111111_11111111) | ((_yscale + 8) << 20) | ((_xscale + 8) << 16);
        
        return self;
    }
    
    static set_xscale = function(_xscale)
    {
        ___value = (___value & 0b111111111_1111_0000_11111111_11111111) | ((_xscale + 8) << 16);
        
        return self;
    }
    
    static set_yscale = function(_yscale)
    {
        ___value = (___value & 0b111111111_0000_1111_11111111_11111111) | ((_yscale + 8) << 20);
        
        return self;
    }
    
    static get_xscale = function()
    {
        return ((___value >> 16) & 0b1111) - 8;
    }
    
    static get_yscale = function()
    {
        return ((___value >> 20) & 0b1111) - 8;
    }
    
    static set_index = function(_index)
    {
        ___value = (___value & 0b111111111_1111_1111_11111111_00000000) | (_index << 0);
        
        return self;
    }
    
    static get_index = function()
    {
        return (___value >> 0) & 0b11111111;
    }
    
    static set_index_offset = function(_index)
    {
        ___value = (___value & 0b111111111_1111_1111_00000000_11111111) | (_index << 8);
        
        return self;
    }
    
    static get_index_offset = function()
    {
        return (___value >> 8) & 0b11111111;
    }
    
    static set_rotation = function(_rotation)
    {
        _rotation = ((_rotation % 360) + 360) % 360;
        
        ___value = (___value & 0b000000000_1111_1111_11111111_11111111) | (_rotation << 24);
    }
    
    static get_rotation = function()
    {
        return (___value >> 24) & 0b111111111;
    }
    
    set_scale(1, 1);
}