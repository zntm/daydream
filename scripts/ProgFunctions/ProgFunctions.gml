
/// @desc Proglang Standard Library Registry


global.proglang_macros = {};
// Defines global macros/constants accessible to all scripts.
// Can be values or functions (getters).

global.proglang_functions = {};

function proglang_function_register(_name, _func) {
    global.proglang_functions[$ _name] = {
        name: _name,
        func: _func
    };
}

// Math
proglang_function_register("floor", function(_args) { return floor(_args[0]); });
proglang_function_register("ceil", function(_args) { return ceil(_args[0]); });
proglang_function_register("round", function(_args) { return round(_args[0]); });
proglang_function_register("abs", function(_args) { return abs(_args[0]); });
proglang_function_register("sign", function(_args) { return sign(_args[0]); });
proglang_function_register("min", function(_args) { return min(_args[0], _args[1]); });
proglang_function_register("max", function(_args) { return max(_args[0], _args[1]); });
proglang_function_register("clamp", function(_args) { return clamp(_args[0], _args[1], _args[2]); });
proglang_function_register("lerp", function(_args) { return lerp(_args[0], _args[1], _args[2]); });
proglang_function_register("power", function(_args) { return power(_args[0], _args[1]); });
proglang_function_register("sqrt", function(_args) { return sqrt(_args[0]); });
proglang_function_register("sin", function(_args) { return sin(_args[0]); });
proglang_function_register("cos", function(_args) { return cos(_args[0]); });
proglang_function_register("tan", function(_args) { return tan(_args[0]); });
proglang_function_register("dsin", function(_args) { return dsin(_args[0]); });
proglang_function_register("dcos", function(_args) { return dcos(_args[0]); });
proglang_function_register("dtan", function(_args) { return dtan(_args[0]); });
proglang_function_register("lengthdir_x", function(_args) { return lengthdir_x(_args[0], _args[1]); });
proglang_function_register("lengthdir_y", function(_args) { return lengthdir_y(_args[0], _args[1]); });
proglang_function_register("point_distance", function(_args) { return point_distance(_args[0], _args[1], _args[2], _args[3]); });
proglang_function_register("point_direction", function(_args) { return point_direction(_args[0], _args[1], _args[2], _args[3]); });

// Random
proglang_function_register("random", function(_args) { return random(_args[0]); });
proglang_function_register("irandom", function(_args) { return irandom(_args[0]); });
proglang_function_register("random_range", function(_args) { return random_range(_args[0], _args[1]); });
proglang_function_register("irandom_range", function(_args) { return irandom_range(_args[0], _args[1]); });
proglang_function_register("choose", function(_args) { 
    var _idx = irandom(array_length(_args) - 1);
    return _args[_idx];
});

// Strings & Types
proglang_function_register("string", function(_args) { return string(_args[0]); });
proglang_function_register("is_string", function(_args) { return is_string(_args[0]); });
proglang_function_register("is_real", function(_args) { return is_real(_args[0]); });
proglang_function_register("is_array", function(_args) { return is_array(_args[0]); });
proglang_function_register("is_struct", function(_args) { return is_struct(_args[0]); });
proglang_function_register("is_undefined", function(_args) { return is_undefined(_args[0]); });

// Data Structures
proglang_function_register("array_length", function(_args) { return array_length(_args[0]); });
proglang_function_register("array_push", function(_args) { array_push(_args[0], _args[1]); });
proglang_function_register("array_pop", function(_args) { return array_pop(_args[0]); });
proglang_function_register("array_contains", function(_args) { return array_contains(_args[0], _args[1]); });
proglang_function_register("struct_get_names", function(_args) { return struct_get_names(_args[0]); });

// Game API
proglang_function_register("tile_place", function(_args, _ctx) { 
    // tile_place(x, y, z, id)
    // Coords are usually relative if using _ctx.x/y? Or absolute?
    // GML scripts usually perform absolute.
    // If user writes `tile_place(x, y, z, ...)` they use context `x`.
    // So arguments are passed as is.
    
    // Safety check for TILE_EMPTY?
    var _id = _args[3];
    if (is_string(_id)) _id = new Tile(_id);
    else if (_id == undefined) _id = TILE_EMPTY;
    
    tile_place(_args[0], _args[1], _args[2], _id);
    tile_update_surrounding(_args[0], _args[1], _args[2]);
});

proglang_function_register("tile_get", function(_args) { 
    return tile_get(_args[0], _args[1], _args[2]);
});

proglang_function_register("spawn_particle", function(_args) { 
    // spawn_particle(x, y, id)
    spawn_particle(_args[0], _args[1], smart_value(_args[2]));
});

proglang_function_register("sfx_play", function(_args) { 
    // sfx_play(x, y, id) - simple positional audio
    // Or just play sound?
    sfx_diegetic_play(undefined, _args[0], _args[1], smart_value(_args[2]));
});

// Print - variadic debug output (alias for show_debug_message)
proglang_function_register("print", function(_args) { 
    var _msg = "";
    for (var i = 0; i < array_length(_args); i++) {
        if (i > 0) _msg += " ";
        _msg += string(_args[i]);
    }
    show_debug_message($"[Proglang] {_msg}");
});

// Type checking
proglang_function_register("typeof", function(_args) {
    var _val = _args[0];
    if (is_undefined(_val)) return "undefined";
    if (is_bool(_val)) return "boolean";
    if (is_real(_val)) return "number";
    if (is_string(_val)) return "string";
    if (is_array(_val)) return "array";
    if (is_struct(_val)) {
        // Check for class instance
        if (variable_struct_exists(_val, "__class__")) return "object";
        return "struct";
    }
    if (is_method(_val)) return "function";
    return "unknown";
});
