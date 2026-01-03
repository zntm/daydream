
/// @desc Proglang Test Suite
function proglang_test() {
    var _passed = 0;
    var _failed = 0;
    /*
    // Ensure globals exist (if test runs before init scripts)
    if (!variable_global_exists("proglang_macros")) global.proglang_macros = {}
    if (!variable_global_exists("proglang_functions")) global.proglang_functions = {}
    if (!variable_global_exists("proglang_scripts")) global.proglang_scripts = {}
    if (!variable_global_exists("proglang_exports")) global.proglang_exports = {}
    if (!variable_global_exists("proglang_functions_registered")) {
        // If we created empty functions map, we need to register stdlib?
        // This is harder because the registration calls are in ProgFunctions.gml
        // But usually ProgFunctions.gml initializes global.proglang_functions.
        // If we are here, it means ProgFunctions.gml hasn't run either?
        // Ideally tests should wait or ensuring init.
    }
    */
    var _log = function(_msg) {
        show_debug_message($"[Proglang Test] {_msg}");
        // Also log to chat if possible?
        // chat_add(_msg);
    }
    
    var _assert = function(_name, _source, _expected, _context = {}) {
        try {
            var _timer = get_timer();
            var _result = proglang_execute(_source, _context);
            if (_result == _expected) {
                show_debug_message($"[Proglang Test] PASS: {_name} ({(get_timer() - _timer) / 1000}ms)");
                return true;
            } else {
                show_debug_message($"[Proglang Test] FAIL: {_name}. Expected {_expected}, got {_result} ({(get_timer() - _timer) / 1000}ms)");
                return false;
            }
        } catch (_e) {
            show_debug_message($"[Proglang Test] FAIL (EXCEPTION): {_name}. Error: {_e}");
            return false;
        }
    }
    
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
    
    // Constants (Global) - can be values or functions
    // global.proglang_macros[$ "TEST_PI"] = 3.14159;
    // global.proglang_macros[$ "GET_HUNDRED"] = function() { return 100; }
    // if (_assert("Macro Value", "return TEST_PI", 3.14159)) _passed++; else _failed++;
    // if (_assert("Macro Function", "return GET_HUNDRED", 100)) _passed++; else _failed++;
    
    // Control Flow
    if (_assert("If True", "if true { return 1 } return 0", 1)) _passed++; else _failed++;
    if (_assert("If False", "if false { return 1 } return 0", 0)) _passed++; else _failed++;
    if (_assert("While", "var i = 0; while i < 5 { i = i + 1 } return i", 5)) _passed++; else _failed++;
    if (_assert("For", "var sum = 0; for (var i = 0; i < 5; i += 1) { sum += i } return sum", 10)) _passed++; else _failed++;
    if (_assert("For Continue", "var sum = 0; for (var i = 0; i < 5; i += 1) { if (i == 0) continue sum += 1 } return sum", 4)) _passed++; else _failed++;
    if (_assert("For Break", "var sum = 0; for (var i = 0; i < 5; i += 1) { if (i == 3) break sum += 1 } return sum", 3)) _passed++; else _failed++;
    
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
    if (_assert("Shift Right", "return 16 >> 2", 4)) _passed++; else _failed++;
    if (_assert("Bit NOT", "return ~0", -1)) _passed++; else _failed++;
    if (_assert("Bit NOT 5", "return ~5", -6)) _passed++; else _failed++;
    
    // Compound Bitwise Assignments
    if (_assert("LShift Assign", "var a = 1; a <<= 3; return a", 8)) _passed++; else _failed++;
    if (_assert("RShift Assign", "var a = 16; a >>= 2; return a", 4)) _passed++; else _failed++;
    if (_assert("BitAnd Assign", "var a = 7; a &= 3; return a", 3)) _passed++; else _failed++;
    if (_assert("BitOr Assign", "var a = 1; a |= 6; return a", 7)) _passed++; else _failed++;
    if (_assert("BitXor Assign", "var a = 5; a ^= 3; return a", 6)) _passed++; else _failed++;
    
    // Break Amount (Multi-Level Break)
    if (_assert("Break 2", 
        $"var found = 0\n" +
        $"for (var i = 0; i < 3; i++) \{\n" +
        $"    for (var j = 0; j < 3; j++) \{\n" +
        $"        if (i == 1 && j == 1) \{\n" +
        $"            found = 1\n" +
        $"            break 2\n" +
        $"        \}\n" +
        $"    \}\n" +
        $"    found = 2  // Should not reach here if break 2 works\n" +
        $"\}\n" +
        $"return found"
    , 1)) _passed++; else _failed++;
    
    // Objects/Structs
    if (_assert("Object Create", "var o = { x: 10 } return o.x", 10)) _passed++; else _failed++;
    if (_assert("Object Set", "var o = { x: 1 } o.x = 5; return o.x", 5)) _passed++; else _failed++;
    
    // Nested Control Flow
    if (_assert("Nested If", "var a = 5; if a > 3 { if a < 10 { return 1 } } return 0", 1)) _passed++; else _failed++;
    if (_assert("Nested Loop", 
        $"var sum = 0;\n" +
        $"for (var i = 0; i < 3; i += 1) \{\n" +
        $"    for (var j = 0; j < 3; j += 1) \{\n" +
        $"        sum += 1\n" +
        $"    \}\n" +
        $"\}\n" +
        $"return sum"
    , 9)) _passed++; else _failed++;
    
    // Complex Expressions
    if (_assert("Complex Math", "return (2 + 3) * (4 - 1) / 3", 5)) _passed++; else _failed++;
    if (_assert("Multi Var", "var a = 1; var b = 2; var c = 3; return a + b * c", 7)) _passed++; else _failed++;
    
    // If-Else
    if (_assert("If Else True", "if true { return 1 } else { return 2 }", 1)) _passed++; else _failed++;
    if (_assert("If Else False", "if false { return 1 } else { return 2 }", 2)) _passed++; else _failed++;
    
    // Context Variables
    var _ctx = { player_hp: 100, player_x: 50 }
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
    if (_assert("Switch Case 1", 
        $"var x = 1\n" +
        $"switch (x) \{\n" +
        $"    case 1: return 10\n" +
        $"    case 2: return 20\n" +
        $"    default: return 0\n" +
        $"\}"
    , 10)) _passed++; else _failed++;
    
    if (_assert("Switch Case 2", 
        $"var x = 2\n" +
        $"switch (x) \{\n" +
        $"    case 1: return 10\n" +
        $"    case 2: return 20\n" +
        $"    default: return 0\n" +
        $"\}"
    , 20)) _passed++; else _failed++;
    
    if (_assert("Switch Default", 
        $"var x = 99\n" +
        $"switch (x) \{\n" +
        $"    case 1: return 10\n" +
        $"    case 2: return 20\n" +
        $"    default: return 0\n" +
        $"\}"
    , 0)) _passed++; else _failed++;
    
    if (_assert("Switch Case 4", 
        $"var x = 2\n" +
        $"switch (x) \{\n" +
        $"    case 1:\n" +
        $"    case 2: return 10\n" +
        $"    case 3: return 20\n" +
        $"    default: return 0\n" +
        $"\}"
    , 10)) _passed++; else _failed++;
    
    // ============ PHASE 8 TESTS: User-Defined Functions ============
    
    // Local function with parameters  
    if (_assert("Function Decl", 
        $"fn add(a, b) \{\n" +
        $"    return a + b\n" +
        $"\}\n" +
        $"return add(3, 5)"
    , 8)) _passed++; else _failed++;
    
    // Function calling another function
    if (_assert("Function Nesting", 
        $"fn double(x) \{\n" +
        $"    return x * 2\n" +
        $"\}\n" +
        $"fn quadruple(x) \{\n" +
        $"    return double(double(x))\n" +
        $"\}\n" +
        $"return quadruple(5)"
    , 20)) _passed++; else _failed++;
    
    // Global function and variable
    if (_assert("Global Var Decl",
        $"global var my_val = 42\n" +
        $"return my_val\n"
    , 42)) _passed++; else _failed++;
    
    // Multiple parameters
    if (_assert("Multiple Params", 
        $"fn sum3(a, b, c) \{\n" +
        $"    return a + b + c\n" +
        $"\}\n" +
        $"return sum3(1, 2, 3)"
    , 6)) _passed++; else _failed++;
    
    // No params
    if (_assert("No Params Fn", 
        $"fn get_ten() \{\n" +
        $"    return 10\n" +
        $"\}\n" +
        $"return get_ten()"
    , 10)) _passed++; else _failed++;
    
    // Function with if statement
    if (_assert("Fn With Control Flow", 
        $"fn is_positive(n) \{\n" +
        $"    if (n > 0) \{\n" +
        $"        return true\n" +
        $"    \}\n" +
        $"    return false\n" +
        $"\}\n" +
        $"return is_positive(5)"
    , true)) _passed++; else _failed++;
    
    // Local function with global variable  
    if (_assert("Fn With Global Var", 
        $"global var n = 10\n" +
        $"fn add(b) \{\n" +
        $"    return n + b\n" +
        $"\}\n" +
        $"return add(5)"
    , 15)) _passed++; else _failed++;
    
    
    // ============ PHASE 9 TESTS: Modern Features ============
    
    // Power Operator
    if (_assert("Power Op", "return 2 ** 3", 8)) _passed++; else _failed++;
    
    // Null Coalescing
    if (_assert("Null Coalesce 1", "return undefined ?? 10", 10)) _passed++; else _failed++;
    if (_assert("Null Coalesce 2", "return 5 ?? 10", 5)) _passed++; else _failed++;
    if (_assert("Null Coalesce Chain", "return undefined ?? undefined ?? 20", 20)) _passed++; else _failed++;
    
    // String Interpolation
    if (_assert("String Interp", "var name = \"World\"; return $\"Hello {name}!\"","Hello World!")) _passed++; else _failed++;
    
    // Destructuring Array
    if (_assert("Destruct Array", "var [a, b] = [10, 20]; return a + b", 30)) _passed++; else _failed++;
    
    // Destructuring Object
    if (_assert("Destruct Object", "var {x, y} = {x: 5, y: 6} return x * y", 30)) _passed++; else _failed++;
    if (_assert("Destruct Alias", "var {x: a} = {x: 10} return a", 10)) _passed++; else _failed++;
    
    // For In Array
    if (_assert("For In Array", 
        $"var arr = [1, 2, 3]\n" +
        $"var sum = 0\n" +
        $"for (v in arr) \{\n" +
        $"    sum += v\n" +
        $"\}" +
        $"return sum"
    , 6)) _passed++; else _failed++;
    
    // For In Array With Index
    if (_assert("For In Array With Index", 
        $"var arr = [1, 2, 3]\n" +
        $"var sum = 0\n" +
        $"for (v, i in arr) \{\n" +
        $"    sum += v + i\n" +
        $"\}\n" +
        $"// v=1,i=0 -> 1; v=2,i=1 -> 3; v=3,i=2 -> 5. Sum=1+3+5=9\n" +
        $"return sum"
    , 9)) _passed++; else _failed++;
    
    // For In Struct
    if (_assert("For In Struct", 
        $"var obj = \{a: 1, b: 2\}\n" +
        $"var count = 0\n" +
        $"for (k in obj) \{\n" +
        $"    count++\n" +
        $"\}\n" +
        $"return count"
    , 2)) _passed++; else _failed++;
    
    // For In Struct With Value
    if (_assert("For In Struct With Value", 
        $"var obj = \{a: 1, b: 2\}\n" +
        $"var sum = 0\n" +
        $"for (k, v in obj) \{\n" +
        $"    sum += v\n" +
        $"\}\n" +
        $"return sum"
    , 3)) _passed++; else _failed++;
    
    // Try Catch (Runtime Error)
    if (_assert("Try Catch Catch", 
        $"try \{\n" +
        $"    var a = undefined\n" +
        $"    return a + 1 \n" +
        $"\} catch (e) \{\n" +
        $"    return 100\n" +
        $"\}"
    , 100)) _passed++; else _failed++;
    
    if (_assert("Try Catch No Error", 
        $"try \{\n" +
        $"    return 50\n" +
        $"\} catch (e) \{\n" +
        $"    return 100\n" +
        $"\}"
    , 50)) _passed++; else _failed++;
    
    // Module Import/Export
    try {
        // 1. Compile Module
        var _lib_code = "export var PI = 3.0; export fn add(a, b) { return a + b; }";
        var _lib_bc = proglang_compile(_lib_code);
        
        // 2. Run Module to populate exports
        var _lib_vm = proglang_vm_create();
        if (!variable_global_exists("proglang_modules")) global.proglang_modules = {}
        global.proglang_modules[$ "math_lib"] = { exports: {}, loaded: true }
        _lib_vm[@ PROG_VM.ACTIVE_MODULE] = global.proglang_modules[$ "math_lib"];
        proglang_vm_run(_lib_vm, _lib_bc);
        proglang_vm_free(_lib_vm);
        
        // 3. Run Consumer
        var _main_code = "import PI, add from \"math_lib\"; return add(PI, 2.0);";
        if (_assert("Module Import/Export", _main_code, 5.0)) _passed++; else _failed++;
        
    } catch (_e) {
        show_debug_message($"[Proglang Test] Module Test Exception: {_e}");
        _failed++;
    }
    
    // Custom Error Handling
    if (_assert("Custom Error Handling", 
        $"try \{\n" +
        $"    // Simulate a typed error\n" +
        $"    throw \{ type: ERROR_TYPE.TYPE, message: \"Custom error\" \}\n" +
        $"\} catch (e) \{\n" +
        $"    if (e.type == ERROR_TYPE.TYPE) return 1\n" +
        $"    return 0\n" +
        $"\}"
    , 1)) _passed++; else _failed++;
    
    
    
    // Spread Array
    if (_assert("Spread Array", "var a = [1, 2]; var b = [0, ...a, 3]; return b[2]", 2)) _passed++; else _failed++;
    
    // Spread Call (assuming 'max' is exposed. If not, verify result is correct logic)
    // var args = [1, 5, 2]; return max(...args); -> Wait, Proglang 'max' might be limited.
    // Use user function for reliability
    if (_assert("Spread Call", 
        $"fn sum(a, b, c) \{ return a + b + c; \}\n" +
        $"var args = [1, 2, 3];\n" +
        $"return sum(...args);"
    , 6)) _passed++; else _failed++;
    
    // ============ PHASE 10 TESTS: Complex Scenarios ============
    
    // 1. Recursion: Factorial
    if (_assert("Recursion Factorial", 
        $"fn fact(n) \{\n" +
        $"    if (n <= 1) return 1\n" +
        $"    return n * fact(n - 1)\n" +
        $"\}\n" +
        $"return fact(5)"
    , 120)) _passed++; else _failed++;
    
    // 2. Recursion: Fibonacci
    if (_assert("Recursion Fibonacci", 
        $"fn fib(n) \{\n" +
        $"    if (n <= 1) return n\n" +
        $"    return fib(n - 1) + fib(n - 2)\n" +
        $"\}\n" +
        $"return fib(10)"
    , 55)) _passed++; else _failed++;
    
    // 3. Closures: Counter
    if (_assert("Closure Counter", 
        $"fn make_counter(start) \{\n" +
        $"    var count = start\n" +
        $"    fn increment() \{\n" +
        $"        count = count + 1\n" +
        $"        return count\n" +
        $"    \}\n" +
        $"    return increment\n" +
        $"\}\n" +
        $"var c = make_counter(10)\n" +
        $"c() // 11\n" +
        $"return c()"
    , 12)) _passed++; else _failed++;
    
    // 4. Higher Order: Map
    if (_assert("Higher Order Map", 
        $"fn map(arr, f) \{\n" +
        $"    var res = []\n" +
        $"    for (var i = 0; i < array_length(arr); i++) \{\n" +
        $"        res[i] = f(arr[i])\n" +
        $"    \}\n" +
        $"    return res\n" +
        $"\}\n" +
        $"fn square(x) \{ return x * x \}\n" +
        $"var numbers = [1, 2, 3]\n" +
        $"var squared = map(numbers, square)\n" +
        $"return squared[2]"
    , 9)) _passed++; else _failed++;
    
    // 5. Higher Order: Filter (manual simulation)
    if (_assert("Higher Order Filter", 
        $"var arr = [1, 5, 2, 8, 3]\n" +
        $"var res = []\n" +
        $"var idx = 0\n" +
        $"for (var i = 0; i < array_length(arr); i++) \{\n" +
        $"    if (arr[i] > 3) \{\n" +
        $"        res[idx] = arr[i]\n" +
        $"        idx++\n" +
        $"    \}\n" +
        $"\}\n" +
        $"return idx"
    , 2)) _passed++; else _failed++;
    
    // 6. Complex Data: Inventory Manager
    if (_assert("Inventory Manager", 
        $"var inv = [\n" +
        $"    \{ id: \"sword\", qty: 1 \},\n" +
        $"    \{ id: \"potion\", qty: 5 \},\n" +
        $"    \{ id: \"shield\", qty: 1 \}\n" +
        $"]\n" +
        $"\n" +
        $"fn find_item(items, name) \{\n" +
        $"    for (item in items) \{\n" +
        $"        if (item.id == name) return item\n" +
        $"    \}\n" +
        $"    return undefined\n" +
        $"\}\n" +
        $"\n" +
        $"var potion = find_item(inv, \"potion\")\n" +
        $"if (potion != undefined) \{\n" +
        $"    potion.qty += 3\n" +
        $"    return potion.qty\n" +
        $"\}\n" +
        $"return 0"
    , 8)) _passed++; else _failed++;
    
    // 7. Algorithm: Bubble Sort
    if (_assert("Bubble Sort", 
        $"var arr = [5, 1, 4, 2, 8]\n" +
        $"var n = array_length(arr)\n" +
        $"for (var i = 0; i < n; i++) \{\n" +
        $"    for (var j = 0; j < n - i - 1; j++) \{\n" +
        $"        if (arr[j] > arr[j+1]) \{\n" +
        $"            var temp = arr[j]\n" +
        $"            arr[j] = arr[j+1]\n" +
        $"            arr[j+1] = temp\n" +
        $"        \}\n" +
        $"    \}\n" +
        $"\}\n" +
        $"return arr[0] + arr[4] // 1 + 8"
    , 9)) _passed++; else _failed++;
    
    // 8. Algorithm: Binary Search
    if (_assert("Binary Search", 
        $"fn binary_search(arr, target) \{\n" +
        $"    var left = 0\n" +
        $"    var right = array_length(arr) - 1\n" +
        $"    while (left <= right) \{\n" +
        $"        var mid = floor((left + right) / 2)\n" +
        $"        if (arr[mid] == target) return mid\n" +
        $"        if (arr[mid] < target) left = mid + 1\n" +
        $"        else right = mid - 1\n" +
        $"    \}\n" +
        $"    return -1\n" +
        $"\}\n" +
        $"var sorted = [10, 20, 30, 40, 50]\n" +
        $"return binary_search(sorted, 40)"
    , 3)) _passed++; else _failed++;
    
    // 9. Matrix Addition
    if (_assert("Matrix Add", 
        $"var m1 = [[1, 2], [3, 4]]\n" +
        $"var m2 = [[5, 6], [7, 8]]\n" +
        $"var res = [[0, 0], [0, 0]]\n" +
        $"\n" +
        $"for (var r = 0; r < 2; r++) \{\n" +
        $"    for (var c = 0; c < 2; c++) \{\n" +
        $"        res[r][c] = m1[r][c] + m2[r][c]\n" +
        $"    \}\n" +
        $"\}\n" +
        $"return res[1][1] // 4 + 8 = 12"
    , 12)) _passed++; else _failed++;
    
    // 10. State Machine (Traffic Light)
    if (_assert("State Machine", 
        $"var state = \"red\"\n" +
        $"var actions = 0\n" +
        $"\n" +
        $"for (var i = 0; i < 5; i++) \{\n" +
        $"    switch (state) \{\n" +
        $"        case \"red\":\n" +
        $"            state = \"green\"\n" +
        $"            break\n" +
        $"        case \"green\":\n" +
        $"            state = \"yellow\"\n" +
        $"            actions++ // go\n" +
        $"            break\n" +
        $"\n" +
        $"        case \"yellow\":\n" +
        $"            state = \"red\"\n" +
        $"            break\n" +
        $"    \}\n" +
        $"\}\n" +
        $"return actions"
    , 2)) _passed++; else _failed++;
    
    // 11. String Parsing (CSV)
    if (_assert("CSV Parse", 
        $"var csv = \"10,20,30,40\"\n" +
        $"var sum = 0\n" +
        $"var num_str = \"\"\n" +
        $"var len = string_length(csv)\n" +
        $"\n" +
        $"for (var i = 1; i <= len; i++) \{\n" +
        $"    var char = string_char_at(csv, i)\n" +
        $"    if (char == \",\") \{\n" +
        $"        sum += real(num_str)\n" +
        $"        num_str = \"\"\n" +
        $"    \} else \{\n" +
        $"        num_str += char\n" +
        $"    \}\n" +
        $"\}\n" +
        $"sum += real(num_str) // last one\n" +
        $"return sum"
    , 100)) _passed++; else _failed++;
    
    // 12. Vector Dot Product
    if (_assert("Vector Struct Dot", 
        $"fn dot(v1, v2) \{\n" +
        $"    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z\n" +
        $"\}\n" +
        $"var a = \{x: 1, y: 2, z: 3\}\n" +
        $"var b = \{x: 4, y: -5, z: 6\}\n" +
        $"return dot(a, b) // 4 - 10 + 18 = 12"
    , 12)) _passed++; else _failed++;
    
    // 13. Function Wrapper (Mock Decorator)
    if (_assert("Function Wrapper", 
        $"fn logger(function, arg) \{\n" +
        $"    // log \"calling\"\n" +
        $"    var res = function(arg)\n" +
        $"    // log \"done\"\n" +
        $"    return res\n" +
        $"\}\n" +
        $"fn double_it(n) \{ return n * 2 \}\n" +
        $"return logger(double_it, 21)"
    , 42)) _passed++; else _failed++;
    
    // 14. Deep Nesting Update
    if (_assert("Deep Nesting", 
        $"var config = \{\n" +
        $"    graphics: \{\n" +
        $"        resolution: \{ w: 1920, h: 1080 \}, \n" +
        $"        settings: \{ bloom: true \}\n" +
        $"    \}\n" +
        $"\}\n" +
        $"config.graphics.resolution.w = 2560\n" +
        $"return config.graphics.resolution.w"
    , 2560)) _passed++; else _failed++;
    
    // 15. Scope Shadowing
    if (_assert("Scope Shadowing", 
        $"var x = 10\n" +
        $"fn test(x) \{\n" +
        $"    var y = 20\n" +
        $"    return x + y // param x (5) + y (20) = 25\n" +
        $"\}\n" +
        $"return test(5) + x // 25 + 10 = 35"
    , 35)) _passed++; else _failed++;
    
    // 16. Array Merging (Spread)
    if (_assert("Merge Configs via Spread", 
        $"var default_tags = [\"item\", \"pickable\"]\n" +
        $"var weapon_tags = [\"weapon\", \"damage\"]\n" +
        $"var all_tags = [...default_tags, ...weapon_tags, \"legendary\"]\n" +
        $"return all_tags[4]"
    , "legendary")) _passed++; else _failed++;
    
    // 17. Exception in Loop
    if (_assert("Exception Loop", 
        $"var sum = 0\n" +
        $"var items = [10, 20, undefined, 30]\n" +
        $"for (item in items) \{\n" +
        $"     try \{\n" +
        $"         if (item == undefined) throw \"bad item\"\n" +
        $"         sum += item\n" +
        $"     \} catch (e) \{\n" +
        $"         // ignore\n" +
        $"     \}\n" +
        $"\}\n" +
        $"return sum"
    , 60)) _passed++; else _failed++;
    
    // 18. Prime Finder
    if (_assert("Prime Finder", 
        $"fn is_prime(n) \{\n" +
        $"    if (n < 2) return false\n" +
        $"    for (var i = 2; i * i <= n; i++) \{\n" +
        $"        if (n % i == 0) return false\n" +
        $"    \}\n" +
        $"    return true\n" +
        $"\}\n" +
        $"var count = 0\n" +
        $"for (var k = 1; k < 20; k++) \{\n" +
        $"    if (is_prime(k)) count++\n" +
        $"\}\n" +
        $"// 2, 3, 5, 7, 11, 13, 17, 19 -> 8 primes\n" +
        $"return count"
    , 8)) _passed++; else _failed++;
    
    // 19. Context Binding (this simulation)
    if (_assert("Object Method simulation", 
        $"fn create_player(name) \{\n" +
        $"    var p = \{ name: name, hp: 100 \}\n" +
        $"    p.heal = fn(amount) \{\n" +
        $"        // 'p' is captured by closure\n" +
        $"        p.hp += amount\n" +
        $"        return p.hp\n" +
        $"    \}\n" +
        $"    return p\n" +
        $"\}\n" +
        $"var player = create_player(\"Hero\")\n" +
        $"player.heal(50)\n" +
        $"return player.hp"
    , 150)) _passed++; else _failed++;
    
    // 20. Mini Evaluator
    if (_assert("Mini Eval", 
        $"var program = [1, 5, 2] // ADD, 5, 2\n" +
        $"// Ops: 1=ADD, 2=SUB\n" +
        $"var ip = 0\n" +
        $"var reg = 0\n" +
        $"while (ip < array_length(program)) \{\n" +
        $"    var op = program[ip]\n" +
        $"    ip++\n" +
        $"    if (op == 1) \{\n" +
        $"        var val1 = program[ip]; ip++;\n" +
        $"        var val2 = program[ip]; ip++;\n" +
        $"        reg = val1 + val2\n" +
        $"    \}\n" +
        $"\}\n" +
        $"return reg"
    , 7)) _passed++; else _failed++;
    
    // ============ PHASE 11 TESTS: Optional Parameters ============
    
    // 1. Implicit Undefined
    if (_assert("Opt Param Implicit", 
        $"fn opt_implicit(a, b) \{\n" +
        $"    return [a, b]\n" +
        $"\}\n" +
        $"var res = opt_implicit(10)\n" +
        $"return res[1] // should be undefined"
    , undefined)) _passed++; else _failed++;
    
    // 2. Default Value
    if (_assert("Opt Param Default", 
        $"fn opt_def(a = 100) \{\n" +
        $"    return a\n" +
        $"\}\n" +
        $"return opt_def()"
    , 100)) _passed++; else _failed++;
    
    // 3. Default Value Override
    if (_assert("Opt Param Override", 
        $"fn opt_def2(a = 100) \{\n" +
        $"    return a\n" +
        $"\}\n" +
        $"return opt_def2(50)"
    , 50)) _passed++; else _failed++;
    
    // 4. Mixed Defaults
    if (_assert("Opt Param Mixed", 
        $"fn opt_mixed(a, b = 2) \{\n" +
        $"    return a + b\n" +
        $"\}\n" +
        $"return opt_mixed(1)"
    , 3)) _passed++; else _failed++;
    
    // 5. Default Expression
    if (_assert("Opt Param Expr", 
        $"fn opt_expr(a = 1 + 2) \{\n" +
        $"    return a\n" +
        $"\}\n" +
        $"return opt_expr()"
    , 3)) _passed++; else _failed++;
    
    
    // Numeric Underscores
    if (_assert("Numeric Underscores", "return 1_000 + 500", 1500)) _passed++; else _failed++;
    
    // ============ PHASE 12 TESTS: Class System ============
    
    // 1. Basic Class Instantiation
    if (_assert("Class Basic", 
        $"class Point \{\n" +
        $"    fn constructor(x, y) \{\n" +
        $"        this.x = x\n" +
        $"        this.y = y\n" +
        $"    \}\n" +
        $"    fn magnitude() \{\n" +
        $"        return this.x * this.x + this.y * this.y\n" +
        $"    \}\n" +
        $"\}\n" +
        $"var p = new Point(3, 4)\n" +
        $"return p.magnitude()"
    , 25)) _passed++; else _failed++;
    
    // 2. Class Inheritance
    if (_assert("Class Inheritance", 
        $"class Animal \{\n" +
        $"    fn constructor(name) \{ this.name = name \}\n" +
        $"    fn speak() \{ return '...' \}\n" +
        $"\}\n" +
        $"class Dog extends Animal \{\n" +
        $"    fn constructor(name) \{\n" +
        $"        super(name)\n" +
        $"    \}\n" +
        $"    fn speak() \{ return 'Woof!' \}\n" +
        $"\}\n" +
        $"var d = new Dog('Rex')\n" +
        $"return d.speak()", 
        "Woof!")) _passed++; else _failed++;
    
    // 3. Super Method Call
    if (_assert("Super Method", 
        $"class A \{\n" +
        $"    fn get_val() \{ return 10 \}\n" +
        $"\}\n" +
        $"class B extends A \{\n" +
        $"    fn get_val() \{ return super.get_val() + 5 \}\n" +
        $"\}\n" +
        $"var b = new B()\n" +
        $"return b.get_val()"
    , 15)) _passed++; else _failed++;
    
    // 4. Static Member
    if (_assert("Static Method", 
        $"class MathUtils \{\n" +
        $"    static fn add(a, b) \{ return a + b \}\n" +
        $"\}\n" +
        $"return MathUtils.add(10, 20)"
    , 30)) _passed++; else _failed++;
    
    // 5. Polymorphism (Method Overriding)
    if (_assert("Polymorphism", 
        $"class Shape \{ fn area() \{ return 0 \} \}\n" +
        $"class Rect extends Shape \{ fn area() \{ return 10 \} \}\n" +
        $"class Circle extends Shape \{ fn area() \{ return 20 \} \}\n" +
        $"\n" +
        $"var shapes = [new Rect(), new Circle()]\n" +
        $"var total = 0\n" +
        $"for (s in shapes) total += s.area()\n" +
        $"return total"
    , 30)) _passed++; else _failed++;
    
    // 6. Encapsulation (Syntax Check - Runtime enforcement optional)
    if (_assert("Encapsulation Syntax", 
        $"class Box \{\n" +
        $"    private var content = 0\n" +
        $"    fn set_content(c) \{ this.content = c \}\n" +
        $"    fn get_content() \{ return this.content \}\n" +
        $"\}\n" +
        $"var b = new Box()\n" +
        $"b.set_content(42)\n" +
        $"return b.get_content()"
    , 42)) _passed++; else _failed++;
    
    // 7. Abstraction (Syntax Check - Abstract classes)
    if (_assert("Abstraction Syntax", 
        $"abstract class Base \{\n" +
        $"    abstract fn process() \{\}\n" +
        $"\}\n" +
        $"class Impl extends Base \{\n" +
        $"    fn process() \{ return 1 \}\n" +
        $"\}\n" +
        $"var i = new Impl()\n" +
        $"return i.process()"
    , 1)) _passed++; else _failed++;
    
    // ============ REGEX TESTS ============
    if (_assert("Is Regex True", "return is_regex(/abc/)", true)) _passed++; else _failed++;
    if (_assert("Is Regex False", "return is_regex('abc')", false)) _passed++; else _failed++;
    if (_assert("Typeof Regex", "return typeof(/abc/)", "regex")) _passed++; else _failed++;
    if (_assert("Regex Lit", "return /abc/.pattern", "abc")) _passed++; else _failed++;
    if (_assert("Regex Test", "return regex_test(\"abc\", /abc/)", true)) _passed++; else _failed++;
    if (_assert("Regex Match", "var m = regex_match(\"abc\", /abc/); return m[0]", "abc")) _passed++; else _failed++;
    if (_assert("Regex Replace", "return regex_replace(\"banana\", /a/, \"o\")", "bonana")) _passed++; else _failed++;
    if (_assert("Regex Replace All", "return regex_replace(\"banana\", /a/g, \"o\")", "bonono")) _passed++; else _failed++;
    if (_assert("Regex Split", "var r = regex_split(\"a,b,c\", /,/); return r[1]", "b,c")) _passed++; else _failed++;
    if (_assert("Regex Split Global", "var r = regex_split(\"a,b,c\", /,/g); return r[1]", "b")) _passed++; else _failed++;
    
    // ============ COMPLEX STRESS TESTS ============
    
    // 1. Advanced Recursion: Ackermann Function
    if (_assert("Ackermann Function", 
        $"fn ack(m, n) \{\n" +
        $"    if (m == 0) return n + 1\n" +
        $"    if (m > 0 && n == 0) return ack(m - 1, 1)\n" +
        $"    return ack(m - 1, ack(m, n - 1))\n" +
        $"\}\n" +
        $"return ack(3, 2)"
    , 29)) _passed++; else _failed++;
    
    // 2. Advanced Data Structures: Linked List
    if (_assert("Linked List", 
        $"class Node \{\n" +
        $"    fn constructor(val) \{\n" +
        $"        this.val = val\n" +
        $"        this.next = undefined\n" +
        $"    \}\n" +
        $"\}\n" +
        $"class LinkedList \{\n" +
        $"    fn constructor() \{\n" +
        $"        this.head = undefined\n" +
        $"        this.size = 0\n" +
        $"    \}\n" +
        $"    fn add(val) \{\n" +
        $"        var newNode = new Node(val)\n" +
        $"        if (this.head == undefined) \{\n" +
        $"            this.head = newNode\n" +
        $"        \} else \{\n" +
        $"            var current = this.head\n" +
        $"            while (current.next != undefined) \{\n" +
        $"                current = current.next\n" +
        $"            \}\n" +
        $"            current.next = newNode\n" +
        $"        \}\n" +
        $"        this.size++\n" +
        $"    \}\n" +
        $"    fn get(index) \{\n" +
        $"        if (index < 0 || index >= this.size) return undefined\n" +
        $"        var current = this.head\n" +
        $"        for (var i = 0; i < index; i++) \{\n" +
        $"            current = current.next\n" +
        $"        \}\n" +
        $"        return current.val\n" +
        $"    \}\n" +
        $"\}\n" +
        $"var list = new LinkedList()\n" +
        $"list.add(10)\n" +
        $"list.add(20)\n" +
        $"list.add(30)\n" +
        $"return list.get(1) + list.get(2)"
    , 50)) _passed++; else _failed++;
    
    // 3. Closure Stress: Function Chains
    if (_assert("Closure Chains", 
        $"fn make_adder(x) \{\n" +
        $"    return fn(y) \{\n" +
        $"        return fn(z) \{\n" +
        $"            return x + y + z\n" +
        $"        \}\n" +
        $"    \}\n" +
        $"\}\n" +
        $"var add5 = make_adder(5)\n" +
        $"var add5_and_10 = add5(10)\n" +
        $"return add5_and_10(20)"
    , 35)) _passed++; else _failed++;
    
    // 4. OOP Complexity: Multi-level Inheritance & Overriding
    if (_assert("Multi-level Inheritance", 
        $"class GrandParent \{\n" +
        $"    fn method() \{ return 1 \}\n" +
        $"\}\n" +
        $"class Parent extends GrandParent \{\n" +
        $"    fn method() \{ return super.method() + 10 \}\n" +
        $"\}\n" +
        $"class Child extends Parent \{\n" +
        $"    fn method() \{ return super.method() + 100 \}\n" +
        $"\}\n" +
        $"var c = new Child()\n" +
        $"return c.method()"
    , 111)) _passed++; else _failed++;
    
    // 5. Exception Handling: Nested Try-Catch with Re-throw
    if (_assert("Nested Exception", 
        $"fn fail() \{\n" +
        $"    throw 42\n" +
        $"\}\n" +
        $"try \{\n" +
        $"    try \{\n" +
        $"        fail()\n" +
        $"    \} catch (e) \{\n" +
        $"        throw e + 1\n" +
        $"    \}\n" +
        $"\} catch (e) \{\n" +
        $"    return e\n" +
        $"\}\n" +
        $"return 0"
    , 43)) _passed++; else _failed++;
    
    // 6. Algorithms: Merge Sort
    if (_assert("Merge Sort", 
        $"fn merge(left, right) \{\n" +
        $"    var res = []\n" +
        $"    var i = 0\n" +
        $"    var j = 0\n" +
        $"    while (i < array_length(left) && j < array_length(right)) \{\n" +
        $"        if (left[i] < right[j]) \{\n" +
        $"            array_push(res, left[i])\n" +
        $"            i++\n" +
        $"        \} else \{\n" +
        $"            array_push(res, right[j])\n" +
        $"            j++\n" +
        $"        \}\n" +
        $"    \}\n" +
        $"    while (i < array_length(left)) \{\n" +
        $"        array_push(res, left[i])\n" +
        $"        i++\n" +
        $"    \}\n" +
        $"    while (j < array_length(right)) \{\n" +
        $"        array_push(res, right[j])\n" +
        $"        j++\n" +
        $"    \}\n" +
        $"    return res\n" +
        $"\}\n" +
        $"fn merge_sort(arr) \{\n" +
        $"    if (array_length(arr) <= 1) return arr\n" +
        $"    var mid = floor(array_length(arr) / 2)\n" +
        $"    var left = []\n" +
        $"    var right = []\n" +
        $"    for (var i = 0; i < mid; i++) array_push(left, arr[i])\n" +
        $"    for (var i = mid; i < array_length(arr); i++) array_push(right, arr[i])\n" +
        $"    return merge(merge_sort(left), merge_sort(right))\n" +
        $"\}\n" +
        $"var arr = [5, 2, 9, 1, 5, 6]\n" +
        $"var sorted = merge_sort(arr)\n" +
        $"return sorted[0] + sorted[1] + sorted[5] // 1 + 2 + 9 = 12"
    , 12)) _passed++; else _failed++;
    
    // ============ ROBUSTNESS & EDGE CASES ============
    
    // 1. Shared Closure State: Multiple closures sharing the same captured variable
    if (_assert("Shared Closure Mutation", 
        $"fn make_counter() \{\n" +
        $"    var count = 0\n" +
        $"    return \{\n" +
        $"        inc: fn() \{ count++ \},\n" +
        $"        dec: fn() \{ count-- \},\n" +
        $"        get: fn() \{ return count \}\n" +
        $"    \}\n" +
        $"\}\n" +
        $"var c = make_counter()\n" +
        $"c.inc()\n" +
        $"c.inc()\n" +
        $"c.dec()\n" +
        $"return c.get()"
    , 1)) _passed++; else _failed++;
    
    // 2. Deep Control Flow: Nested loops, if-statements, and returns
    if (_assert("Deep Nesting Return", 
        $"fn complex_flow(n) \{\n" +
        $"    var sum = 0\n" +
        $"    for (var i = 0; i < n; i++) \{\n" +
        $"        if (i == 5) \{\n" +
        $"            for (var j = 0; j < 10; j++) \{\n" +
        $"                if (j == 3) return sum + i + j\n" +
        $"                sum++\n" +
        $"            \}\n" +
        $"        \}\n" +
        $"        sum++\n" +
        $"    \}\n" +
        $"    return sum\n" +
        $"\}\n" +
        $"return complex_flow(10)"
    , 16)) _passed++; else _failed++;
    
    // 3. Method Binding & this: Verify that extracting a method still works (bound at access)
    if (_assert("Method Extraction Binding", 
        $"class Greeter \{\n" +
        $"    fn constructor(prefix) \{ this.prefix = prefix \}\n" +
        $"    fn greet(name) \{ return this.prefix + \" \" + name \}\n" +
        $"\}\n" +
        $"var g = new Greeter(\"Hello\")\n" +
        $"var f = g.greet\n" +
        $"return f(\"World\")"
    , "Hello World")) _passed++; else _failed++;
    
    // 4. Static Method Access
    if (_assert("Static Method Counter", 
        $"class GlobalState \{\n" +
        $"    static fn get_version() \{ return 123 \}\n" +
        $"\}\n" +
        $"return GlobalState.get_version()"
    , 123)) _passed++; else _failed++;
    
    // 5. Complex Destructuring: Nested object and array patterns
    if (_assert("Nested Destructuring", 
        $"var data = \{\n" +
        $"    users: [\n" +
        $"        \{ id: 101, meta: \{ active: true \} \},\n" +
        $"        \{ id: 102, meta: \{ active: false \} \}\n" +
        $"    ]\n" +
        $"\}\n" +
        $"var \{ users: [u1, \{ id: id2, meta: \{ active: a2 \} \}] \} = data\n" +
        $"return u1.id + id2 + (a2 ? 1000 : 0)"
    , 203)) _passed++; else _failed++;
    
    // 6. Closure capture of arguments
    if (_assert("Argument Capture Closure", 
        $"fn wrapper(val) \{\n" +
        $"    return fn() \{ return val \}\n" +
        $"\}\n" +
        $"var f1 = wrapper(10)\n" +
        $"var f2 = wrapper(20)\n" +
        $"return f1() + f2()"
    , 30)) _passed++; else _failed++;
    
    // 7. Recursive Closure
    if (_assert("Recursive Closure", 
        $"var fact = undefined\n" +
        $"fact = fn(n) \{\n" +
        $"    if (n <= 1) return 1\n" +
        $"    return n * fact(n - 1)\n" +
        $"\}\n" +
        $"return fact(5)"
    , 120)) _passed++; else _failed++;
    
    // 8. Array method-like behavior (if supported via context)
    // Testing array_length as a first-class citizen inside a function
    if (_assert("First-class Builtin", 
        $"fn do_call(f, arg) \{\n" +
        $"    return f(arg)\n" +
        $"\}\n" +
        $"return do_call(array_length, [1, 2, 3, 4, 5])"
    , 5)) _passed++; else _failed++;
    
    // ============ Debug Tests ============
    
    // ============ PHASE 13 TESTS: Syntax Enhancements & Exports ============
    
    // 1. Single Quote Strings
    if (_assert("Single Quote String", "return 'hello world'", "hello world")) _passed++; else _failed++;
    // if (_assert("Mixed Quotes 1", "return 'say \"hello\"'", "say \"hello\"")) _passed++; else _failed++;
    // if (_assert("Mixed Quotes 2", "return \"say 'hello'\"", "say 'hello'")) _passed++; else _failed++;
    
    // 2. Strict Global Var
    if (_assert("Global Var Syntax", 
        $"global var g_test = 999\n" +
        $"return g_test"
    , 999)) _passed++; else _failed++;
    
    // 3. Export Variables
    try {
        // Compile Module with Export Vars
        var _mod_code = 
            $"export var X = 10\n" +
            $"export global var Y = 20\n" +
            $"var Z = 30 // Internal\n" +
            $"export fn get_z() \{ return Z \}"
        ;
        var _mod_bc = proglang_compile(_mod_code);
        
        // Run Module
        var _mod_vm = proglang_vm_create();
        if (!variable_global_exists("proglang_modules")) global.proglang_modules = {}
        global.proglang_modules[$ "vars_lib"] = { exports: {}, loaded: true }
        _mod_vm[@ PROG_VM.ACTIVE_MODULE] = global.proglang_modules[$ "vars_lib"];
        proglang_vm_run(_mod_vm, _mod_bc);
        proglang_vm_free(_mod_vm);
        
        // Consumer
        var _consumer_code = 
            $"import X, Y, get_z from \"vars_lib\"\n" +
            $"return X + Y + get_z()"
        ;
        // 10 + 20 + 30 = 60
        if (_assert("Export Variables", _consumer_code, 60)) _passed++; else _failed++;
        
    } catch (_e) {
        show_debug_message($"[Proglang Test] Export Var Exception: {_e}");
        _failed++;
    }
    
    // ============ PHASE 14 TESTS: Simple Tests (Logic, Math, Types) ============
    
    // 1. Boolean Logic
    if (_assert("Logic NOT", "return !true", false)) _passed++; else _failed++;
    if (_assert("Logic NOT NOT", "return !!true", true)) _passed++; else _failed++;
    if (_assert("Logic Precedence", "return true || false && false", true)) _passed++; else _failed++; // true || (false && false) -> true
    
    // 2. Math Precedence
    if (_assert("Math Precedence", "return 1 + 2 * 3", 7)) _passed++; else _failed++;
    if (_assert("Math Paren", "return (1 + 2) * 3", 9)) _passed++; else _failed++;
    if (_assert("Math Negative", "return -5 + 3", -2)) _passed++; else _failed++;
    if (_assert("PEMDAS", "return 6/2*(2+1)", 9)) _passed++; else _failed++;
    
    // 3. Comparisons
    if (_assert("Compare LT", "return 5 < 10", true)) _passed++; else _failed++;
    if (_assert("Compare GTE", "return 5 >= 5", true)) _passed++; else _failed++;
    if (_assert("Compare EQ String", "return 'abc' == \"abc\"", true)) _passed++; else _failed++;
    if (_assert("Compare NEq", "return 10 != 5", true)) _passed++; else _failed++;
    
    // ============ PHASE 15 TESTS: Complex Tests (Structures & Algorithms) ============
    
    // 1. Array Map Implementation
    if (_assert("Complex Array Map", 
        $"fn map(arr, f) \{\n" +
        $"    var res = []\n" +
        $"    var len = array_length(arr)\n" +
        $"    for (var i = 0; i < len; i++) \{\n" +
        $"        res[i] = f(arr[i])\n" +
        $"    \}\n" +
        $"    return res\n" +
        $"\}\n" +
        $"var nums = [1, 2, 3]\n" +
        $"var doubled = map(nums, fn(x) \{ return x * 2 \})\n" +
        $"return doubled[0] + doubled[1] + doubled[2]" // 2 + 4 + 6 = 12
    , 12)) _passed++; else _failed++;
    
    // 2. Nested Object Sum
    if (_assert("Nested Object Sum", 
        $"var data = \{\n" +
        $"    a: \{ val: 10 \},\n" +
        $"    b: \{ val: 20 \},\n" +
        $"    c: \{ val: 30 \}\n" +
        $"\}\n" +
        $"var total = 0\n" +
        $"// Access by key manually since for-in on object key order is undefined usually, \n" +
        $"// but lets verify direct access logic in deep structure\n" +
        $"total += data.a.val\n" +
        $"total += data[\"b\"].val\n" +
        $"total += data.c[\"val\"]\n" +
        $"return total"
    , 60)) _passed++; else _failed++;
    
    // ============ PHASE 16 TESTS: Really Complex Tests (Recursion, OOP, State) ============
    
    // 1. Recursive Stress (Ackermann Function)
    // ack(2, 3) = 9
    if (_assert("Ackermann(2,3)", 
        $"fn ack(m, n) \{\n" +
        $"    if (m == 0) return n + 1\n" +
        $"    if (m > 0 && n == 0) return ack(m - 1, 1)\n" +
        $"    return ack(m - 1, ack(m, n - 1))\n" +
        $"\}\n" +
        $"return ack(2, 3)"
    , 9)) _passed++; else _failed++;
    
    // 2. Class Deep Inheritance
    if (_assert("Deep Inheritance", 
        $"class Base \{ fn name() \{ return \"A\" \} \}\n" +
        $"class Middle extends Base \{ fn name() \{ return \"B -> \" + super.name() \} \}\n" +
        $"class Top extends Middle \{ fn name() \{ return \"C -> \" + super.name() \} \}\n" +
        $"return new Top().name()"
    , "C -> B -> A")) _passed++; else _failed++;
    
    // 3. Closure State Machine
    if (_assert("Closure State Machine", 
        $"fn create_toggle() \{\n" +
        $"    var state = false\n" +
        $"    return \{\n" +
        $"        toggle: fn() \{ state = !state; return state \},\n" +
        $"        value: fn() \{ return state \}\n" +
        $"    \}\n" +
        $"\}\n" +
        $"var t = create_toggle()\n" +
        $"var s1 = t.value()   // false\n" +
        $"var s2 = t.toggle()  // true\n" +
        $"var s3 = t.toggle()  // false\n" +
        $"var s4 = t.value()   // false\n" +
        $"return !s1 && s2 && !s3 && !s4" // true && true && true && true
    , true)) _passed++; else _failed++;
    
    // ============ PHASE 17 TESTS: 50 More Tests - Batch 1: Primitives ============
    
    // 1. Bitwise AND
    if (_assert("Bitwise AND", "return 12 & 5", 4)) _passed++; else _failed++; // 1100 & 0101 = 0100 (4)
    
    // 2. Bitwise OR
    if (_assert("Bitwise OR", "return 12 | 5", 13)) _passed++; else _failed++; // 1100 | 0101 = 1101 (13)
    
    // 3. Bitwise XOR
    if (_assert("Bitwise XOR", "return 12 ^ 5", 9)) _passed++; else _failed++; // 1100 ^ 0101 = 1001 (9)
    
    // 4. Bitwise Left Shift
    if (_assert("Bitwise LShift", "return 2 << 2", 8)) _passed++; else _failed++;
    
    // 5. Bitwise Right Shift
    if (_assert("Bitwise RShift", "return 8 >> 2", 2)) _passed++; else _failed++;
    
    // 6. Ternary True
    if (_assert("Ternary True", "return true ? 10 : 20", 10)) _passed++; else _failed++;
    
    // 7. Ternary False
    if (_assert("Ternary False", "return false ? 10 : 20", 20)) _passed++; else _failed++;
    
    // 8. Ternary Chain
    // a ? b : c ? d : e -> a ? b : (c ? d : e)
    if (_assert("Ternary Chain", "return false ? 1 : false ? 2 : 3", 3)) _passed++; else _failed++;
    
    // 9. String Concat (Number)
    if (_assert("Str Concat Num", "return 'val: ' + 10", "val: 10")) _passed++; else _failed++;
    
    // 10. String Concat (Bool)
    if (_assert("Str Concat Bool", "return 'is ' + true", "is true")) _passed++; else _failed++;
    
    // ============ Batch 2: Control Flow ============
    
    // 11. Nested Looping
    if (_assert("Nested Loops", 
        $"var sum = 0\n" +
        $"for (var i = 0; i < 3; i++) \{\n" +
        $"    for (var j = 0; j < 3; j++) \{\n" +
        $"        sum++\n" +
        $"    \}\n" +
        $"\}\n" +
        $"return sum"
    , 9)) _passed++; else _failed++;
    
    // 12. Continue in While
    if (_assert("While Continue", 
        $"var i = 0; var sum = 0\n" +
        $"while (i < 5) \{\n" +
        $"    i++\n" +
        $"    if (i == 3) continue\n" +
        $"    sum += i\n" +
        $"\}\n" +
        $"return sum" // 1 + 2 + 4 + 5 = 12
    , 12)) _passed++; else _failed++;
    
    // 13. Continue in For
    if (_assert("For Continue", 
        $"var sum = 0\n" +
        $"for (var i = 0; i < 5; i++) \{\n" +
        $"    if (i == 2) continue\n" +
        $"    sum += i\n" +
        $"\}\n" +
        $"return sum" // 0 + 1 + 3 + 4 = 8
    , 8)) _passed++; else _failed++;
    
    // 14. Variable Shadowing
    if (_assert("Shadowing", 
        $"var x = 10\n" +
        $"\{\n" +
        $"    var x = 20\n" +
        $"    x += 5\n" +
        $"\}\n" +
        $"return x"
    , 10)) _passed++; else _failed++;
    
    // 15. Switch Expression
    if (_assert("Switch Expr", 
        $"var x = 10\n" +
        $"var res = 0\n" +
        $"switch (x + 5) \{\n" +
        $"    case 15: res = 1; break\n" +
        $"    default: res = 2\n" +
        $"\}\n" +
        $"return res"
    , 1)) _passed++; else _failed++;
    
    // 16. Switch Fallthrough (Simulated if supported)
    // Proglang currently compiles cases as independent blocks usually?
    // Let's test if multiple cases match one body logic (stacking cases).
    // Note: Proglang parser might treat multiple cases as fallthrough if empty?
    if (_assert("Switch Stacking", 
        $"var x = 1\n" +
        $"switch (x) \{\n" +
        $"    case 1:\n" + // Fallthrough to 2
        $"    case 2: return 'Hit'\n" +
        $"\}\n" +
        $"return 'Miss'"
    , "Hit")) _passed++; else _failed++;
    
    // 17. Break from Infinite Loop
    if (_assert("Break Infinite", 
        $"var i = 0\n" +
        $"while (true) \{\n" +
        $"    i++\n" +
        $"    if (i > 5) break\n" +
        $"\}\n" +
        $"return i"
    , 6)) _passed++; else _failed++;
    
    // 18. Nested If Else Chain
    if (_assert("If Else Chain", 
        $"var x = 10\n" +
        $"if (x < 5) return 1\n" +
        $"else if (x < 8) return 2\n" +
        $"else if (x == 10) return 3\n" +
        $"else return 4"
    , 3)) _passed++; else _failed++;
    
    // 19. Do-While (Repeat) Logic with Variable
    if (_assert("Repeat Variable", 
        $"var n = 3\n" +
        $"var sum = 0\n" +
        $"repeat (n) \{\n" +
        $"    sum += 10\n" +
        $"\}\n" +
        $"return sum"
    , 30)) _passed++; else _failed++;
    
    // 20. Empty Block
    if (_assert("Empty Block", 
        $"\{\}\n" +
        $"var x = 1\n" +
        $"return x"
    , 1)) _passed++; else _failed++;
    
    // ============ Batch 3: Functions & Closures ============
    
    // 21. Currying
    if (_assert("Currying", 
        $"fn add(x) \{ return fn(y) \{ return x + y \} \}\n" +
        $"var add5 = add(5)\n" +
        $"return add5(10)"
    , 15)) _passed++; else _failed++;
    
    // 22. Higher Order Composition
    if (_assert("Function Compose", 
        $"fn compose(f, g) \{ return fn(x) \{ return f(g(x)) \} \}\n" +
        $"fn double(x) \{ return x * 2 \}\n" +
        $"fn square(x) \{ return x * x \}\n" +
        $"var f = compose(double, square)\n" +
        $"return f(3)" // double(square(3)) = double(9) = 18
    , 18)) _passed++; else _failed++;
    
    // 23. Recursion (Fibonacci)
    if (_assert("Fibonacci Rec", 
        $"fn fib(n) \{\n" +
        $"    if (n < 2) return n\n" +
        $"    return fib(n - 1) + fib(n - 2)\n" +
        $"\}\n" +
        $"return fib(6)" // 0, 1, 1, 2, 3, 5, 8
    , 8)) _passed++; else _failed++;
    
    // 24. Mutual Recursion
    // Requires hoisting or forward declaration support?
    // Proglang function decls are hoisted if at block level? Or we use 'var' and assignment.
    // If we use 'fn name()', it might verify hoisting.
    if (_assert("Mutual Recursion", 
        $"fn is_even(n) \{\n" +
        $"    if (n == 0) return true\n" +
        $"    return is_odd(n - 1)\n" +
        $"\}\n" +
        $"fn is_odd(n) \{\n" +
        $"    if (n == 0) return false\n" +
        $"    return is_even(n - 1)\n" +
        $"\}\n" +
        $"return is_even(4)"
    , true)) _passed++; else _failed++;
    
    // 25. Closure Counter (Multiple Instances)
    if (_assert("Closure Counters", 
        $"fn make_counter() \{\n" +
        $"    var count = 0\n" +
        $"    return fn() \{ count++; return count \}\n" +
        $"\}\n" +
        $"var c1 = make_counter()\n" +
        $"var c2 = make_counter()\n" +
        $"c1()\n" +
        $"c1()\n" +
        $"return c1() + c2()" // 3 + 1 = 4
    , 4)) _passed++; else _failed++;
    
    // 26. Scope Chain (Global, Outer, Inner)
    if (_assert("Scope Chain", 
        $"global var g_val = 100\n" +
        $"fn outer() \{\n" +
        $"    var o_val = 20\n" +
        $"    return fn() \{\n" +
        $"        var i_val = 3\n" +
        $"        return g_val + o_val + i_val\n" +
        $"    \}\n" +
        $"\}\n" +
        $"return outer()()" // 100 + 20 + 3 = 123
    , 123)) _passed++; else _failed++;
    
    // 27. Default Parameters Complex
    if (_assert("Default Param Complex", 
        $"fn complex_def(a, b = a * 2, c = a + b) \{\n" +
        $"    return c\n" +
        $"\}\n" +
        $"return complex_def(2)" // b=4, c=2+4=6
    , 6)) _passed++; else _failed++;
    
    // 28. IIFE (Immediately Invoked Function Expression)
    if (_assert("IIFE", 
        $"return (fn(x) \{ return x * x \})(5)"
    , 25)) _passed++; else _failed++;
    
    // 29. Function as Argument
    if (_assert("Func Arg", 
        $"fn exec(f) \{ return f() \}\n" +
        $"return exec(fn() \{ return 'Success' \})"
    , "Success")) _passed++; else _failed++;
    
    // 30. Argument Shadowing
    if (_assert("Arg Shadowing", 
        $"var x = 10\n" +
        $"fn test(x) \{ return x \}\n" + // Param shadows global
        $"return test(5)"
    , 5)) _passed++; else _failed++;
    
    // ============ Batch 4: OOP & Errors ============
    
    // 31. Static Fields Modifier
    if (_assert("Static Fields", 
        $"class Config \{\n" +
        $"    static var version = 1.0\n" +
        $"    static fn update(v) \{ Config.version = v \}\n" +
        $"\}\n" +
        $"Config.update(2.0)\n" +
        $"return Config.version"
    , 2.0)) _passed++; else _failed++;
    
    // 32. Dynamic Member Access
    if (_assert("Dynamic Member", 
        $"class Box \{ fn constructor() \{ this.value = 42 \} \}\n" +
        $"var b = new Box()\n" +
        $"var key = \"value\"\n" +
        $"return b[key]"
    , 42)) _passed++; else _failed++;
    
    // 33. Method Override Call Super
    if (_assert("Override Super", 
        $"class A \{ fn val() \{ return 1 \} \}\n" +
        $"class B extends A \{ fn val() \{ return super.val() + 1 \} \}\n" +
        $"class C extends B \{ fn val() \{ return super.val() + 1 \} \}\n" +
        $"return new C().val()" // 1 + 1 + 1 = 3
    , 3)) _passed++; else _failed++;
    
    // 34. Try Catch Basic
    if (_assert("Try Catch", 
        $"try \{\n" +
        $"    throw \"Error\"\n" +
        $"\} catch (e) \{\n" +
        $"    return e\n" +
        $"\}\n" +
        $"return \"No Error\""
    , "Error")) _passed++; else _failed++;
    
    // 35. Try Catch Nesting
    if (_assert("Try Nested", 
        $"try \{\n" +
        $"    try \{\n" +
        $"        throw \"Inner\"\n" +
        $"    \} catch (e) \{\n" +
        $"        throw e + \" handled\"\n" + // Re-throw
        $"    \}\n" +
        $"\} catch (e2) \{\n" +
        $"    return e2\n" +
        $"\}\n" +
        $"return \"Failed\""
    , "Inner handled")) _passed++; else _failed++;
    
    // 36. Object Trailing Comma
    if (_assert("Obj Trailing Comma", 
        $"var o = \{ a: 1, b: 2, \}\n" + // Trailing comma
        $"return o.a + o.b"
    , 3)) _passed++; else _failed++;
    
    // 37. Array Trailing Comma
    if (_assert("Arr Trailing Comma", 
        $"var a = [1, 2, ]\n" +
        $"return array_length(a)"
    , 2)) _passed++; else _failed++;
    
    // 38. Instanceof Check (Simulated via reflection or duck typing)
    // Assuming we don't have instanceof operator yet?
    // Let's test property existence check for 'value' in Box from test 32
    if (_assert("Prop Exists", 
        $"var o = \{ x: 10 \}\n" +
        $"return struct_exists(o, \"x\")"
    , true)) _passed++; else _failed++;
    
    // 39. Static vs Instance Name Collision
    if (_assert("Static Instance Collision", 
        $"class Collision \{\n" +
        $"    static var x = 10\n" +
        $"    var x = 20\n" +
        $"    fn get_x() \{ return this.x \}\n" +
        $"    static fn get_static_x() \{ return Collision.x \}\n" +
        $"\}\n" +
        $"var c = new Collision()\n" +
        $"return c.get_x() + Collision.get_static_x()" // 20 + 10 = 30
    , 30)) _passed++; else _failed++;
    
    // 40. Thrown Object
    if (_assert("Throw Object", 
        $"try \{\n" +
        $"    throw \{ msg: \"Custom Error\", code: 404 \}\n" +
        $"\} catch (e) \{\n" +
        $"    return e.code\n" +
        $"\}\n" +
        $"return 0"
    , 404)) _passed++; else _failed++;
    
    // ============ Batch 5: Algorithms & Stress ============
    
    // 41. Bubble Sort
    if (_assert("Bubble Sort", 
        $"var arr = [5, 3, 8, 1, 2]\n" +
        $"var len = array_length(arr)\n" +
        $"for (var i = 0; i < len; i++) \{\n" +
        $"    for (var j = 0; j < len - i - 1; j++) \{\n" +
        $"        if (arr[j] > arr[j + 1]) \{\n" +
        $"            var temp = arr[j]\n" +
        $"            arr[j] = arr[j + 1]\n" +
        $"            arr[j + 1] = temp\n" +
        $"        \}\n" +
        $"    \}\n" +
        $"\}\n" +
        $"return arr[0] + arr[1] + arr[2] + arr[3] + arr[4]" // 1+2+3+5+8 = 19
    , 19)) _passed++; else _failed++;
    
    // 42. String Reversal
    if (_assert("Reverse String", 
        $"var s = \"abcde\"\n" +
        $"var res = \"\"\n" +
        $"var len = string_length(s)\n" +
        $"for (var i = len; i > 0; i--) \{\n" +
        $"    res += string_char_at(s, i)\n" +
        $"\}\n" +
        $"return res"
    , "edcba")) _passed++; else _failed++;
    
    // 43. Matrix Ops (Access)
    if (_assert("Matrix Access", 
        $"var m = [[1, 2], [3, 4]]\n" +
        $"return m[1][0]" // 3
    , 3)) _passed++; else _failed++;
    
    // 44. Large Loop Count (~1000)
    if (_assert("Large Loop", 
        $"var sum = 0\n" +
        $"for (var i = 0; i < 1000; i++) sum++\n" +
        $"return sum"
    , 1000)) _passed++; else _failed++;
    
    // 45. Null Checks
    if (_assert("Null Check", 
        $"var x = undefined\n" +
        $"return x == undefined"
    , true)) _passed++; else _failed++;
    
    // 46. Type Coercion (Simulated)
    // Proglang behavior dependent on underlying GML
    if (_assert("Coercion Bool", "return true + 1", 2)) _passed++; else _failed++;
    
    // 47. Assignment in Expression
    if (_assert("Assign Expr", 
        $"var x = 5\n" +
        $"var y = (x = 5) + 2\n" +
        $"return y"
    , 3)) _passed++; else _failed++;
    
    // 48. Comma Operator (Sequence)
    // If supported '(a, b)' returns b
    try {
        if (_assert("Comma Op", "return (1, 2)", 2)) _passed++; else _failed++;
        // If not supported, it might return array or error, so wrapping in try/catch or just skipping if parser doesn't support
        // Assuming it's not standard C/JS comma operator, but let's test.
    } catch (_e) { /* Ignore */ }
    
    // 49. Block Scope Cleanup
    if (_assert("Block Scope Clean", 
        $"var x = 1\n" +
        $"\{\n" +
        $"    var y = 2\n" +
        $"\}\n" +
        $"// y should be undefined or error usually, but GML 'var' is function scoped\n" +
        $"// Proglang simulates block scope?\n" +
        $"// If Proglang uses GML structs for scope, it might be persistent if not cleared\n" +
        $"// But assuming correct implementation:\n" +
        $"try \{ return y \} catch (e) \{ return \"Error\" \}"
    , "Error")) _passed++; else _failed++;
    
    // 50. Final Complex Integration
    if (_assert("Complex Integration", 
        $"class Calc \{ \n" +
        $"  static fn add(a, b) \{ return a + b \} \n" +
        $"\}\n" +
        $"var list = [1, 2, 3]\n" +
        $"var sum = 0\n" +
        $"for (v in list) sum = Calc.add(sum, v)\n" +
        $"return sum"
    , 6)) _passed++; else _failed++;
    proglang_execute("print(\"Proglang Print Test OK\")");
    
    // Run verification tests for new features
    proglang_function_test();
    
    // ============ PHASE 13 TESTS: Optimizations ============
    
    // Constant Folding and Propagation
    if (_assert("Constant Optimization", 
        $"var a = 10;\n" +
        $"var b = 20;\n" +
        $"var c = a + b; // Should be 30\n" +
        $"var str1 = \"Hello\";\n" +
        $"var str2 = \" World\";\n" +
        $"var str3 = str1 + str2; // \"Hello World\"\n" +
        $"var bool1 = true;\n" +
        $"var bool2 = false;\n" +
        $"var bool3 = bool1 || bool2; // true\n" +
        $"var x = 100;\n" +
        $"if (true) \{ x = 200; \}\n" +
        $"var y = x; // 200 (should not be constant folded to 100)\n" +
        $"return c == 30 && str3 == \"Hello World\" && bool3 == true && y == 200;"
    , true)) _passed++; else _failed++;


    // ============ PHASE 14 TESTS: Event System ============
    
    if (_assert("Event Hook", 
        $"global var triggered = false\n" +
        $"var sub = event_subscribe(EVENT_TYPE.ACHIEVEMENT_UNLOCKED, fn(data) \{\n" +
        $"    triggered = true\n" +
        $"\})\n" +
        $"event_emit(new EventDataAchievementUnlocked('test'))\n" +
        $"// Cleanup (unsubscribe)\n" +
        $"event_unsubscribe(sub)\n" +
        $"return triggered"
    , true)) _passed++; else _failed++;
    
    if (_assert("Event Unhook", 
        $"global var count = 0\n" +
        $"var sub = event_subscribe(EVENT_TYPE.ACHIEVEMENT_UNLOCKED, fn(data) \{\n" +
        $"    count++\n" +
        $"\})\n" +
        $"event_emit(new EventDataAchievementUnlocked('test1'))\n" +
        $"event_unsubscribe(sub)\n" +
        $"event_emit(new EventDataAchievementUnlocked('test2'))\n" +
        $"return count"
    , 1)) _passed++; else _failed++;

    show_debug_message($"[Proglang Test] COMPLETE. Passed: {_passed}, Failed: {_failed}");
    return _failed == 0;
}

if (IS_DEVELOPER_MODE)
{
    call_later(1, time_source_units_frames, function()
    {
        var _files = file_read_directory($"{PROGRAM_DIRECTORY_RESOURCES}/data/scripts/tests");
        var _length = array_length(_files);
        
        for (var i = 0; i < _length; ++i)
        {
            var _file = _files[i];
            
            var _dir = $"{PROGRAM_DIRECTORY_RESOURCES}/data/scripts/tests/{_file}";
            
            // Skip directories and non-.daydream files
            if (directory_exists(_dir)) continue;
            if (!string_ends_with(_file, ".daydream")) continue;
            //if (_file != "debug_crash.daydream") continue;
            
            show_debug_message($"[ProglangTest] Executing: {_file}");
            proglang_execute(buffer_load_text(_dir), {}, _dir);
        }
    });
    
    test_quadtree();
}