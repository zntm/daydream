# Math Functions

### `min(a, b)`: Number

Returns the smaller of two values.

```javascript
min(10, 5); // 5
```

### `max(a, b)`: Number

Returns the larger of two values.

```javascript
max(10, 5); // 10
```

### `abs(n)`: Number

Returns the absolute value.

```javascript
abs(-5); // 5
```

### `round(n)`: Number

Rounds to the nearest integer.

```javascript
round(3.6); // 4
```

### `floor(n)`: Number

Rounds down to the nearest integer.

```javascript
floor(3.9); // 3
```

### `ceil(n)`: Number

Rounds up to the nearest integer.

```javascript
ceil(3.1); // 4
```

### `sign(n)`: Number

Returns -1 if negative, 0 if zero, 1 if positive.

```javascript
sign(-50); // -1
```

### `clamp(val, min, max)`: Number

Constrains a value between min and max.

```javascript
clamp(15, 0, 10); // 10
```

### `lerp(a, b, t)`: Number

Linearly interpolates between `a` and `b` by amount `t` (0-1).

```javascript
lerp(0, 100, 0.5); // 50
```

### `power(base, exp)`: Number

Returns base raised to the power of exp.

```javascript
power(2, 3); // 8
```

### `sqrt(n)`: Number

Returns the square root of n.

```javascript
sqrt(16); // 4
```

### `sin(x)`: Number

Returns sine of x (in radians).

### `cos(x)`: Number

Returns cosine of x (in radians).

### `tan(x)`: Number

Returns tangent of x (in radians).

### `dsin(x)`: Number

Returns sine of x (in degrees).

### `dcos(x)`: Number

Returns cosine of x (in degrees).

### `dtan(x)`: Number

Returns tangent of x (in degrees).

### `lengthdir_x(len, dir)`: Number

Returns the horizontal component of a vector with given length and direction (degrees).

### `lengthdir_y(len, dir)`: Number

Returns the vertical component of a vector with given length and direction (degrees).

### `point_distance(x1, y1, x2, y2)`: Number

Returns the distance between two points.

### `point_direction(x1, y1, x2, y2)`: Number

Returns the direction (in degrees) from point 1 to point 2.
