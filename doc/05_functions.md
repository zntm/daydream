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
