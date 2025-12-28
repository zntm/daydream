# Debugging

Functions for debugging, assertions, and performance profiling.

---

## Output

### `print(...)`: Undefined

Prints one or more values to the debug console, separated by spaces.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `...` | Any | Any number of values to print |

**Returns:** Nothing (undefined).

```javascript
print("Hello, World!");
print("User:", user.name, "Score:", user.score);
print("Array:", [1, 2, 3]);
```

---

## Assertions

### `assert(condition, message?)`: Undefined

Throws an error if the condition is false. Useful for validating assumptions.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `condition` | Boolean | Condition to check |
| `message` | String | Optional error message |

**Returns:** Nothing, or throws PROG_ERROR.RUNTIME if condition is false.

```javascript
assert(hp > 0, "Player health must be positive");
assert(array_length(items) > 0); // Default message: "Assertion failed"
```

---

## Performance Timing

### `time_start(name)`: Undefined

Starts a named timer for performance measurement.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `name` | String | Timer identifier |

**Returns:** Nothing (undefined).

```javascript
time_start("pathfinding");
// ... expensive operation ...
var elapsed = time_end("pathfinding");
print($"Pathfinding took {elapsed}ms");
```

### `time_end(name)`: Number

Stops a named timer and returns elapsed time.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `name` | String | Timer identifier (must match `time_start`) |

**Returns:** Elapsed time in milliseconds.

```javascript
time_start("loop");
for (var i = 0; i < 10000; i++) {
    // work
}
var ms = time_end("loop");
print($"Loop completed in {ms}ms");
```

> [!NOTE]
> Calling `time_end` removes the timer. You must call `time_start` again to restart timing.

---

## Constants

### `infinity`: Number

The mathematical infinity value. Useful for initializing min/max comparisons.

```javascript
var min_val = infinity;
for (v in values) {
    if (v < min_val) min_val = v;
}
```
