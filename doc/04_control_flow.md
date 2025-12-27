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
