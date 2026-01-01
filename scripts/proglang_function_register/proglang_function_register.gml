global.proglang_functions = {}
global.proglang_classes = {}

function proglang_function_register(_name, _func)
{
    global.proglang_functions[$ _name] = {
        name: _name,
        "function": _func
    }
}

#region Game API
/*
// Tile Operations
proglang_function_register("tile_get", function(_args)
{
    return tile_get(_args[0], _args[1], _args[2]);
});

proglang_function_register("tile_place", function(_args)
{
    var _x = _args[0];
    var _y = _args[1];
    var _z = _args[2];
    var _id = _args[3];
    
    if (is_string(_id)) _id = new Tile(_id);
    else if (_id == undefined) _id = TILE_EMPTY;
    
    tile_place(_x, _y, _z, _id);
    tile_update_surrounding(_x, _y, _z);
});

proglang_function_register("tile_update_surrounding", function(_args)
{
    tile_update_surrounding(_args[0], _args[1], _args[2]);
});

// Particle & Audio
proglang_function_register("spawn_particle", function(_args)
{
    spawn_particle(_args[0], _args[1], smart_value(_args[2]));
});

proglang_function_register("sfx_play", function(_args)
{
    var _emitter = (array_length(_args) > 3) ? _args[3] : undefined;
    sfx_diegetic_play(_emitter, _args[0], _args[1], smart_value(_args[2]));
});

proglang_function_register("spawn_projectile", function(_args)
{
    spawn_projectile(_args[0], _args[1], smart_value(_args[2]), _args[3], _args[4] ?? 1, _args[5] ?? 1);
});

// Events
proglang_function_register("event_emit", function(_args)
{
    event_emit(_args[0], _args[1]);
});
/*
// Game Constants
proglang_function_register("get_tile_size", function(_args)
{
    return TILE_SIZE;
});

proglang_function_register("get_chunk_depth", function(_args)
{
    return global.chunk_depth[$ _args[0]];
});

// Inventory
proglang_function_register("inventory_get_selected", function(_args)
{
    return global.inventory.base[global.inventory_selected_hotbar];
});

proglang_function_register("inventory_set_selected", function(_args)
{
    global.inventory.base[@ global.inventory_selected_hotbar] = _args[0];
    obj_Game_Control.surface_refresh |= SURFACE_REFRESH_BOOLEAN.INVENTORY_HOTBAR;
});

// Liquid Flow
proglang_function_register("liquid_flow_start", function(_args)
{
    liquid_flow_start(_args[0], _args[1], _args[2], _args[3] ?? {});
});

// Tick Delay  
proglang_function_register("tick_delay_add", function(_args)
{
    tick_delay_add(_args[0], _args[1], _args[2] ?? []);
});
*/
#endregion

#region Native Classes

// Register Tile and Inventory as native constructors
global.proglang_classes[$ "Tile"] = Tile;
global.proglang_classes[$ "Inventory"] = Inventory;

#endregion

#region Math

proglang_function_register("floor", function(_args)
{
    return floor(_args[0]);
});

proglang_function_register("ceil", function(_args)
{
    return ceil(_args[0]);
});

proglang_function_register("round", function(_args)
{
    return round(_args[0]);
});

proglang_function_register("abs", function(_args)
{
    return abs(_args[0]);
});

proglang_function_register("sign", function(_args)
{
    return sign(_args[0]);
});

proglang_function_register("min", function(_args)
{
    return min(_args[0], _args[1]);
});

proglang_function_register("max", function(_args)
{
    return max(_args[0], _args[1]);
});

proglang_function_register("clamp", function(_args)
{
    return clamp(_args[0], _args[1], _args[2]);
});

proglang_function_register("lerp", function(_args)
{
    return lerp(_args[0], _args[1], _args[2]);
});

proglang_function_register("power", function(_args)
{
    return power(_args[0], _args[1]);
});

proglang_function_register("sqrt", function(_args)
{
    return sqrt(_args[0]);
});

proglang_function_register("sin", function(_args)
{
    return sin(_args[0]);
});

proglang_function_register("cos", function(_args)
{
    return cos(_args[0]);
});

proglang_function_register("tan", function(_args)
{
    return tan(_args[0]);
});

proglang_function_register("dsin", function(_args)
{
    return dsin(_args[0]);
});

proglang_function_register("dcos", function(_args)
{
    return dcos(_args[0]);
});

proglang_function_register("dtan", function(_args)
{
    return dtan(_args[0]);
});

proglang_function_register("lengthdir_x", function(_args)
{
    return lengthdir_x(_args[0], _args[1]);
});

proglang_function_register("lengthdir_y", function(_args)
{
    return lengthdir_y(_args[0], _args[1]);
});

proglang_function_register("point_distance", function(_args)
{
    return point_distance(_args[0], _args[1], _args[2], _args[3]);
});

proglang_function_register("point_direction", function(_args)
{
    return point_direction(_args[0], _args[1], _args[2], _args[3]);
});

proglang_function_register("exp", function(_args)
{
    return exp(_args[0]);
});

proglang_function_register("ln", function(_args)
{
    return ln(_args[0]);
});

proglang_function_register("log2", function(_args)
{
    return log2(_args[0]);
});

proglang_function_register("log10", function(_args)
{
    return log10(_args[0]);
});

proglang_function_register("sqr", function(_args)
{
    return sqr(_args[0]);
});

proglang_function_register("frac", function(_args)
{
    return frac(_args[0]);
});

proglang_function_register("arcsin", function(_args)
{
    return arcsin(_args[0]);
});

proglang_function_register("arccos", function(_args)
{
    return arccos(_args[0]);
});

proglang_function_register("arctan", function(_args)
{
    return arctan(_args[0]);
});

proglang_function_register("arctan2", function(_args)
{
    return arctan2(_args[0], _args[1]);
});

proglang_function_register("degtorad", function(_args)
{
    return degtorad(_args[0]);
});

proglang_function_register("radtodeg", function(_args)
{
    return radtodeg(_args[0]);
});

#endregion

#region Random

proglang_function_register("random", function(_args)
{
    return random(_args[0]);
});

proglang_function_register("irandom", function(_args)
{
    return irandom(_args[0]);
});

proglang_function_register("random_range", function(_args)
{
    return random_range(_args[0], _args[1]);
});

proglang_function_register("irandom_range", function(_args)
{
    return irandom_range(_args[0], _args[1]);
});

proglang_function_register("choose", function(_args)
{
    var _array = _args[0];
    
    if (!is_array(_array)) || (array_length(_array) == 0)
    {
        return undefined;
    }
    
    return array_choose(_array);
});

proglang_function_register("chance", function(_args)
{
    return chance(_args[0]);
});

#endregion

// Strings & Types
proglang_function_register("string", function(_args)
{
    return string(_args[0]);
});

proglang_function_register("is_string", function(_args)
{
    return is_string(_args[0]);
});

proglang_function_register("is_real", function(_args)
{
    return is_real(_args[0]);
});

proglang_function_register("is_numeric", function(_args)
{
    return is_numeric(_args[0]);
});

proglang_function_register("is_bool", function(_args)
{
    return is_bool(_args[0]);
});

proglang_function_register("is_array", function(_args)
{
    return is_array(_args[0]);
});

proglang_function_register("is_struct", function(_args)
{
    return is_struct(_args[0]);
});

proglang_function_register("is_undefined", function(_args)
{
    return is_undefined(_args[0]);
});

proglang_function_register("real", function(_args)
{
    return real(_args[0]);
});

proglang_function_register("string_length", function(_args)
{
    return string_length(_args[0]);
});

proglang_function_register("string_pos", function(_args)
{
    return string_pos(_args[0], _args[1]);
});

proglang_function_register("string_copy", function(_args)
{
    return string_copy(_args[0], _args[1], _args[2]);
});

proglang_function_register("string_char_at", function(_args)
{
    return string_char_at(_args[0], _args[1]);
});

proglang_function_register("string_delete", function(_args)
{
    return string_delete(_args[0], _args[1], _args[2]);
});

proglang_function_register("string_insert", function(_args)
{
    return string_insert(_args[0], _args[1], _args[2]);
});

proglang_function_register("string_replace", function(_args)
{
    return string_replace(_args[0], _args[1], _args[2]);
});

proglang_function_register("string_replace_all", function(_args)
{
    return string_replace_all(_args[0], _args[1], _args[2]);
});

proglang_function_register("string_upper", function(_args)
{
    return string_upper(_args[0]);
});

proglang_function_register("string_lower", function(_args)
{
    return string_lower(_args[0]);
});

proglang_function_register("string_width", function(_args)
{
    return string_width(_args[0]);
});

proglang_function_register("string_height", function(_args)
{
    return string_height(_args[0]);
});

proglang_function_register("chr", function(_args)
{
    return chr(_args[0]);
});

proglang_function_register("ord", function(_args)
{
    return ord(_args[0]);
});

// Data Structures
proglang_function_register("array_length", function(_args)
{
    return array_length(_args[0]);
});

proglang_function_register("array_push", function(_args)
{ 
    var _arr = _args[0];
    for(var i=1; i<array_length(_args); i++) array_push(_arr, _args[i]);
});

proglang_function_register("array_pop", function(_args)
{
    return array_pop(_args[0]);
});

proglang_function_register("array_resize", function(_args)
{
    array_resize(_args[0], _args[1]);
});

proglang_function_register("array_copy", function(_args)
{
    array_copy(_args[0], _args[1], _args[2], _args[3], _args[4]);
});

proglang_function_register("struct_get_names", function(_args)
{
    return struct_get_names(_args[0]);
});

proglang_function_register("struct_get", function(_args)
{
    return struct_get(_args[0], _args[1]);
});

proglang_function_register("struct_set", function(_args)
{
    struct_set(_args[0], _args[1], _args[2]);
});

proglang_function_register("struct_names_count", function(_args)
{
    return struct_names_count(_args[0]);
});

proglang_function_register("struct_stringify", function(_args)
{
    return json_stringify(_args[0]);
});

proglang_function_register("struct_parse", function(_args)
{
    return json_parse(_args[0]);
});

// GAME
// proglang_

proglang_function_register("tile_get", function(_args) {
    var _tile = tile_get(_args[0], _args[1], _args[2]);
    
    return ((_tile != TILE_EMPTY) ? _tile : undefined);
});

proglang_function_register("tile_place", function(_args) {
    var _x = _args[1];
    var _y = _args[2];
    var _z = _args[3];
    
    tile_place(_x, _y, _z, _args[0] ?? TILE_EMPTY);
    tile_update_surrounding(_x, _y, _z);
});

proglang_function_register("spawn_particle", function(_args) {
    var _x = _args[1];
    
    if (_x == undefined) exit;
    
    var _y = _args[2];
    
    if (_y == undefined) exit;
    
    spawn_particle(_x * TILE_SIZE, _y * TILE_SIZE, _args[0]);
});

proglang_function_register("tag_get", function(_args) {
    return global.tag_data[$ $"#{_args[0]}"];
});

/*
// Game API
proglang_function_register("tile_place", function(_args, _ctx)
{ 
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
    spawn_particle(_args[0], _args[1], smart_value(_args[2]));
});

proglang_function_register("sfx_play", function(_args) { 
    sfx_diegetic_play(undefined, _args[0], _args[1], smart_value(_args[2]));
});
*/

// Print
proglang_function_register("print", function(_args)
{
    var _length = array_length(_args);
    
    var _string = "";
    
    for (var i = 0; i < _length; i++)
    {
        if (i > 0)
        {
            _string += " ";
        }
        
        _string += string(_args[i]);
    }
    
    show_debug_message(_string);
});

// Type checking
proglang_function_register("typeof", function(_args)
{
    var _val = _args[0];
    
    if (is_undefined(_val))
    {
        return "undefined";
    }
    
    if (is_bool(_val))
    {
        return "boolean";
    }
    
    if (is_real(_val))
    {
        return "number";
    }
    
    if (is_string(_val))
    {
        return "string";
    }
    
    // Check for closures/functions BEFORE generic array check
    if (is_array(_val))
    {
        // Check if it's a Proglang closure
        if (array_length(_val) >= PROG_CLOSURE.SIZE && _val[PROG_CLOSURE.TYPE] == "closure")
        {
            return "function";
        }
        // Check if it's a Proglang function
        if (array_length(_val) >= PROG_FUNC.SIZE && _val[PROG_FUNC.TYPE] == "function")
        {
            return "function";
        }
        // Otherwise it's a regular array
        return "array";
    }
    
    if (is_struct(_val))
    {
        if (struct_exists(_val, "function"))
        {
            return "function";
        }

        // Check for Regex instance or struct with __type__ == "regex"
        if ((is_instanceof(_val, Regex)) || (_val[$ "__type__"] == "regex"))
        {
            return "regex";
        }
        
        // Class instance (has __class__)
        if (_val[$ "__class__"] != undefined)
        {
            return "object";
        }
        
        // Class definition (has __type__ == "class")
        if (_val[$ "__type__"] == "class")
        {
            return "object";
        }
        
        // Plain struct
        return "struct";
    }
    
    if (is_method(_val))
    {
        return "function";
    }
    
    return "unknown";
});

proglang_function_register("is_regex", function(_args)
{
    var _val = _args[0];
    return (is_instanceof(_val, Regex)) || (is_struct(_val) && struct_exists(_val, "__type__") && _val.__type__ == "regex");
});

// Runtime error function (throws an error that can be caught)
proglang_function_register("runtime_error", function(_args)
{
    var _type = (array_length(_args) > 0) ? _args[0] : PROGLANG_ERROR_TYPE.RUNTIME;
    var _msg = (array_length(_args) > 1) ? _args[1] : "Runtime error";
    throw { type: _type, message: _msg }
});

// Debug & Utils
proglang_function_register("assert", function(_args)
{
    if (!_args[0])
    {
        var _msg = (array_length(_args) > 1) ? _args[1] : "Assertion failed";
        throw { type: PROGLANG_ERROR_TYPE.RUNTIME, message: _msg }
    }
});

proglang_function_register("time_start", function(_args)
{
    var _name = _args[0];
    if (!variable_global_exists("proglang_timers")) global.proglang_timers = {}
    global.proglang_timers[$ _name] = get_timer();
});

proglang_function_register("time_end", function(_args)
{
    var _name = _args[0];
    if (!variable_global_exists("proglang_timers") || !struct_exists(global.proglang_timers, _name))
    {
        throw { type: PROGLANG_ERROR_TYPE.RUNTIME, message: $"Timer '{_name}' does not exist." }
    }
    var _start = global.proglang_timers[$ _name];
    var _time = (get_timer() - _start) / 1000; // ms
    struct_remove(global.proglang_timers, _name);
    return _time;
});

// Regex
proglang_function_register("regex_parse", function(_args) { return new Regex(_args[0], array_length(_args)>1 ? _args[1] : ""); });
proglang_function_register("regex_test", function(_args)
{ 
    if (!is_struct(_args[1]) || !struct_exists(_args[1], "test"))
    {
            throw { type: PROGLANG_ERROR_TYPE.TYPE, message: "Expected regex object." }
    }
    return _args[1].test(_args[0]); 
});
proglang_function_register("regex_match", function(_args) { return _args[1].match(_args[0]); });
proglang_function_register("regex_match_index", function(_args) { return _args[1].match_index(_args[0]); });
proglang_function_register("regex_replace", function(_args) { return _args[1].replace(_args[0], _args[2]); });
proglang_function_register("regex_replace_all", function(_args) { return _args[1].replace(_args[0], _args[2]); });
proglang_function_register("regex_split", function(_args) { return _args[1].split(_args[0]); });

global.proglang_test_state = {
    current_failures: [],
    current_assertions: 0,
    in_test: false
}

proglang_function_register("test_expect", function(_args, _vm = undefined)
{
    // Guard: test_expect must be called inside a test
    if (!global.proglang_test_state.in_test)
    {
        throw { type: PROGLANG_ERROR_TYPE.RUNTIME, message: "test_expect() can only be called inside a test or test_group." }
    }
    
    var _actual = _args[0];
    var _expected = _args[1];
    
    // Execute actual if it's a closure/function
    if (is_array(_actual) && array_length(_actual) >= PROG_CLOSURE.SIZE && _actual[PROG_CLOSURE.TYPE] == "closure")
    {
        var _eval_vm = proglang_vm_create();
        // Propagate global_ref from calling VM
        if (_vm != undefined) _eval_vm[@ PROG_VM.GLOBAL_REF] = _vm[PROG_VM.GLOBAL_REF];
        _eval_vm[PROG_VM.SCOPE][@ PROG_SCOPE.PARENT] = _actual[PROG_CLOSURE.ENV];
        _actual = proglang_vm_run(_eval_vm, _actual[PROG_CLOSURE.BYTECODE]);
        proglang_vm_free(_eval_vm);
    }
    else if (is_struct(_actual) && struct_exists(_actual, "function"))
    {
        _actual = _actual.function([]);
    }
    
    // Execute expected if it's a closure/function
    if (is_array(_expected) && array_length(_expected) >= PROG_CLOSURE.SIZE && _expected[PROG_CLOSURE.TYPE] == "closure")
    {
        var _eval_vm = proglang_vm_create();
        // Propagate global_ref from calling VM
        if (_vm != undefined) _eval_vm[@ PROG_VM.GLOBAL_REF] = _vm[PROG_VM.GLOBAL_REF];
        _eval_vm[PROG_VM.SCOPE][@ PROG_SCOPE.PARENT] = _expected[PROG_CLOSURE.ENV];
        _expected = proglang_vm_run(_eval_vm, _expected[PROG_CLOSURE.BYTECODE]);
        proglang_vm_free(_eval_vm);
    }
    else if (is_struct(_expected) && struct_exists(_expected, "function"))
    {
        _expected = _expected.function([]);
    }
    
    ++global.proglang_test_state.current_assertions;
    
    if (_actual != _expected)
    {
        var _msg = $"Expected {_expected}, got {_actual}";
        array_push(global.proglang_test_state.current_failures, _msg);
        return false;
    }
    return true;
});

/// test(name, fn, stop_on_failure) - Runs a test function, measures time, prints summary on completion
/// Returns { passed: bool, time_ms: number, failures: array }
global.proglang_pending_tests = [];

function proglang_reset_pending()
{
    global.proglang_pending_tests = [];
}

function proglang_run_pending()
{
    var _tests = global.proglang_pending_tests;
    for (var i = 0; i < array_length(_tests); i++)
    {
        var _test = _tests[i];
        
        // Skip handled tests (ones that were inside a group)
        if (is_struct(_test) && struct_exists(_test, "handled") && _test.handled) continue;
        
        if (struct_exists(_test, "__type__") && _test.__type__ == "Group")
        {
            // Execute Group
            var _group_name = _test.name;
            var _group_tests = _test.tests;
            
            var _start = get_timer();
            var _total = array_length(_group_tests);
            var _passed = 0;
            var _failed = 0;
            
            show_debug_message($"━━━ {_group_name} ━━━");
            
            for (var j = 0; j < _total; j++)
            {
                var _t_res = _proglang_run_test_internal(_group_tests[j], $"Test {j + 1}");
                
                var _t_time = _t_res.time_ms;
                var _t_name = _t_res.name;
                
                if (_t_res.passed)
                {
                    ++_passed;
                    
                    show_debug_message($"  ✓ {_t_name} ({_t_time}ms)");
                }
                else
                {
                    ++_failed;
                    
                    show_debug_message($"  ✗ {_t_name} ({_t_time}ms)");
                    
                    for (var k = 0; k < array_length(_t_res.failures); k++)
                    {
                        show_debug_message($"    - {_t_res.failures[k]}");
                    }
                    
                    if (_t_res.error != undefined)
                    {
                        var _err_msg = is_struct(_t_res.error) && struct_exists(_t_res.error, "message") ? _t_res.error.message : string(_t_res.error);
                        
                        show_debug_message($"    - Error: {_err_msg}");
                    }
                }
            }
            
            var _total_time = (get_timer() - _start) / 1000;
            if (_failed == 0) show_debug_message($"━━━ {_passed}/{_total} passed ({_total_time}ms) ━━━");
            else show_debug_message($"━━━ {_passed}/{_total} passed, {_failed} failed ({_total_time}ms) ━━━");
        }
        else if (struct_exists(_test, "__type__") && _test.__type__ == "Test")
        {
            // Execute Single Test
            var _t_res = _proglang_run_test_internal(_test, _test.name);
            var _t_time = _t_res.time_ms;
            
            if (_t_res.passed)
            {
                show_debug_message($"✓ {_test.name} ({_t_time}ms)");
            }
            else
            {
                show_debug_message($"✗ {_test.name} ({_t_time}ms)");
                for (var k = 0; k < array_length(_t_res.failures); k++)
                {
                    show_debug_message($"  - {_t_res.failures[k]}");
                }
                if (_t_res.error != undefined)
                {
                    var _err_msg = is_struct(_t_res.error) && struct_exists(_t_res.error, "message") ? _t_res.error.message : string(_t_res.error);
                    show_debug_message($"  - Error: {_err_msg}");
                }
            }
        }
    }
}

function _proglang_run_test_internal(_test_struct, _default_name)
{
    var _name = _default_name;
    var _fn = undefined;
    
    if (is_struct(_test_struct)) && (_test_struct[$ "__type__"] == "Test")
    {
        _name = _test_struct.name;
        _fn = _test_struct.fn;
    }
    else if (is_struct(_test_struct) && struct_exists(_test_struct, "fn"))
    {
        _name = struct_exists(_test_struct, "name") ? _test_struct.name : _default_name;
        _fn = _test_struct.fn;
    }
    else
    {
        _fn = _test_struct;
    }
    
    // Support Test N: 'name' format if we have a real name
    if (_name != _default_name && string_pos(_default_name, "Test") == 1)
    {
         _name = $"{_default_name}: '{_name}'";
    }

    // Reset test state
    global.proglang_test_state.current_failures = [];
    global.proglang_test_state.current_assertions = 0;
    global.proglang_test_state.in_test = true;
    
    var _start = get_timer();
    var _error = undefined;
    
    try
    {
        // Execute the test function
        if (is_array(_fn) && array_length(_fn) >= PROG_CLOSURE.SIZE && _fn[PROG_CLOSURE.TYPE] == "closure")
        {
            var _vm = proglang_vm_create();
            // Use captured global_ref if available
            if (is_struct(_test_struct) && struct_exists(_test_struct, "global_ref") && _test_struct.global_ref != undefined)
            {
                _vm[@ PROG_VM.GLOBAL_REF] = _test_struct.global_ref;
            }
            _vm[PROG_VM.SCOPE][@ PROG_SCOPE.PARENT] = _fn[PROG_CLOSURE.ENV];
            
            // Propagate __filename for import resolution
            if (is_struct(_test_struct) && struct_exists(_test_struct, "__filename") && _test_struct.__filename != undefined)
            {
                _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__filename"] = _test_struct.__filename;
                _vm[PROG_VM.SCOPE][PROG_SCOPE.VARS][$ "__dirname"] = proglang_get_directory(_test_struct.__filename);
            }
            
            proglang_vm_run(_vm, _fn[PROG_CLOSURE.BYTECODE]);
            proglang_vm_free(_vm);
        }
        else if (is_struct(_fn)) && (struct_exists(_fn, "function"))
        {
            _fn.function([]);
        }
    }
    catch (_e)
    {
        _error = _e;
    }
    
    var _time_ms = (get_timer() - _start) / 1000;
    var _failures = global.proglang_test_state.current_failures;
    var _passed = array_length(_failures) == 0 && _error == undefined;
    
    // Reset in_test flag after test completes
    global.proglang_test_state.in_test = false;
    
    return { passed: _passed, time_ms: _time_ms, failures: _failures, error: _error, name: _name }
}

proglang_function_register("test", function(_args, _vm = undefined)
{
    var _name = _args[0];
    var _function = _args[1];
    
    var _stop_on_fail = ((array_length(_args) > 2) ? _args[2] : false);
    
    var _test_struct = {
        __type__: "Test",
        name: _name,
        fn: _function,
        stop_on_fail: _stop_on_fail,
        handled: false,
        global_ref: (_vm != undefined) ? _vm[PROG_VM.GLOBAL_REF] : undefined,
        __filename: undefined
    }
    
    if (_vm != undefined)
    {
        var _s = proglang_vm_find_var_scope(_vm, "__filename");
        if (_s != undefined)
        {
            _test_struct.__filename = _s[PROG_SCOPE.VARS][$ "__filename"];
            // show_debug_message($"[Test] Captured filename: {_test_struct.__filename}");
        }
        else
        {
             if (IS_DEVELOPER_MODE) show_debug_message($"[Test] Warning: __filename not found in scope for test '{_name}'");
        }
    }
    else
    {
         if (IS_DEVELOPER_MODE) show_debug_message($"[Test] Warning: VM undefined for test '{_name}'");
    }
    
    array_push(global.proglang_pending_tests, _test_struct);
    
    return _test_struct;
});

/// test_group(name, tests) - Registers a test group
proglang_function_register("test_group", function(_args, _vm = undefined)
{
    var _group_name = _args[0];
    var _tests = _args[1];
    
    for (var i = 0; i < array_length(_tests); i++)
    {
        var _t = _tests[i];
        
        if (is_struct(_t)) && (_t[$ "__type__"] == "Test")
        {
            _t.handled = true;
            // Propagate global_ref if not already set
            if (!struct_exists(_t, "global_ref") || _t.global_ref == undefined)
            {
                _t.global_ref = (_vm != undefined) ? _vm[PROG_VM.GLOBAL_REF] : undefined;
            }
        }
    }
    
    var _group_struct = {
        __type__: "Group",
        name: _group_name,
        tests: _tests,
        global_ref: (_vm != undefined) ? _vm[PROG_VM.GLOBAL_REF] : undefined
    }
    
    array_push(global.proglang_pending_tests, _group_struct);
    
    return _group_struct;
});
