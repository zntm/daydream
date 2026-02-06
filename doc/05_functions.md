# Functions

Functions are first-class citizens in Daydream. They can be assigned to variables, passed as arguments, and returned from other functions.

## Declaration

Use `fn` to declare a function.

```javascript
fn mysum(a, b) {
    return a + b;
}

print(mysum(10, 20)); // 30
```

### Semicolons and Return

Like `break` and `continue`, the `return` keyword is subject to ASI rules. If you want to return an expression, it MUST start on the same line as the `return` keyword.

```javascript
fn get_value() {
    return 42; // Returns 42
}

fn get_nothing() {
    return
    42; // Returns undefined! 42 is treated as a separate expression statement.
}
```

### Optional Parameters

Parameters can have default values.

```javascript
fn greet(name, greeting = "Hello") {
    print($"{greeting}, {name}!");
}

greet("Alice"); // "Hello, Alice!"
greet("Bob", "Hi"); // "Hi, Bob!"
```

## Anonymous Functions

Functions can be created without a name (lambdas/closures).

```javascript
var square = fn(x) { return x * x; };
print(square(4)); // 16
```

## Closures

Functions capture the scope in which they are defined.

```javascript
fn make_counter() {
    var count = 0;
    return fn() {
        count++;
        return count;
    };
}

var counter = make_counter();
print(counter()); // 1
print(counter()); // 2
```

## Destructuring Arguments

You can destruct objects or arrays using assignment syntax within the function body.

```javascript
fn print_point(pt) {
    var {x, y} = pt;
    print($"X: {x}, Y: {y}");
}

print_point({x: 10, y: 20});
```
