
/// @desc Proglang Standard Library Registry

global.proglang_functions = {}

function proglang_function_register(_name, _func)
{
    global.proglang_functions[$ _name] = {
        name: _name,
        func: _func
    }
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

proglang_function_register("exp", function(_args) { return exp(_args[0]); });
proglang_function_register("ln", function(_args) { return ln(_args[0]); });
proglang_function_register("log2", function(_args) { return log2(_args[0]); });
proglang_function_register("log10", function(_args) { return log10(_args[0]); });
proglang_function_register("sqr", function(_args) { return sqr(_args[0]); });
proglang_function_register("frac", function(_args) { return frac(_args[0]); });
proglang_function_register("arcsin", function(_args) { return arcsin(_args[0]); });
proglang_function_register("arccos", function(_args) { return arccos(_args[0]); });
proglang_function_register("arctan", function(_args) { return arctan(_args[0]); });
proglang_function_register("arctan2", function(_args) { return arctan2(_args[0], _args[1]); });
proglang_function_register("degtorad", function(_args) { return degtorad(_args[0]); });
proglang_function_register("radtodeg", function(_args) { return radtodeg(_args[0]); });

// Random
// Random
proglang_function_register("random", function(_args) { return random(_args[0]); });
proglang_function_register("irandom", function(_args) { return irandom(_args[0]); });
proglang_function_register("random_range", function(_args) { return random_range(_args[0], _args[1]); });
proglang_function_register("irandom_range", function(_args) { return irandom_range(_args[0], _args[1]); });
proglang_function_register("choose", function(_args) {
    // Proglang 'choose' takes a single array argument
    var _arr = _args[0];
    if (!is_array(_arr) || array_length(_arr) == 0) return undefined;
    var _idx = irandom(array_length(_arr) - 1);
    return _arr[_idx];
});

// Strings & Types
proglang_function_register("string", function(_args) { return string(_args[0]); });
proglang_function_register("is_string", function(_args) { return is_string(_args[0]); });
proglang_function_register("is_real", function(_args) { return is_real(_args[0]); });
proglang_function_register("is_numeric", function(_args) { return is_numeric(_args[0]); });
proglang_function_register("is_bool", function(_args) { return is_bool(_args[0]); });
proglang_function_register("is_array", function(_args) { return is_array(_args[0]); });
proglang_function_register("is_struct", function(_args) { return is_struct(_args[0]); });
proglang_function_register("is_undefined", function(_args) { return is_undefined(_args[0]); });
proglang_function_register("real", function(_args) { return real(_args[0]); });

proglang_function_register("string_length", function(_args) { return string_length(_args[0]); });
proglang_function_register("string_pos", function(_args) { return string_pos(_args[0], _args[1]); });
proglang_function_register("string_copy", function(_args) { return string_copy(_args[0], _args[1], _args[2]); });
proglang_function_register("string_char_at", function(_args) { return string_char_at(_args[0], _args[1]); });
proglang_function_register("string_delete", function(_args) { return string_delete(_args[0], _args[1], _args[2]); });
proglang_function_register("string_insert", function(_args) { return string_insert(_args[0], _args[1], _args[2]); });
proglang_function_register("string_replace", function(_args) { return string_replace(_args[0], _args[1], _args[2]); });
proglang_function_register("string_replace_all", function(_args) { return string_replace_all(_args[0], _args[1], _args[2]); });
proglang_function_register("string_upper", function(_args) { return string_upper(_args[0]); });
proglang_function_register("string_lower", function(_args) { return string_lower(_args[0]); });
proglang_function_register("string_width", function(_args) { return string_width(_args[0]); });
proglang_function_register("string_height", function(_args) { return string_height(_args[0]); });
proglang_function_register("chr", function(_args) { return chr(_args[0]); });
proglang_function_register("ord", function(_args) { return ord(_args[0]); });

// Data Structures
// Data Structures
proglang_function_register("array_length", function(_args) { return array_length(_args[0]); });
proglang_function_register("array_push", function(_args) { 
    var _arr = _args[0];
    for(var i=1; i<array_length(_args); i++) array_push(_arr, _args[i]);
});
proglang_function_register("array_pop", function(_args) { return array_pop(_args[0]); });
proglang_function_register("array_resize", function(_args) { array_resize(_args[0], _args[1]); });
proglang_function_register("array_copy", function(_args) { array_copy(_args[0], _args[1], _args[2], _args[3], _args[4]); });
proglang_function_register("array_contains", function(_args) { return array_contains(_args[0], _args[1]); });
proglang_function_register("struct_get_names", function(_args) { return struct_get_names(_args[0]); });
proglang_function_register("struct_exists", function(_args) { return struct_exists(_args[0], _args[1]); });
proglang_function_register("struct_get", function(_args) { return struct_get(_args[0], _args[1]); });
proglang_function_register("struct_set", function(_args) { struct_set(_args[0], _args[1], _args[2]); });
proglang_function_register("struct_names_count", function(_args) { return struct_names_count(_args[0]); });
proglang_function_register("struct_stringify", function(_args) { return json_stringify(_args[0]); });
proglang_function_register("struct_parse", function(_args) { return json_parse(_args[0]); });

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
    show_debug_message($"[Daydream] {_msg}");
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
        if (struct_exists(_val, "__type__") && _val.__type__ == "regex") return "regex";
        // Check for class instance
        if (struct_exists(_val, "__class__")) return "object";
        return "struct";
    }
    if (is_method(_val)) return "function";
    return "unknown";
});

proglang_function_register("is_regex", function(_args) {
    var _val = _args[0];
    return is_struct(_val) && struct_exists(_val, "__type__") && _val.__type__ == "regex";
});

// Debug & Utils
proglang_function_register("show_debug_message", function(_args) { show_debug_message(_args[0]); });

proglang_function_register("assert", function(_args) {
    if (!_args[0]) {
        var _msg = (array_length(_args) > 1) ? _args[1] : "Assertion failed";
        throw { type: PROG_ERROR.RUNTIME, message: _msg }
    }
});

proglang_function_register("time_start", function(_args) {
    var _name = _args[0];
    if (!variable_global_exists("proglang_timers")) global.proglang_timers = {}
    global.proglang_timers[$ _name] = get_timer();
});

proglang_function_register("time_end", function(_args) {
    var _name = _args[0];
    if (!variable_global_exists("proglang_timers") || !struct_exists(global.proglang_timers, _name)) {
        throw { type: PROG_ERROR.RUNTIME, message: $"Timer '{_name}' does not exist." }
    }
    var _start = global.proglang_timers[$ _name];
    var _time = (get_timer() - _start) / 1000; // ms
    struct_remove(global.proglang_timers, _name);
    return _time;
});

// Regex
proglang_function_register("regex_parse", function(_args) { return new Regex(_args[0], array_length(_args)>1 ? _args[1] : ""); });
proglang_function_register("regex_test", function(_args) { 
    if (!is_struct(_args[1]) || !struct_exists(_args[1], "test")) {
            throw { type: PROG_ERROR.TYPE, message: "Expected regex object." }
    }
    return _args[1].test(_args[0]); 
});
proglang_function_register("regex_match", function(_args) { return _args[1].match(_args[0]); });
proglang_function_register("regex_match_index", function(_args) { return _args[1].match_index(_args[0]); });
proglang_function_register("regex_replace", function(_args) { return _args[1].replace(_args[0], _args[2]); });
proglang_function_register("regex_replace_all", function(_args) { return _args[1].replace(_args[0], _args[2]); });
proglang_function_register("regex_split", function(_args) { return _args[1].split(_args[0]); });
