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

Available error types:

-   `PROG_ERROR.NONE`: No error.
-   `PROG_ERROR.RUNTIME`: Generic runtime error.
-   `PROG_ERROR.TYPE`: Type mismatch (e.g. adding string to object).
-   `PROG_ERROR.INDEX`: Array or string index out of bounds.
-   `PROG_ERROR.MEMBER`: accessing invalid struct member.
-   `PROG_ERROR.VARIABLE`: Variable not found.
-   `PROG_ERROR.DIVIDE_BY_ZERO`: Division by zero.
-   `PROG_ERROR.UNDEFINED_VALUE`: Operation on undefined value.
-   `PROG_ERROR.NULL_REFERENCE`: Dereferencing null/undefined.
-   `PROG_ERROR.INVALID_ARGUMENT`: Invalid argument passed to function.
-   `PROG_ERROR.NOT_CALLABLE`: Attempting to call a non-function.
-   `PROG_ERROR.SYNTAX`: Syntax error during compilation.
-   `PROG_ERROR.IMPORT`: Module import failure.
-   `PROG_ERROR.STACK_OVERFLOW`: Stack overflow.
-   `PROG_ERROR.STACK_UNDERFLOW`: Stack underflow.
-   `PROG_ERROR.RECURSION_LIMIT`: Maximum recursion depth exceeded.
-   `PROG_ERROR.INFINITE_LOOP`: Infinite loop protection triggered.
-   `PROG_ERROR.ACCESS_DENIED`: Access violation (e.g. private member).
-   `PROG_ERROR.READ_ONLY`: Modifying read-only value.
-   `PROG_ERROR.ABSTRACT_METHOD`: calling abstract method.
-   `PROG_ERROR.FILE_NOT_FOUND`: File not found.
-   `PROG_ERROR.PATH_SECURITY`: Path security violation.
-   `PROG_ERROR.ARITY_MISMATCH`: Incorrect number of arguments.
-   `PROG_ERROR.SUPER_ERROR`: Invalid use of `super`.
