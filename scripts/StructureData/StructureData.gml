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
    
    static has_if_clear = function()
    {
        return !!(___value & (1 << 2));
    }
    
    static __structure_placement_type = {
        "floor":   STRUCTURE_PLACEMENT_TYPE.FLOOR,
        "ceiling": STRUCTURE_PLACEMENT_TYPE.CEILING,
        "inside":  STRUCTURE_PLACEMENT_TYPE.INSIDE
    }
    
    var _placement_offset = _placement.offset;
    
    ___placement_value = __structure_placement_type[$ _placement.type];
    
    ___placement_xoffset = _placement_offset.x;
    ___placement_yoffset = _placement_offset.y;
    
    var _if_clear = _placement[$ "if_clear"];
    
    if (_if_clear != undefined)
    {
        ___placement_if_clear_length = array_length(_if_clear);
        ___placement_if_clear = array_create(___placement_if_clear_length);
        
        for (var i = 0; i < ___placement_if_clear_length; ++i)
        {
            var _data = _if_clear[i];
            var _offset = _data.offset;
            
            ___placement_if_clear[@ i] = {
                xoffset: _offset.x,
                yoffset: _offset.y,
                width:  _data.width,
                height: _data.height
            }
        }
        
        ___value |= 1 << 2;
    }
    
    static get_placement_type = function()
    {
        return ___placement_value;
    }
    
    static get_placement_xoffset = function()
    {
        return ___placement_xoffset;
    }
    
    static get_placement_yoffset = function()
    {
        return ___placement_yoffset;
    }
    
    static get_placement_if_clear = function()
    {
        return ___placement_if_clear;
    }
    
    static get_placement_if_clear_length = function()
    {
        return ___placement_if_clear_length;
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