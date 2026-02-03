
function proglang_annotations_test() {
    var _passed = 0;
    var _failed = 0;
    
    var _assert = function(_name, _source, _expected) {
        try {
            var _result = proglang_execute(_source);
            if (_result == _expected) {
                show_debug_message($"[PogLang Annotation Test] PASS: {_name}");
                return true;
            } else {
                show_debug_message($"[PogLang Annotation Test] FAIL: {_name}. Expected {_expected}, got {_result}");
                return false;
            }
        } catch (_e) {
            show_debug_message($"[PogLang Annotation Test] FAIL (EXCEPTION): {_name}. Error: {_e}");
            return false;
        }
    }
    
    show_debug_message("[PogLang Annotation Test] Starting Tests...");
    
    // 1. @memoize
    var _memo_src = @"
        var calls = 0;
        @memoize
        fn square(x) {
            calls += 1;
            return x * x;
        }
        square(2);
        square(2);
        square(3);
        square(3);
        return calls;
    ";
    if (_assert("Memoization Basic", _memo_src, 2)) _passed++; else _failed++;

    // 2. @memoize with multiple args
    var _memo_multi_src = @"
        var calls = 0;
        @memoize
        fn add(a, b) {
            calls += 1;
            return a + b;
        }
        add(1, 2);
        add(1, 2);
        add(2, 1); // Different order
        return calls;
    ";
    if (_assert("Memoization Multiple Args", _memo_multi_src, 2)) _passed++; else _failed++;

    // 3. wait(callback, params, seconds)
    var _wait_src = @"
        var val = 0;
        wait(fn(v) { val = v; }, [100], 0.1);
        return val;
    ";
    // This will initially be 0 because wait is asynchronous
    if (_assert("Wait Callback (Initial)", _wait_src, 0)) _passed++; else _failed++;

    // 5. Simplified Syntax (No braces)
    var _syntax_src = @"
        @inline
        fn test() { return 42; }
        return test();
    ";
    if (_assert("Simplified Syntax @inline", _syntax_src, 42)) _passed++; else _failed++;
    
    show_debug_message($"[PogLang Annotation Test] FINISHED. Passed: {_passed}, Failed: {_failed}");
    return _failed == 0;
}
