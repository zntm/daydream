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
    
    static has_clearance_condition = function()
    {
        return !!(___value & (1 << 2));
    }
    
    static __structure_placement_type = {
        "floor":   STRUCTURE_PLACEMENT_TYPE.FLOOR,
        "ceiling": STRUCTURE_PLACEMENT_TYPE.CEILING,
        "inside":  STRUCTURE_PLACEMENT_TYPE.INSIDE
    }
    
    ___placement_value = __structure_placement_type[$ _placement.type];
    
    ___placement_xoffset = _placement[$ "xoffset"];
    ___placement_yoffset = _placement[$ "yoffset"];
    
    var _clearance_condition = _placement[$ "clearance_condition"];
    
    if (_clearance_condition != undefined)
    {
        ___placement_clearance_condition = [];
        ___placement_clearance_condition_length = array_length(_clearance_condition);
        
        for (var i = 0; i < ___placement_clearance_condition_length; ++i)
        {
            var _data = _clearance_condition[i];
            
            array_push(___placement_clearance_condition, {
                xoffset: _data[$ "xoffset"] ?? 0,
                yoffset: _data[$ "yoffset"] ?? 0,
                width:  _data.width,
                height: _data.height
            });
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
    
    static get_placement_clearance_condition = function()
    {
        return ___placement_clearance_condition;
    }
    
    static get_placement_clearance_condition_length = function()
    {
        return ___placement_clearance_condition_length;
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