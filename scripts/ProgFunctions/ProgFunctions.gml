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
proglang_function_register("random", function(_args) { return random(_args[0]); });
proglang_function_register("irandom", function(_args) { return irandom(_args[0]); });
proglang_function_register("random_range", function(_args) { return random_range(_args[0], _args[1]); });
proglang_function_register("irandom_range", function(_args) { return irandom_range(_args[0], _args[1]); });
proglang_function_register("choose", function(_args)
{
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
proglang_function_register("array_length", function(_args) { return array_length(_args[0]); });
proglang_function_register("array_push", function(_args)
{ 
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

// Print
proglang_function_register("print", function(_args)
{ 
    var _msg = "";
    for (var i = 0; i < array_length(_args); i++)
    {
        if (i > 0) _msg += " ";
        _msg += string(_args[i]);
    }
    show_debug_message($"[Daydream] {_msg}");
});

// Type checking
proglang_function_register("typeof", function(_args)
{
    var _val = _args[0];
    if (is_undefined(_val)) return "undefined";
    if (is_bool(_val)) return "boolean";
    if (is_real(_val)) return "number";
    if (is_string(_val)) return "string";
    if (is_array(_val)) return "array";
    if (is_struct(_val))
    {
        if (struct_exists(_val, "__type__") && _val.__type__ == "regex") return "regex";
        if (struct_exists(_val, "__class__")) return "object";
        return "struct";
    }
    if (is_method(_val)) return "function";
    return "unknown";
});

proglang_function_register("is_regex", function(_args)
{
    var _val = _args[0];
    return is_struct(_val) && struct_exists(_val, "__type__") && _val.__type__ == "regex";
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
    current_assertions: 0
}

proglang_function_register("test_expect", function(_args)
{
    var _actual = _args[0];
    var _expected = _args[1];
    
    // Execute actual if it's a closure/function
    if (is_array(_actual) && array_length(_actual) >= PROG_CLOSURE.SIZE && _actual[PROG_CLOSURE.TYPE] == "closure")
    {
        var _vm = new ProgVM();
        
        _actual = _vm.run(_actual[PROG_CLOSURE.BYTECODE]);
    }
    else if (is_struct(_actual) && struct_exists(_actual, "func"))
    {
        _actual = _actual.func([]);
    }
    
    // Execute expected if it's a closure/function
    if (is_array(_expected) && array_length(_expected) >= PROG_CLOSURE.SIZE && _expected[PROG_CLOSURE.TYPE] == "closure")
    {
        var _vm = new ProgVM();
        _expected = _vm.run(_expected[PROG_CLOSURE.BYTECODE]);
    }
    else if (is_struct(_expected) && struct_exists(_expected, "func"))
    {
        _expected = _expected.func([]);
    }
    
    global.proglang_test_state.current_assertions++;
    
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
proglang_function_register("test", function(_args)
{
    var _name = _args[0];
    var _fn = _args[1];
    var _stop_on_fail = array_length(_args) > 2 ? _args[2] : false;
    
    // Reset test state
    global.proglang_test_state.current_failures = [];
    global.proglang_test_state.current_assertions = 0;
    
    var _start = get_timer();
    var _error = undefined;
    
    try
    {
        // Execute the test function
        if (is_array(_fn) && array_length(_fn) >= PROG_CLOSURE.SIZE && _fn[PROG_CLOSURE.TYPE] == "closure")
        {
            var _vm = new ProgVM();
            _vm.run(_fn[PROG_CLOSURE.BYTECODE]);
        }
        else if (is_struct(_fn) && struct_exists(_fn, "func"))
        {
            _fn.func([]);
        }
    }
    catch (_e)
    {
        _error = _e;
    }
    
    var _time_ms = (get_timer() - _start) / 1000;
    var _failures = global.proglang_test_state.current_failures;
    var _passed = array_length(_failures) == 0 && _error == undefined;
    
    // Print result only after completion
    if (_passed)
    {
        show_debug_message($"✓ {_name} ({_time_ms}ms)");
    }
    else
    {
        show_debug_message($"✗ {_name} ({_time_ms}ms)");
        for (var i = 0; i < array_length(_failures); i++)
        {
            show_debug_message($"  - {_failures[i]}");
        }
        if (_error != undefined)
        {
            var _err_msg = is_struct(_error) && struct_exists(_error, "message") ? _error.message : string(_error);
            show_debug_message($"  - Error: {_err_msg}");
        }
        
        if (_stop_on_fail)
        {
            throw { type: PROGLANG_ERROR_TYPE.RUNTIME, message: $"Test '{_name}' failed" };
        }
    }
    
    return { passed: _passed, time_ms: _time_ms, failures: _failures };
});

/// test_group(name, tests) - Aggregates multiple tests, prints clean summary after completion
/// tests: array of { name, fn } or just functions
/// Returns { total: n, passed: n, failed: n, time_ms: n }
proglang_function_register("test_group", function(_args)
{
    var _group_name = _args[0];
    var _tests = _args[1];
    
    var _start = get_timer();
    var _total = array_length(_tests);
    var _passed = 0;
    var _failed = 0;
    var _results = [];
    
    show_debug_message($"━━━ {_group_name} ━━━");
    
    for (var i = 0; i < _total; i++)
    {
        var _test = _tests[i];
        var _test_name = "";
        var _test_fn = undefined;
        
        // Support { name, fn } or just fn
        if (is_struct(_test) && struct_exists(_test, "fn"))
        {
            _test_name = struct_exists(_test, "name") ? _test.name : $"Test {i + 1}";
            _test_fn = _test.fn;
        }
        else
        {
            _test_name = $"Test {i + 1}";
            _test_fn = _test;
        }
        
        // Reset test state
        global.proglang_test_state.current_failures = [];
        global.proglang_test_state.current_assertions = 0;
        
        var _t_start = get_timer();
        var _error = undefined;
        
        try
        {
            if (is_array(_test_fn) && array_length(_test_fn) >= PROG_CLOSURE.SIZE && _test_fn[PROG_CLOSURE.TYPE] == "closure")
            {
                var _vm = new ProgVM();
                _vm.run(_test_fn[PROG_CLOSURE.BYTECODE]);
            }
            else if (is_struct(_test_fn) && struct_exists(_test_fn, "func"))
            {
                _test_fn.func([]);
            }
        }
        catch (_e)
        {
            _error = _e;
        }
        
        var _t_time = (get_timer() - _t_start) / 1000;
        var _failures = global.proglang_test_state.current_failures;
        var _test_passed = array_length(_failures) == 0 && _error == undefined;
        
        if (_test_passed)
        {
            _passed++;
            show_debug_message($"  ✓ {_test_name} ({_t_time}ms)");
        }
        else
        {
            _failed++;
            show_debug_message($"  ✗ {_test_name} ({_t_time}ms)");
            for (var j = 0; j < array_length(_failures); j++)
            {
                show_debug_message($"    - {_failures[j]}");
            }
            if (_error != undefined)
            {
                var _err_msg = is_struct(_error) && struct_exists(_error, "message") ? _error.message : string(_error);
                show_debug_message($"    - Error: {_err_msg}");
            }
        }
        
        array_push(_results, { name: _test_name, passed: _test_passed, time_ms: _t_time });
    }
    
    var _total_time = (get_timer() - _start) / 1000;
    
    // Summary line
    if (_failed == 0)
    {
        show_debug_message($"━━━ {_passed}/{_total} passed ({_total_time}ms) ━━━");
    }
    else
    {
        show_debug_message($"━━━ {_passed}/{_total} passed, {_failed} failed ({_total_time}ms) ━━━");
    }
    
    return { total: _total, passed: _passed, failed: _failed, time_ms: _total_time, results: _results };
});
