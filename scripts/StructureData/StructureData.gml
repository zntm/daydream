enum STRUCTURE_PLACEMENT_TYPE {
    FLOOR,
    CEILING,
    INSIDE
}

function StructureData(_width, _height, _placement, _is_persistent, _is_natural) constructor
{
    ___width  = _width;
    ___height = _height;
    
    ___value = (_is_persistent << 1) | _is_natural;
    
    static get_width = function()
    {
        return ___width;
    }
    
    static get_height = function()
    {
        return ___height;
    }
    
    static is_natural = function()
    {
        return !!(___value & (1 << 0));
    }
    
    static is_persistent = function()
    {
        return !!(___value & (1 << 1));
    }
    
    static __structure_placement_type = {
        "floor":   STRUCTURE_PLACEMENT_TYPE.FLOOR,
        "ceiling": STRUCTURE_PLACEMENT_TYPE.CEILING,
        "inside":  STRUCTURE_PLACEMENT_TYPE.INSIDE
    }
    
    var _placement_offset = _placement.offset;
    
    ___placement_value = ((_placement_offset.y + 0x80) << 16) | ((_placement_offset.x + 0x80) << 8) | __structure_placement_type[$ _placement.type];
    
    static get_placement_type = function()
    {
        return ___placement_value & 0xff;
    }
    
    static get_placement_xoffset = function()
    {
        return ((___placement_value >> 8) & 0xff) - 0x80;
    }
    
    static get_placement_yoffset = function()
    {
        return ((___placement_value >> 16) & 0xff) - 0x80;
    }
    
    static set_parameter = function(_array)
    {
        ___parameter = _array;
        
        return self;
    }
    
    static get_parameter = function()
    {
        return self[$ "___parameter"];
    }
    
    static set_data = function(_function)
    {
        ___data = _function;
        
        return self;
    }
    
    static get_data = function()
    {
        return ___data;
    }
}

global.structure_data = {}

function init_structure(_directory, _namespace = "phantasia", _type = 0)
{
    /*
    if (_type & INIT_TYPE.RESET)
    {
        init_data_reset("structure_data");
    }
    */
    init_structure_recursive(_directory, _namespace, undefined);
}