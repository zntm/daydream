# Random Functions

Functions for generating random numbers and making random selections.

---

## Random Numbers

### `random(n)`: Number

Returns a random real number between 0 (inclusive) and n (exclusive).

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | Number | Upper bound (exclusive) |

**Returns:** A random real number in range `[0, n)`.

```javascript
random(10); // e.g. 5.123, 0.001, 9.999
random(1); // e.g. 0.742 (useful for probability checks)
```

### `irandom(n)`: Number

Returns a random integer between 0 and n (inclusive).

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | Number | Upper bound (inclusive) |

**Returns:** A random integer in range `[0, n]`.

```javascript
irandom(10); // 0, 1, 2, ... or 10
irandom(5); // Could be 0, 1, 2, 3, 4, or 5
```

### `random_range(min, max)`: Number

Returns a random real number within a range.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `min` | Number | Lower bound (inclusive) |
| `max` | Number | Upper bound (inclusive) |

**Returns:** A random real number in range `[min, max]`.

```javascript
random_range(10, 20); // e.g. 15.7, 10.2, 19.9
random_range(-1, 1); // e.g. -0.5, 0.8, 0.0
```

### `irandom_range(min, max)`: Number

Returns a random integer within a range.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `min` | Number | Lower bound (inclusive) |
| `max` | Number | Upper bound (inclusive) |

**Returns:** A random integer in range `[min, max]`.

```javascript
irandom_range(10, 20); // 10, 11, 12, ... or 20
irandom_range(1, 6); // Simulates a dice roll: 1-6
```

---

## Random Selection

### `choose(array)`: Any

Randomly returns one element from the provided array.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `array` | Array | Array of values to choose from |

**Returns:** One of the array elements, selected randomly.

```javascript
choose(["A", "B", "C"]); // "A", "B", or "C"
choose([1, 2, 3, 4, 5]); // 1, 2, 3, 4, or 5
choose(["common", "rare"]); // Random rarity
```

> [!TIP]
> All values have equal probability. For weighted random selection, use conditional logic with `random(1)`.
