
/// @desc Proglang Test Suite
function proglang_test() {
    var _passed = 0;
    var _failed = 0;
    
    // Ensure globals exist (if test runs before init scripts)
    if (!variable_global_exists("proglang_macros")) global.proglang_macros = {};
    if (!variable_global_exists("proglang_functions")) global.proglang_functions = {};
    if (!variable_global_exists("proglang_scripts")) global.proglang_scripts = {};
    if (!variable_global_exists("proglang_exports")) global.proglang_exports = {};
    if (!variable_global_exists("proglang_functions_registered")) {
         // If we created empty functions map, we need to register stdlib?
         // This is harder because the registration calls are in ProgFunctions.gml
         // But usually ProgFunctions.gml initializes global.proglang_functions.
         // If we are here, it means ProgFunctions.gml hasn't run either?
         // Ideally tests should wait or ensuring init.
    }
    
    var _log = function(_msg) {
        show_debug_message($"[Proglang Test] {_msg}");
        // Also log to chat if possible?
        // chat_add(_msg);
    };
    
    var _assert = function(_name, _source, _expected, _context = {}) {
        var _result = proglang_execute(_source, _context);
        if (_result == _expected) {
            show_debug_message($"[Proglang Test] PASS: {_name}");
            return true;
        } else {
            show_debug_message($"[Proglang Test] FAIL: {_name}. Expected {_expected}, got {_result}");
            return false;
        }
    };
    
    show_debug_message("[Proglang Test] Starting Tests...");
    
    // Arithmetic
    if (_assert("Add", "return 1 + 2", 3)) _passed++; else _failed++;
    if (_assert("Sub", "return 5 - 2", 3)) _passed++; else _failed++;
    if (_assert("Mul", "return 3 * 4", 12)) _passed++; else _failed++;
    if (_assert("Div", "return 10 / 2", 5)) _passed++; else _failed++;
    if (_assert("Precedence", "return 2 + 3 * 4", 14)) _passed++; else _failed++;
    if (_assert("Group", "return (2 + 3) * 4", 20)) _passed++; else _failed++;
    
    // Variables
    if (_assert("Var", "var a = 10; return a", 10)) _passed++; else _failed++;
    if (_assert("Assign", "var a = 10; a = 20; return a", 20)) _passed++; else _failed++;
    
    // Macros (Global)
    global.proglang_macros[$ "TEST_PI"] = 3.14159;
    global.proglang_macros[$ "GET_HUNDRED"] = function() { return 100; };
    if (_assert("Macro Value", "return TEST_PI", 3.14159)) _passed++; else _failed++;
    if (_assert("Macro Function", "return GET_HUNDRED", 100)) _passed++; else _failed++;
    
    // Control Flow
    if (_assert("If True", "if true { return 1 } return 0", 1)) _passed++; else _failed++;
    if (_assert("If False", "if false { return 1 } return 0", 0)) _passed++; else _failed++;
    if (_assert("While", "var i = 0; while i < 5 { i = i + 1 } return i", 5)) _passed++; else _failed++;
    if (_assert("For", "var sum = 0; for (var i = 0; i < 5; i += 1) { sum += i } return sum", 10)) _passed++; else _failed++;
    
    // Compound Assignment
    if (_assert("PlusEqual", "var a = 1; a += 5; return a", 6)) _passed++; else _failed++;
    
    // Arrays
    if (_assert("Array", "var a = [1, 2, 3]; return a[1]", 2)) _passed++; else _failed++;
    if (_assert("Array Set", "var a = [1, 2, 3]; a[0] = 5; return a[0]", 5)) _passed++; else _failed++;
    
    // Functions
    if (_assert("Math Max", "return max(10, 20)", 20)) _passed++; else _failed++;
    if (_assert("Math Abs", "var _abs = abs(-5); return _abs", 5)) _passed++; else _failed++;
    if (_assert("Math Clamp", "return clamp(15, 0, 10)", 10)) _passed++; else _failed++;
    if (_assert("Function Chain", "return floor(abs(-3.7))", 3)) _passed++; else _failed++;
    
    // Unary Operators
    if (_assert("Unary Neg", "return -5", -5)) _passed++; else _failed++;
    if (_assert("Unary Not", "return !false", true)) _passed++; else _failed++;
    // if (_assert("Double Neg", "return --5", 5)) _passed++; else _failed++;
    
    // Comparison
    if (_assert("Greater", "return 10 > 5", true)) _passed++; else _failed++;
    if (_assert("LessEqual", "return 5 <= 5", true)) _passed++; else _failed++;
    if (_assert("NotEqual", "return 3 != 4", true)) _passed++; else _failed++;
    if (_assert("Equal", "return 3 == 3", true)) _passed++; else _failed++;
    
    // Logical
    if (_assert("And True", "return true && true", true)) _passed++; else _failed++;
    if (_assert("And False", "return true && false", false)) _passed++; else _failed++;
    if (_assert("Or", "return false || true", true)) _passed++; else _failed++;
    
    // Bitwise
    if (_assert("Bit And", "return 5 & 3", 1)) _passed++; else _failed++;
    if (_assert("Bit Or", "return 5 | 3", 7)) _passed++; else _failed++;
    if (_assert("Bit Xor", "return 5 ^ 3", 6)) _passed++; else _failed++;
    if (_assert("Shift Left", "return 1 << 4", 16)) _passed++; else _failed++;
    
    // Objects/Structs
    if (_assert("Object Create", "var o = { x: 10 }; return o.x", 10)) _passed++; else _failed++;
    if (_assert("Object Set", "var o = { x: 1 }; o.x = 5; return o.x", 5)) _passed++; else _failed++;
    
    // Nested Control Flow
    if (_assert("Nested If", "var a = 5; if a > 3 { if a < 10 { return 1 } } return 0", 1)) _passed++; else _failed++;
    if (_assert("Nested Loop", @"
        var sum = 0;
        for (var i = 0; i < 3; i += 1) {
            for (var j = 0; j < 3; j += 1) {
                sum += 1
            }
        }
        return sum
    ", 9)) _passed++; else _failed++;
    
    // Complex Expressions
    if (_assert("Complex Math", "return (2 + 3) * (4 - 1) / 3", 5)) _passed++; else _failed++;
    if (_assert("Multi Var", "var a = 1; var b = 2; var c = 3; return a + b * c", 7)) _passed++; else _failed++;
    
    // If-Else
    if (_assert("If Else True", "if true { return 1 } else { return 2 }", 1)) _passed++; else _failed++;
    if (_assert("If Else False", "if false { return 1 } else { return 2 }", 2)) _passed++; else _failed++;
    
    // Context Variables
    var _ctx = { player_hp: 100, player_x: 50 };
    if (_assert("Context Read", "return player_hp", 100, _ctx)) _passed++; else _failed++;
    if (_assert("Context Math", "return player_x * 2", 100, _ctx)) _passed++; else _failed++;
    
    // Random (just check it runs without error)
    var _rand_result = proglang_execute("return random(100)");
    if (_rand_result != undefined && _rand_result >= 0 && _rand_result < 100) {
        show_debug_message("[Proglang Test] PASS: Random");
        _passed++;
    } else {
        show_debug_message($"[Proglang Test] FAIL: Random. Got {_rand_result}");
        _failed++;
    }
    
    // String Functions
    if (_assert("String Convert", "return string(123)", "123")) _passed++; else _failed++;
    if (_assert("Is Real", "return is_real(5)", true)) _passed++; else _failed++;
    if (_assert("Is String", "return is_string(\"hi\")", true)) _passed++; else _failed++;
    
    // ============ PHASE 7 TESTS ============
    
    // Ternary Operators
    if (_assert("Ternary True", "return true ? 1 : 2", 1)) _passed++; else _failed++;
    if (_assert("Ternary False", "return false ? 1 : 2", 2)) _passed++; else _failed++;
    if (_assert("Ternary Nested", "return true ? (false ? 1 : 2) : 3", 2)) _passed++; else _failed++;
    if (_assert("Ternary Expr", "var a = 5; return a > 3 ? 10 : 20", 10)) _passed++; else _failed++;
    
    // Prefix Increment/Decrement
    if (_assert("Prefix Inc", "var i = 5; return ++i", 6)) _passed++; else _failed++;
    if (_assert("Prefix Dec", "var i = 5; return --i", 4)) _passed++; else _failed++;
    if (_assert("Prefix Inc Side Effect", "var i = 5; ++i; return i", 6)) _passed++; else _failed++;
    
    // Postfix Increment/Decrement
    if (_assert("Postfix Inc", "var i = 5; return i++", 5)) _passed++; else _failed++;
    if (_assert("Postfix Dec", "var i = 5; return i--", 5)) _passed++; else _failed++;
    if (_assert("Postfix Inc Side Effect", "var i = 5; i++; return i", 6)) _passed++; else _failed++;
    
    // Switch/Case
    if (_assert("Switch Case 1", @"
        var x = 1
        switch (x) {
            case 1: return 10
            case 2: return 20
            default: return 0
        }
    ", 10)) _passed++; else _failed++;
    
    if (_assert("Switch Case 2", @"
        var x = 2
        switch (x) {
            case 1: return 10
            case 2: return 20
            default: return 0
        }
    ", 20)) _passed++; else _failed++;
    
    if (_assert("Switch Default", @"
        var x = 99
        switch (x) {
            case 1: return 10
            case 2: return 20
            default: return 0
        }
    ", 0)) _passed++; else _failed++;
    
    // ============ PHASE 8 TESTS: User-Defined Functions ============
    
    // Local function with parameters  
    if (_assert("Function Decl", @"
        fn add(a, b) {
            return a + b
        }
        return add(3, 5)
    ", 8)) _passed++; else _failed++;
    
    // Function calling another function
    if (_assert("Function Nesting", @"
        fn double(x) {
            return x * 2
        }
        fn quadruple(x) {
            return double(double(x))
        }
        return quadruple(5)
    ", 20)) _passed++; else _failed++;
    
    // Global function and variable
    if (_assert("Global Var Decl", @"
        global my_val = 42
        return my_val
    ", 42)) _passed++; else _failed++;
    
    // Multiple parameters
    if (_assert("Multiple Params", @"
        fn sum3(a, b, c) {
            return a + b + c
        }
        return sum3(1, 2, 3)
    ", 6)) _passed++; else _failed++;
    
    // No params
    if (_assert("No Params Fn", @"
        fn get_ten() {
            return 10
        }
        return get_ten()
    ", 10)) _passed++; else _failed++;
    
    // Function with if statement
    if (_assert("Fn With Control Flow", @"
        fn is_positive(n) {
            if (n > 0) {
                return true
            }
            return false
        }
        return is_positive(5)
    ", true)) _passed++; else _failed++;
    
    // Function keyword (synonym for fn)
    if (_assert("Function Keyword", @"
        function multiply(a, b) {
            return a * b
        }
        return multiply(4, 5)
    ", 20)) _passed++; else _failed++;

    // Local function with global variable  
    if (_assert("Fn With Global Var", @"
        global n = 10
        
        fn add(b) {
            return n + b
        }
        return add(5)
    ", 15)) _passed++; else _failed++;

    show_debug_message($"[Proglang Test] Tests Completed. Passed: {_passed}, Failed: {_failed}");
    
    return (_failed == 0);
}


proglang_test();