
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
    if (_assert("Destruct Object", "var {x, y} = {x: 5, y: 6}; return x * y", 30)) _passed++; else _failed++;
    if (_assert("Destruct Alias", "var {x: a} = {x: 10}; return a", 10)) _passed++; else _failed++;
    
    // For In Array
    if (_assert("For In Array", @"
        var arr = [1, 2, 3]
        var sum = 0
        for (v in arr) {
            sum += v
        }
        return sum
    ", 6)) _passed++; else _failed++;
    
    // For In Struct
    if (_assert("For In Struct", @"
        var obj = {a: 1, b: 2}
        var count = 0
        for (k in obj) {
            count++
        }
        return count
    ", 2)) _passed++; else _failed++;
    
    // Try Catch (Runtime Error)
    if (_assert("Try Catch Catch", @"
        try {
            var a = undefined
            return a + 1 
        } catch (e) {
            return 100
        }
    ", 100)) _passed++; else _failed++;
    
    if (_assert("Try Catch No Error", @"
        try {
            return 50
        } catch (e) {
            return 100
        }
    ", 50)) _passed++; else _failed++;


    
    // Spread Array
    if (_assert("Spread Array", "var a = [1, 2]; var b = [0, ...a, 3]; return b[2]", 2)) _passed++; else _failed++;
    
    // Spread Call (assuming 'max' is exposed. If not, verify result is correct logic)
    // var args = [1, 5, 2]; return max(...args); -> Wait, Proglang 'max' might be limited.
    // Use user function for reliability
    if (_assert("Spread Call", @"
        fn sum(a, b, c) { return a + b + c; }
        var args = [1, 2, 3];
        return sum(...args);
    ", 6)) _passed++; else _failed++;

    // ============ PHASE 10 TESTS: Complex Scenarios ============

    // 1. Recursion: Factorial
    if (_assert("Recursion Factorial", @"
        fn fact(n) {
            if (n <= 1) return 1
            return n * fact(n - 1)
        }
        return fact(5)
    ", 120)) _passed++; else _failed++;

    // 2. Recursion: Fibonacci
    if (_assert("Recursion Fibonacci", @"
        fn fib(n) {
            if (n <= 1) return n
            return fib(n - 1) + fib(n - 2)
        }
        return fib(10)
    ", 55)) _passed++; else _failed++;

    // 3. Closures: Counter
    if (_assert("Closure Counter", @"
        fn make_counter(start) {
            var count = start
            fn increment() {
                count = count + 1
                return count
            }
            return increment
        }
        var c = make_counter(10)
        c() // 11
        return c()
    ", 12)) _passed++; else _failed++;

    // 4. Higher Order: Map
    if (_assert("Higher Order Map", @"
        fn map(arr, f) {
            var res = []
            for (var i = 0; i < array_length(arr); i++) {
                res[i] = f(arr[i])
            }
            return res
        }
        fn square(x) { return x * x }
        var numbers = [1, 2, 3]
        var squared = map(numbers, square)
        return squared[2]
    ", 9)) _passed++; else _failed++;

    // 5. Higher Order: Filter (manual simulation)
    if (_assert("Higher Order Filter", @"
        var arr = [1, 5, 2, 8, 3]
        var res = []
        var idx = 0
        for (var i = 0; i < array_length(arr); i++) {
            if (arr[i] > 3) {
                res[idx] = arr[i]
                idx++
            }
        }
        return idx
    ", 2)) _passed++; else _failed++;

    /*
    // 6. Complex Data: Inventory Manager
    if (_assert("Inventory Manager", @"
        var inv = [
            { id: \"sword\", qty: 1 },
            { id: \"potion\", qty: 5 },
            { id: \"shield\", qty: 1 }
        ]
        
        fn find_item(items, name) {
            for (item in items) {
                if (item.id == name) return item
            }
            return undefined
        }
        
        var potion = find_item(inv, \"potion\")
        if (potion != undefined) {
            potion.qty += 3
            return potion.qty
        }
        return 0
    ", 8)) _passed++; else _failed++;

    // 7. Algorithm: Bubble Sort
    if (_assert("Bubble Sort", @"
        var arr = [5, 1, 4, 2, 8]
        var n = array_length(arr)
        for (var i = 0; i < n; i++) {
            for (var j = 0; j < n - i - 1; j++) {
                if (arr[j] > arr[j+1]) {
                    var temp = arr[j]
                    arr[j] = arr[j+1]
                    arr[j+1] = temp
                }
            }
        }
        return arr[0] + arr[4] // 1 + 8
    ", 9)) _passed++; else _failed++;

    // 8. Algorithm: Binary Search
    if (_assert("Binary Search", @"
        fn binary_search(arr, target) {
            var left = 0
            var right = array_length(arr) - 1
            while (left <= right) {
                var mid = floor((left + right) / 2)
                if (arr[mid] == target) return mid
                if (arr[mid] < target) left = mid + 1
                else right = mid - 1
            }
            return -1
        }
        var sorted = [10, 20, 30, 40, 50]
        return binary_search(sorted, 40)
    ", 3)) _passed++; else _failed++;

    // 9. Matrix Addition
    if (_assert("Matrix Add", @"
        var m1 = [[1, 2], [3, 4]]
        var m2 = [[5, 6], [7, 8]]
        var res = [[0, 0], [0, 0]]
        
        for (var r = 0; r < 2; r++) {
            for (var c = 0; c < 2; c++) {
                res[r][c] = m1[r][c] + m2[r][c]
            }
        }
        return res[1][1] // 4 + 8 = 12
    ", 12)) _passed++; else _failed++;

    // 10. State Machine (Traffic Light)
    if (_assert("State Machine", @"
        var state = \"red\"
        var actions = 0
        
        for (var i = 0; i < 5; i++) {
            switch (state) {
                case \"red\":
                    state = \"green\"
                    break
                case \"green\":
                    state = \"yellow\"
                    actions++ // go
                    break
                case \"yellow\":
                    state = \"red\"
                    break
            }
        }
        return actions
    ", 2)) _passed++; else _failed++;

    // 11. String Parsing (CSV)
    if (_assert("CSV Parse", @"
        var csv = \"10,20,30,40\"
        var sum = 0
        var num_str = \"\"
        var len = string_length(csv)
        
        for (var i = 1; i <= len; i++) {
            var char = string_char_at(csv, i)
            if (char == \",\") {
                sum += real(num_str)
                num_str = \"\"
            } else {
                num_str += char
            }
        }
        sum += real(num_str) // last one
        return sum
    ", 100)) _passed++; else _failed++;

    // 12. Vector Dot Product
    if (_assert("Vector Struct Dot", @"
        fn dot(v1, v2) {
            return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z
        }
        var a = {x: 1, y: 2, z: 3}
        var b = {x: 4, y: -5, z: 6}
        return dot(a, b) // 4 - 10 + 18 = 12
    ", 12)) _passed++; else _failed++;

    // 13. Function Wrapper (Mock Decorator)
    if (_assert("Function Wrapper", @"
        fn logger(func, arg) {
            // log \"calling\"
            var res = func(arg)
            // log \"done\"
            return res
        }
        fn double_it(n) { return n * 2 }
        return logger(double_it, 21)
    ", 42)) _passed++; else _failed++;
    
    // 14. Deep Nesting Update
    if (_assert("Deep Nesting", @"
        var config = {
            graphics: {
                resolution: { w: 1920, h: 1080 },
                settings: { bloom: true }
            }
        }
        config.graphics.resolution.w = 2560
        return config.graphics.resolution.w
    ", 2560)) _passed++; else _failed++;

    // 15. Scope Shadowing
    if (_assert("Scope Shadowing", @"
        var x = 10
        fn test(x) {
            var y = 20
            return x + y // param x (5) + y (20) = 25
        }
        return test(5) + x // 25 + 10 = 35
    ", 35)) _passed++; else _failed++;

    // 16. Array Merging (Spread)
    if (_assert("Merge Configs via Spread", @"
        var default_tags = [\"item\", \"pickable\"]
        var weapon_tags = [\"weapon\", \"damage\"]
        var all_tags = [...default_tags, ...weapon_tags, \"legendary\"]
        return all_tags[4]
    ", "legendary")) _passed++; else _failed++;

    // 17. Exception in Loop
    if (_assert("Exception Loop", @"
        var sum = 0
        var items = [10, 20, undefined, 30]
        for (item in items) {
             try {
                 if (item == undefined) throw \"bad item\"
                 sum += item
             } catch (e) {
                 // ignore
             }
        }
        return sum
    ", 60)) _passed++; else _failed++;

    // 18. Prime Finder
    if (_assert("Prime Finder", @"
        fn is_prime(n) {
            if (n < 2) return false
            for (var i = 2; i * i <= n; i++) {
                if (n % i == 0) return false
            }
            return true
        }
        var count = 0
        for (var k = 1; k < 20; k++) {
            if (is_prime(k)) count++
        }
        // 2, 3, 5, 7, 11, 13, 17, 19 -> 8 primes
        return count
    ", 8)) _passed++; else _failed++;
    
    // 19. Context Binding (this simulation)
    if (_assert("Object Method simulation", @"
        fn create_player(name) {
            var p = { name: name, hp: 100 }
            p.heal = fn(amount) {
                // 'p' is captured by closure
                p.hp += amount
                return p.hp
            }
            return p
        }
        var player = create_player("Hero")
        player.heal(50)
        return player.hp
    ", 150)) _passed++; else _failed++;
    
    // 20. Mini Evaluator
    if (_assert("Mini Eval", @"
        var program = [1, 5, 2] // ADD, 5, 2
        // Ops: 1=ADD, 2=SUB
        var ip = 0
        var reg = 0
        while (ip < array_length(program)) {
            var op = program[ip]
            ip++
            if (op == 1) {
                var val1 = program[ip]; ip++;
                var val2 = program[ip]; ip++;
                reg = val1 + val2
            }
        }
        return reg
    ", 7)) _passed++; else _failed++;*/

    show_debug_message($"[Proglang Test] Tests Completed. Passed: {_passed}, Failed: {_failed}");
    
    return (_failed == 0);
}


proglang_test();