# Math Functions

Mathematical functions for calculations, trigonometry, and vector operations.

---

## Constants

| Name  | Type   | Value (Approx) | Description                                       |
| ----- | ------ | -------------- | ------------------------------------------------- |
| `PI`  | Number | 3.14159...     | Ratio of a circle's circumference to its diameter |
| `TAU` | Number | 6.28318...     | `2 * PI`                                          |
| `E`   | Number | 2.71828...     | Euler's number                                    |
| `PHI` | Number | 1.61803...     | The Golden Ratio                                  |

---

## Basic Math

### `min(a, b)`: Number

Returns the smaller of two values.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `a` | Number | First value |
| `b` | Number | Second value |

**Returns:** The smaller value.

```javascript
min(10, 5); // 5
```

### `max(a, b)`: Number

Returns the larger of two values.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `a` | Number | First value |
| `b` | Number | Second value |

**Returns:** The larger value.

```javascript
max(10, 5); // 10
```

### `abs(n)`: Number

Returns the absolute value.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | Number | Input value |

**Returns:** The absolute value (always positive).

```javascript
abs(-5); // 5
```

### `sign(n)`: Number

Returns the sign of a number.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | Number | Input value |

**Returns:** `-1` if negative, `0` if zero, `1` if positive.

```javascript
sign(-50); // -1
sign(0); // 0
sign(42); // 1
```

---

## Rounding

### `round(n)`: Number

Rounds to the nearest integer.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | Number | Value to round |

**Returns:** The rounded integer.

```javascript
round(3.6); // 4
round(3.4); // 3
```

### `floor(n)`: Number

Rounds down to the nearest integer.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | Number | Value to round down |

**Returns:** The floor value.

```javascript
floor(3.9); // 3
floor(-3.1); // -4
```

### `ceil(n)`: Number

Rounds up to the nearest integer.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | Number | Value to round up |

**Returns:** The ceiling value.

```javascript
ceil(3.1); // 4
ceil(-3.9); // -3
```

### `frac(n)`: Number

Returns the fractional part of a number.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | Number | Input value |

**Returns:** The fractional component (0 to 1).

```javascript
frac(3.75); // 0.75
```

---

## Interpolation & Clamping

### `clamp(val, min, max)`: Number

Constrains a value between min and max.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `val` | Number | Value to constrain |
| `min` | Number | Minimum bound |
| `max` | Number | Maximum bound |

**Returns:** The clamped value.

```javascript
clamp(15, 0, 10); // 10
clamp(-5, 0, 10); // 0
clamp(5, 0, 10); // 5
```

### `lerp(a, b, t)`: Number

Linearly interpolates between two values.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `a` | Number | Start value |
| `b` | Number | End value |
| `t` | Number | Interpolation factor (0-1) |

**Returns:** The interpolated value.

```javascript
lerp(0, 100, 0.5); // 50
lerp(0, 100, 0.25); // 25
```

---

## Power & Roots

### `power(base, exp)`: Number

Returns base raised to the power of exp.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `base` | Number | The base |
| `exp` | Number | The exponent |

**Returns:** `base^exp`.

```javascript
power(2, 3); // 8
power(10, 2); // 100
```

### `sqrt(n)`: Number

Returns the square root.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | Number | Value (must be >= 0) |

**Returns:** The square root.

```javascript
sqrt(16); // 4
sqrt(2); // 1.414...
```

### `sqr(n)`: Number

Returns the square of a number (n \* n).

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `n` | Number | Value to square |

**Returns:** `n * n`.

```javascript
sqr(5); // 25
```

---

## Trigonometry (Radians)

### `sin(x)`: Number

Returns sine of x in radians.

```javascript
sin(0); // 0
sin(pi / 2); // 1
```

### `cos(x)`: Number

Returns cosine of x in radians.

```javascript
cos(0); // 1
cos(pi); // -1
```

### `tan(x)`: Number

Returns tangent of x in radians.

```javascript
tan(0); // 0
tan(pi / 4); // 1
```

### `arcsin(x)`: Number

Returns the arcsine (inverse sine) in radians.

### `arccos(x)`: Number

Returns the arccosine (inverse cosine) in radians.

### `arctan(x)`: Number

Returns the arctangent (inverse tangent) in radians.

### `arctan2(y, x)`: Number

Returns the angle from origin to point (x, y) in radians.

---

## Trigonometry (Degrees)

### `dsin(x)`: Number

Returns sine of x in degrees.

```javascript
dsin(90); // 1
```

### `dcos(x)`: Number

Returns cosine of x in degrees.

```javascript
dcos(180); // -1
```

### `dtan(x)`: Number

Returns tangent of x in degrees.

```javascript
dtan(45); // 1
```

### `degtorad(deg)`: Number

Converts degrees to radians.

### `radtodeg(rad)`: Number

Converts radians to degrees.

---

## Vector Math

### `lengthdir_x(len, dir)`: Number

Returns the horizontal component of a vector.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `len` | Number | Vector length |
| `dir` | Number | Direction in degrees |

**Returns:** X component.

```javascript
lengthdir_x(10, 0); // 10 (pointing right)
lengthdir_x(10, 90); // 0  (pointing up)
```

### `lengthdir_y(len, dir)`: Number

Returns the vertical component of a vector.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `len` | Number | Vector length |
| `dir` | Number | Direction in degrees |

**Returns:** Y component.

```javascript
lengthdir_y(10, 0); // 0  (pointing right)
lengthdir_y(10, 90); // -10 (pointing up, Y increases downward)
```

### `point_distance(x1, y1, x2, y2)`: Number

Returns the distance between two points.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `x1`, `y1` | Number | First point coordinates |
| `x2`, `y2` | Number | Second point coordinates |

**Returns:** Distance as a positive number.

```javascript
point_distance(0, 0, 3, 4); // 5
```

### `point_direction(x1, y1, x2, y2)`: Number

Returns the direction from point 1 to point 2.

**Arguments:**
| Name | Type | Description |
|------|------|-------------|
| `x1`, `y1` | Number | Origin point |
| `x2`, `y2` | Number | Target point |

**Returns:** Direction in degrees (0-360).

```javascript
point_direction(0, 0, 10, 0); // 0 (right)
point_direction(0, 0, 0, -10); // 90 (up)
```
