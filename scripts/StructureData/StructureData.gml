enum STRUCTURE_PLACEMENT_TYPE {
    FLOOR,
    CEILING,
    INSIDE
}

enum STRUCTURE_TERRAIN_MODIFIER_TYPE {
    NONE,
    CLEAR,    // Village-style: clear surface above structure
    CARVE,    // Trial chamber-style: carve into terrain
    ELEVATE   // Raise terrain around structure
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
    ___placement_type = __structure_placement_type[$ _placement[$ "type"]];
    ___placement_if_clear = _placement[$ "if_clear"] ?? false;
    
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
    
    static get_placement_xoffset = function()
    {
        return ___placement_xoffset;
    }
    
    static get_placement_yoffset = function()
    {
        return ___placement_yoffset;
    }
    
    static get_placement_type = function()
    {
        return ___placement_type;
    }
    
    static get_if_clear = function()
    {
        return ___placement_if_clear;
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
    
    static set_data = function(_data)
    {
        ___data = _data;
        
        return self;
    }
    
    static get_data = function()
    {
        return self[$ "___data"];
    }
    
    static set_function = function(_id, _parameters)
    {
        ___function_id = _id;
        ___function_parameters = _parameters;
        
        return self;
    }
    
    static get_function_id = function()
    {
        return ___function_id;
    }
    
    static get_function_parameters = function()
    {
        return ___function_parameters;
    }
    
    static __terrain_modifier_type = {
        "clear":   STRUCTURE_TERRAIN_MODIFIER_TYPE.CLEAR,
        "carve":   STRUCTURE_TERRAIN_MODIFIER_TYPE.CARVE,
        "elevate": STRUCTURE_TERRAIN_MODIFIER_TYPE.ELEVATE
    }
    
    static set_terrain_modifier = function(_modifier)
    {
        if (_modifier != undefined)
        {
            ___terrain_modifier_type = __terrain_modifier_type[$ _modifier.type] ?? STRUCTURE_TERRAIN_MODIFIER_TYPE.NONE;
            ___terrain_modifier_depth = _modifier[$ "depth"] ?? 0;
            ___terrain_modifier_radius = _modifier[$ "radius"];
            ___terrain_modifier_blend = _modifier[$ "blend"] ?? true;
            ___value |= 1 << 3;
        }
        
        return self;
    }
    
    static has_terrain_modifier = function()
    {
        return !!(___value & (1 << 3));
    }
    
    static get_terrain_modifier_type = function()
    {
        return self[$ "___terrain_modifier_type"] ?? STRUCTURE_TERRAIN_MODIFIER_TYPE.NONE;
    }
    
    static get_terrain_modifier_depth = function()
    {
        return self[$ "___terrain_modifier_depth"] ?? 0;
    }
    
    static get_terrain_modifier_radius = function()
    {
        return self[$ "___terrain_modifier_radius"];
    }
    
    static get_terrain_modifier_blend = function()
    {
        return self[$ "___terrain_modifier_blend"] ?? true;
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