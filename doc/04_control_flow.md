# Control Flow

## Conditional Statements

### if / else

Execute code only if a condition is true.

```javascript
if (score > 100) {
    print("High Score!");
} else {
    print("Try Again");
}
```

### switch

Select one of many code blocks to be executed.

```javascript
switch (state) {
    case "idle":
        // ...
        break;
    case "run":
        // ...
        break;
    default:
    // ...
}
```

(Note: `break` is required to prevent fall-through).

### break N (Multi-Level Break)

You can break out of multiple nested loops by specifying a number after `break`:

```javascript
for (var i = 0; i < 10; i++) {
    for (var j = 0; j < 10; j++) {
        if (found) break 2; // Breaks out of BOTH loops
    }
}
```

`break 1` is equivalent to `break`. The number must be a literal value.

## Loops

### while

Loops while a condition is true.

```javascript
var i = 0;
while (i < 5) {
    print(i);
    i++;
}
```

### for

Standard C-style for loop.

```javascript
for (var i = 0; i < 10; i++) {
    print(i);
}
```

### repeat

Executes a block a specific number of times.

```javascript
repeat (5) {
    print("Hello");
}
```

### for...in

Iterate over arrays or struct keys.

**Arrays:**

```javascript
var list = ["a", "b", "c"];
for (val in list) {
    print(val); // "a", then "b", then "c"
}

// With index
for (val, index in list) {
    print($"Index {index}: {val}");
}
```

**Structs:**

```javascript
var obj = { x: 10, y: 20 };
for (key in obj) {
    print(key); // "x", "y" (order not guaranteed)
}

// With value
for (key, val in obj) {
    print($"{key}: {val}");
}
```

**Ranges:**

Iterate over a numeric range (inclusive).

```javascript
for (i in 1..10) {
    print(i); // 1, 2, ..., 10
}
```

## Error Handling

### try / catch

Handle runtime errors gracefully.

```javascript
try {
    var result = 10 / 0; // Or some operation that might throw
    throw "My Error";
} catch (e) {
    print($"Caught error: {e}");
}
```

### Error Types

The `PROG_ERROR` enum defines specific error types that can be checked in a `catch` block.

```javascript
try {
    // ...
} catch (e) {
    if (is_struct(e) && variable_struct_exists(e, "type")) {
        if (e.type == PROG_ERROR.DIVIDE_BY_ZERO) {
            print("Cannot divide by zero!");
        }
    }
}
```

| Type                          | Description                      | Example Cause                           |
| ----------------------------- | -------------------------------- | --------------------------------------- |
| `PROG_ERROR.RUNTIME`          | Generic runtime error            | `throw "Error"`                         |
| `PROG_ERROR.TYPE`             | Type mismatch                    | `array_push(10, 5)` (1st arg not array) |
| `PROG_ERROR.INDEX`            | Array/String index out of bounds | `[1, 2][5]`                             |
| `PROG_ERROR.MEMBER`           | Invalid member access            | `obj.missing_prop`                      |
| `PROG_ERROR.VARIABLE`         | Variable not found               | `print(unknown_var)`                    |
| `PROG_ERROR.DIVIDE_BY_ZERO`   | Division by zero                 | `10 / 0`                                |
| `PROG_ERROR.UNDEFINED_VALUE`  | Operation on undefined value     | `undefined + 5`                         |
| `PROG_ERROR.NULL_REFERENCE`   | Dereferencing null/undefined     | `undefined.prop`                        |
| `PROG_ERROR.INVALID_ARGUMENT` | Invalid argument passed          | `sqrt(-1)` (if strict)                  |
| `PROG_ERROR.NOT_CALLABLE`     | Calling a non-function           | `var x = 1; x()`                        |
| `PROG_ERROR.SYNTAX`           | Syntax error                     | `if (x {`                               |
| `PROG_ERROR.IMPORT`           | Module import failure            | `import "missing_file"`                 |
| `PROG_ERROR.STACK_OVERFLOW`   | Stack limit reached              | Deep recursion `f() { f() }`            |
| `PROG_ERROR.STACK_UNDERFLOW`  | Stack underflow                  | Internal VM error                       |
| `PROG_ERROR.RECURSION_LIMIT`  | Recursion depth limit            | Deep recursion                          |
| `PROG_ERROR.INFINITE_LOOP`    | Infinite loop protection         | `while(true) {}`                        |
| `PROG_ERROR.ACCESS_DENIED`    | Access violation                 | Accessing `private` member              |
| `PROG_ERROR.ABSTRACT_METHOD`  | Abstract method usage            | `new AbstractClass()`                   |
| `PROG_ERROR.FILE_NOT_FOUND`   | File system error                | Opening non-existent file               |
| `PROG_ERROR.PATH_SECURITY`    | Path violation                   | Accessing forbidden path                |
| `PROG_ERROR.ARITY_MISMATCH`   | Incorrect argument count         | `fn f(a,b){} f(1)`                      |
| `PROG_ERROR.SUPER_ERROR`      | Invalid super usage              | `super` outside class                   |
