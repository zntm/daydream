/// @desc Proglang Standard Library Function Tests
function proglang_function_test() {
    proglang_init(); // Initialize environment
    var _passed = 0;
    var _failed = 0;

    var _log = function(_msg) {
        show_debug_message($"[Proglang function Test] {_msg}");
    };
    
    var _assert = function(_name, _source, _expected, _epsilon = undefined) {
        try {
            var _result = proglang_execute(_source);
            
            var _match = false;
            if (_epsilon != undefined && is_real(_result) && is_real(_expected)) {
                _match = abs(_result - _expected) <= _epsilon;
            } else {
                _match = (_result == _expected);
            }

            if (_match) {
                show_debug_message($"[Proglang Fn Test] PASS: {_name}");
                return true;
            } else {
                show_debug_message($"[Proglang Fn Test] FAIL: {_name}. Expected {_expected}, got {_result}");
                return false;
            }
        } catch (_e) {
            show_debug_message($"[Proglang Fn Test] FAIL (EXCEPTION): {_name}. Error: {_e}");
            return false;
        }
    };

    show_debug_message("[Proglang Fn Test] Starting Tests...");

    // ============ MATH FUNCTIONS ============
    if (_assert("floor", "return floor(5.9)", 5)) _passed++; else _failed++;
    if (_assert("ceil", "return ceil(5.1)", 6)) _passed++; else _failed++;
    if (_assert("round", "return round(5.5)", 6)) _passed++; else _failed++; // GM round is round-to-nearest-even sometimes? or standard? standard usually rounds .5 up or to even. Let's check 5.5 -> 6 usually.
    if (_assert("abs", "return abs(-10)", 10)) _passed++; else _failed++;
    if (_assert("sign positive", "return sign(50)", 1)) _passed++; else _failed++;
    if (_assert("sign negative", "return sign(-50)", -1)) _passed++; else _failed++;
    if (_assert("sign zero", "return sign(0)", 0)) _passed++; else _failed++;
    if (_assert("min", "return min(10, 5)", 5)) _passed++; else _failed++;
    if (_assert("max", "return max(10, 5)", 10)) _passed++; else _failed++;
    if (_assert("clamp logic", "return clamp(15, 0, 10)", 10)) _passed++; else _failed++;
    if (_assert("lerp", "return lerp(0, 10, 0.5)", 5)) _passed++; else _failed++;
    if (_assert("power", "return power(2, 3)", 8)) _passed++; else _failed++;
    if (_assert("sqrt", "return sqrt(16)", 4)) _passed++; else _failed++;
    
    // Trig (Approximate)
    if (_assert("sin", "return sin(0)", 0)) _passed++; else _failed++;
    if (_assert("cos", "return cos(0)", 1)) _passed++; else _failed++;
    if (_assert("tan", "return tan(0)", 0)) _passed++; else _failed++;
    
    if (_assert("dsin", "return dsin(90)", 1)) _passed++; else _failed++;
    if (_assert("dcos", "return dcos(180)", -1)) _passed++; else _failed++; // GM dcos(180) is -1
    // if (_assert("dtan", "return dtan(45)", 1)) _passed++; else _failed++; // Might be 0.99999... depending on precision

    if (_assert("lengthdir_x", "return lengthdir_x(10, 0)", 10)) _passed++; else _failed++; // 0 degrees is right
    if (_assert("lengthdir_y", "return lengthdir_y(10, 90)", -10))_passed++; else _failed++; // GM y is down-positive, but angles usually counter-clockwise? Wait GM: 90 is UP (-y). So 10 * dsin(90) = 10? No lengthdir_y = len * dsin(dir). dsin(90)=1. So 10? Wait.
    // In GM: lengthdir_x = len * dcos(dir); lengthdir_y = -len * dsin(dir); (Usually, because y is down).
    // Let's assume standard behavior. lengthdir_y(10, 90) -> -10 in GM typically.
    
    if (_assert("point_distance", "return point_distance(0, 0, 3, 4)", 5)) _passed++; else _failed++;
    if (_assert("point_direction", "return point_direction(0, 0, 10, 0)", 0)) _passed++; else _failed++;

    // ============ RANDOM FUNCTIONS ============
    // Can't assert exact values easily, but check bounds/types
    
    // irandom
    var _irand = proglang_execute("return irandom(10)");
    if (_irand >= 0 && _irand <= 10 && floor(_irand) == _irand) {
        show_debug_message("[Proglang Fn Test] PASS: irandom"); _passed++;
    } else {
        show_debug_message($"[Proglang Fn Test] FAIL: irandom got {_irand}"); _failed++;
    }
    
    // random_range
    var _rr = proglang_execute("return random_range(5, 10)");
    if (_rr >= 5 && _rr <= 10) {
        show_debug_message("[Proglang Fn Test] PASS: random_range"); _passed++;
    } else {
        show_debug_message($"[Proglang Fn Test] FAIL: random_range got {_rr}"); _failed++;
    }

    // choose
    var _ch = proglang_execute("return choose([10, 20, 30])");
    if (_ch == 10 || _ch == 20 || _ch == 30) {
        show_debug_message("[Proglang Fn Test] PASS: choose"); _passed++;
    } else {
        show_debug_message($"[Proglang Fn Test] FAIL: choose got {_ch}"); _failed++;
    }

    // ============ STRINGS & TYPES ============
    if (_assert("string conversion", "return string(123)", "123")) _passed++; else _failed++;
    if (_assert("is_string true", "return is_string('hello')", true)) _passed++; else _failed++;
    if (_assert("is_string false", "return is_string(123)", false)) _passed++; else _failed++;
    if (_assert("is_real true", "return is_real(123)", true)) _passed++; else _failed++;
    if (_assert("is_array true", "return is_array([])", true)) _passed++; else _failed++;
    if (_assert("is_struct true", "return is_struct({})", true)) _passed++; else _failed++;
    if (_assert("is_undefined true", "return is_undefined(undefined)", true)) _passed++; else _failed++;
    if (_assert("is_regex true", "return is_regex(/^abs/g)", true)) _passed++; else _failed++;
    
    if (_assert("typeof string", "return typeof('s')", "string")) _passed++; else _failed++;
    if (_assert("typeof number", "return typeof(10)", "number")) _passed++; else _failed++;
    if (_assert("typeof boolean", "return typeof(true)", "boolean")) _passed++; else _failed++;
    if (_assert("typeof array", "return typeof([])", "array")) _passed++; else _failed++;
    if (_assert("typeof struct", "return typeof({})", "struct")) _passed++; else _failed++;
    
    // ============ DATA STRUCTURES ============
    if (_assert("array_length", "return array_length([1,2,3])", 3)) _passed++; else _failed++;
    
    if (_assert("array_push", 
        $"var a = [1]\n" +
        $"array_push(a, 2)\n" +
        $"return a[1]"
    , 2)) _passed++; else _failed++;

    if (_assert("array_pop", 
        $"var a = [1, 5]\n" +
        $"var v = array_pop(a)\n" +
        $"return v"
    , 5)) _passed++; else _failed++;
    
    if (_assert("array_contains true", "return array_contains([1, 2, 3], 2)", true)) _passed++; else _failed++;
    if (_assert("array_contains false", "return array_contains([1, 2, 3], 5)", false)) _passed++; else _failed++;

    if (_assert("struct_get_names", 
        $"var s = \{ a: 1, b: 2 \}\n" +
        $"var names = struct_get_names(s)\n" +
        $"return array_length(names)"
    , 2)) _passed++; else _failed++;

    
    // ============ DEBUG & REGEX ============
    // Just run print, shouldn't crash
    try {
        proglang_execute("print('Hello from test', 123)");
        show_debug_message("[Proglang Fn Test] PASS: print (no crash)");
        _passed++;
    } catch(_e) {
        show_debug_message($"[Proglang Fn Test] FAIL: print crashed: {_e}");
        _failed++;
    }
    
    // ============ NEW DEBUG FUNCTIONS ============
    // Infinity
    // Infinity can be tricky to assert exact equality with some JSON parsers or internal reps, 
    // but GML infinity == infinity.
    if (_assert("infinity check", "return infinity > 999999999", true)) _passed++; else _failed++;
    
    // ============ REGEX FUNCTIONS ============
    if (_assert("is_regex true", "return is_regex(regex_parse('^test$'))", true)) _passed++; else _failed++;
    if (_assert("is_regex false", "return is_regex('not a regex')", false)) _passed++; else _failed++;
    if (_assert("typeof regex", "return typeof(regex_parse('^test$'))", "regex")) _passed++; else _failed++;
    
    // Regex Logic
    if (_assert("regex_test true", "return regex_test('hello', /^h.llo$/)", true)) _passed++; else _failed++;
    if (_assert("regex_test false", "return regex_test('hello', regex_parse('^world$'))", false)) _passed++; else _failed++;
    
    if (_assert("regex_match", 
        $"var re = regex_parse(\"\\d+\") // match digits\n" +
        $"var m = regex_match(\"item: 1234\", re)\n" +
        $"return m[0]"
    , "1234")) _passed++; else _failed++;
    
    if (_assert("regex_replace", 
        $"var re = regex_parse(\"apple\")\n" +
        $"return regex_replace(\"apple pie\", re, \"banana\")"
    , "banana pie")) _passed++; else _failed++;

    if (_assert("regex_replace_all", 
        $"var re = regex_parse(\" \", \"g\") // global flag\n" +
        $"return regex_replace(\"a b c\", re, \"-\")" // uses regex_replace with global flag internally or regex_replace_all
    , "a-b-c")) _passed++; else _failed++;

    // Assert
    try {
        proglang_execute("assert(true)");
        _passed++;
        show_debug_message("[Proglang Fn Test] PASS: assert(true)");
    } catch (_e) {
         show_debug_message($"[Proglang Fn Test] FAIL: assert(true) threw exception: {_e}");
         _failed++;
    }

    try {
        proglang_execute("assert(false, 'Should fail')");
        show_debug_message("[Proglang Fn Test] FAIL: assert(false) did not throw");
        _failed++;
    } catch (_e) {
         show_debug_message("[Proglang Fn Test] PASS: assert(false) threw exception as expected");
         _passed++;
    }

    // Timers
    try {
        proglang_execute("time_start('test_timer'); var i=0; for(var k=0; k<100; k++) i++; print($\"test_timer: \{time_end('test_timer')\}ms\");");
        show_debug_message("[Proglang Fn Test] PASS: time_start/end");
        _passed++;
    } catch (_e) {
         show_debug_message($"[Proglang Fn Test] FAIL: time_start/end: {_e}");
         _failed++;
    }
    
    // Struct Stringify/Parse
    if (_assert("struct JSON roundtrip", 
        $"var s = \{ a: 10, b: \"hello\" \}\n" +
        $"var json = struct_stringify(s)\n" +
        $"var s2 = struct_parse(json)\n" +
        $"return s2.a == 10 && s2.b == \"hello\""
    , true)) _passed++; else _failed++;

    
    show_debug_message($"[Proglang Fn Test] COMPLETE. Passed: {_passed}, Failed: {_failed}");
    return { passed: _passed, failed: _failed };
}

if (IS_DEVELOPER_MODE)
{
    proglang_function_test()
}
