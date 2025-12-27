# Random Functions

### `random(n)`: Number

Returns a random real number between 0 (inclusive) and n (exclusive).

```javascript
random(10); // e.g. 5.123
```

### `irandom(n)`: Number

Returns a random integer between 0 and n (inclusive).

```javascript
irandom(10); // e.g. 7
```

### `random_range(min, max)`: Number

Returns a random real number between min (inclusive) and max (inclusive).

```javascript
random_range(10, 20);
```

### `irandom_range(min, max)`: Number

Returns a random integer between min and max (inclusive).

```javascript
irandom_range(10, 20);
```

### `choose(val1, val2, ...)`: Any

Randomly returns one of the provided arguments.

```javascript
choose("A", "B", "C"); // e.g. "B"
```
