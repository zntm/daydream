/// @desc Initialize Proglang environment
function proglang_init() {
    // Clear bytecode cache to ensure fresh compilation after hot-reload
    if (variable_global_exists("proglang_cache")) {
        global.proglang_cache = {};
    }
    
    // Global function registry
    if (!variable_global_exists("proglang_functions")) {
        global.proglang_functions = {};
    }
    
    // Global script registry
    if (!variable_global_exists("proglang_scripts")) {
        global.proglang_scripts = {};
    }
    
    // Global module registry
    if (!variable_global_exists("proglang_modules")) {
        global.proglang_modules = {};
    }
    
    // Global constants
    if (!variable_global_exists("proglang_constants")) {
        global.proglang_constants = {};
    }
    
    // Expose PROG_ERROR enum
    global.proglang_constants.PROG_ERROR = {
        NONE: PROG_ERROR.NONE,
        RUNTIME: PROG_ERROR.RUNTIME,
        TYPE: PROG_ERROR.TYPE,
        INDEX: PROG_ERROR.INDEX,
        MEMBER: PROG_ERROR.MEMBER,
        VARIABLE: PROG_ERROR.VARIABLE,
        DIVIDE_BY_ZERO: PROG_ERROR.DIVIDE_BY_ZERO,
        UNDEFINED_VALUE: PROG_ERROR.UNDEFINED_VALUE,
        NULL_REFERENCE: PROG_ERROR.NULL_REFERENCE,
        INVALID_ARGUMENT: PROG_ERROR.INVALID_ARGUMENT,
        NOT_CALLABLE: PROG_ERROR.NOT_CALLABLE,
        SYNTAX: PROG_ERROR.SYNTAX,
        IMPORT: PROG_ERROR.IMPORT
    };
    
    // Helper to register built-ins
    var _reg = function(_name, _func) {
        global.proglang_functions[$ _name] = { func: _func };
    };
    
    // Math
    _reg("max", function(_args) { 
        if (array_length(_args) == 0) return 0;
        if (array_length(_args) == 1 && is_array(_args[0])) {
            // max(arr) - not standard GML but useful
             var _arr = _args[0];
             var _m = -999999999;
             for(var i=0; i<array_length(_arr); i++) _m = max(_m, _arr[i]);
             return _m;
        }
        if (array_length(_args) == 2) return max(_args[0], _args[1]);
        var _m = _args[0];
        for(var i=1; i<array_length(_args); i++) _m = max(_m, _args[i]);
        return _m;
    });
    _reg("min", function(_args) { 
         if (array_length(_args) == 0) return 0;
         if (array_length(_args) == 2) return min(_args[0], _args[1]);
         var _m = _args[0];
         for(var i=1; i<array_length(_args); i++) _m = min(_m, _args[i]);
         return _m;
    });
    _reg("abs", function(_args) { return abs(_args[0]); });
    _reg("round", function(_args) { return round(_args[0]); });
    _reg("floor", function(_args) { return floor(_args[0]); });
    _reg("ceil", function(_args) { return ceil(_args[0]); });
    _reg("sign", function(_args) { return sign(_args[0]); });
    _reg("frac", function(_args) { return frac(_args[0]); });
    _reg("sqrt", function(_args) { return sqrt(_args[0]); });
    _reg("sqr", function(_args) { return sqr(_args[0]); });
    _reg("power", function(_args) { return power(_args[0], _args[1]); });
    _reg("exp", function(_args) { return exp(_args[0]); });
    _reg("ln", function(_args) { return ln(_args[0]); });
    _reg("log2", function(_args) { return log2(_args[0]); });
    _reg("log10", function(_args) { return log10(_args[0]); });
    _reg("sin", function(_args) { return sin(_args[0]); });
    _reg("cos", function(_args) { return cos(_args[0]); });
    _reg("tan", function(_args) { return tan(_args[0]); });
    _reg("arcsin", function(_args) { return arcsin(_args[0]); });
    _reg("arccos", function(_args) { return arccos(_args[0]); });
    _reg("arctan", function(_args) { return arctan(_args[0]); });
    _reg("arctan2", function(_args) { return arctan2(_args[0], _args[1]); });
    _reg("degtorad", function(_args) { return degtorad(_args[0]); });
    _reg("radtodeg", function(_args) { return radtodeg(_args[0]); });
    _reg("random", function(_args) { return random(_args[0]); });
    _reg("random_range", function(_args) { return random_range(_args[0], _args[1]); });
    _reg("irandom", function(_args) { return irandom(_args[0]); });
    _reg("irandom_range", function(_args) { return irandom_range(_args[0], _args[1]); });
    _reg("clamp", function(_args) { return clamp(_args[0], _args[1], _args[2]); });
    _reg("lerp", function(_args) { return lerp(_args[0], _args[1], _args[2]); });
    
    // Types
    _reg("is_string", function(_args) { return is_string(_args[0]); });
    _reg("is_real", function(_args) { return is_real(_args[0]); });
    _reg("is_numeric", function(_args) { return is_numeric(_args[0]); });
    _reg("is_bool", function(_args) { return is_bool(_args[0]); });
    _reg("is_array", function(_args) { return is_array(_args[0]); });
    _reg("is_struct", function(_args) { return is_struct(_args[0]); });
    _reg("is_undefined", function(_args) { return is_undefined(_args[0]); });
    _reg("typeof", function(_args) { return typeof(_args[0]); });
    _reg("string", function(_args) { return string(_args[0]); });
    _reg("real", function(_args) { return real(_args[0]); });
    
    // Strings
    _reg("string_length", function(_args) { return string_length(_args[0]); });
    _reg("string_pos", function(_args) { return string_pos(_args[0], _args[1]); });
    _reg("string_copy", function(_args) { return string_copy(_args[0], _args[1], _args[2]); });
    _reg("string_char_at", function(_args) { return string_char_at(_args[0], _args[1]); });
    _reg("string_delete", function(_args) { return string_delete(_args[0], _args[1], _args[2]); });
    _reg("string_insert", function(_args) { return string_insert(_args[0], _args[1], _args[2]); });
    _reg("string_replace", function(_args) { return string_replace(_args[0], _args[1], _args[2]); });
    _reg("string_replace_all", function(_args) { return string_replace_all(_args[0], _args[1], _args[2]); });
    _reg("string_upper", function(_args) { return string_upper(_args[0]); });
    _reg("string_lower", function(_args) { return string_lower(_args[0]); });
    _reg("string_width", function(_args) { return string_width(_args[0]); });
    _reg("string_height", function(_args) { return string_height(_args[0]); });
    _reg("chr", function(_args) { return chr(_args[0]); });
    _reg("ord", function(_args) { return ord(_args[0]); });
    
    // Arrays
    _reg("array_length", function(_args) { return array_length(_args[0]); });
    _reg("array_resize", function(_args) { array_resize(_args[0], _args[1]); return 0; });
    _reg("array_copy", function(_args) { array_copy(_args[0], _args[1], _args[2], _args[3], _args[4]); return 0; });
    _reg("array_pop", function(_args) { return array_pop(_args[0]); });
    _reg("array_push", function(_args) { 
        var _arr = _args[0]; // Reference
        for(var i=1; i<array_length(_args); i++) array_push(_arr, _args[i]);
        return 0; 
    });
    
    // Structs
    _reg("variable_struct_exists", function(_args) { return variable_struct_exists(_args[0], _args[1]); });
    _reg("variable_struct_get", function(_args) { return variable_struct_get(_args[0], _args[1]); });
    _reg("variable_struct_set", function(_args) { variable_struct_set(_args[0], _args[1], _args[2]); return 0; });
    _reg("variable_struct_names_count", function(_args) { return variable_struct_names_count(_args[0]); });
    _reg("variable_struct_get_names", function(_args) { return variable_struct_get_names(_args[0]); });
    
    // Output
    _reg("show_debug_message", function(_args) { show_debug_message(_args[0]); return 0; });
    _reg("print", function(_args) { show_debug_message(_args[0]); return 0; });
}
